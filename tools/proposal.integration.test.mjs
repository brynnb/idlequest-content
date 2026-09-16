import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import mysql from 'mysql2/promise';
import { randomUUID } from 'node:crypto';
import { applyProposal, readProposal } from './proposal.mjs';
import { generateMigration } from './migration.mjs';
import { localConfig, readManifest, hash, encodedRow } from './dataset.mjs';

const root = process.env.IDLEQUEST_CONTENT_DATASET;
const env = process.env.IDLEQUEST_CONTENT_ENV;
const database = process.env.IDLEQUEST_CONTENT_DATABASE;
test('real MySQL proposal round trip, preimage conflicts and rollback', { skip: !root || !env || !database }, async t => {
  assert.match(database, /^idlequest_content_[a-z0-9_]+$/);
  const config = await localConfig(env, database);
  const db = await mysql.createConnection(config);
  const { manifest, manifestHash } = await readManifest(root);
  const [[questRaw]] = await db.query("SELECT * FROM quests WHERE zone='freportn' AND name='Ton_Twostring'");
  const [[npcRaw]] = await db.query("SELECT * FROM npc_types WHERE name='Ton_Twostring' ORDER BY id LIMIT 1");
  assert.ok(questRaw && npcRaw);
  const quest = encodedRow(questRaw, manifest.tables.quests.columns);
  const npc = encodedRow(npcRaw, manifest.tables.npc_types.columns);
  const lua = quest.lua_content + '\n-- Content bundle round-trip fixture; behavior unchanged.\n';
  const directory = `changes/test-${randomUUID()}`;
  await fs.mkdir(path.join(root,directory), { recursive: true });
  t.after(() => fs.rm(path.join(root,directory), { recursive: true, force: true }));
  const proposedFile = `${directory}/Ton_Twostring.lua`;
  await fs.writeFile(path.join(root, proposedFile),lua);
  const target = 'maintained/lua/modified-upstream/freportn/Ton_Twostring.lua';
  const proposal = {
    format: 1, id: 'ton-roundtrip-test', summary: 'Test source/data round trip without changing quest mechanics',
    baseManifestSha256: manifestHash,
    evidence: [{ url: 'https://wiki.project1999.com/Ton_Twostring', note: 'Fixture exercises the existing two-mail hand-in; no new content claim.' }],
    rows: [
      { table: 'quests', before: quest, after: { ...quest, lua_content: lua } },
      { table: 'npc_types', before: npc, after: { ...npc, hp: String(Number(npc.hp) + 1) } },
    ],
    sources: [{ target, beforeSha256: manifest.files[target], proposedFile, afterSha256: hash(lua) }],
  };
  const file = `${directory}/proposal.json`;
  const save = p => fs.writeFile(path.join(root,file), JSON.stringify(p));
  const restore = async () => {
    await db.query('UPDATE quests SET lua_content=? WHERE id=?',[quest.lua_content,quest.id]);
    await db.query('UPDATE npc_types SET hp=?,loottable_id=? WHERE id=?',[npc.hp,npc.loottable_id,npc.id]);
  };
  t.after(async () => { try { await restore(); } finally { await db.end(); } });
  await save(proposal);

  await t.test('preview rolls back and apply is repeatable', async () => {
    assert.equal((await applyProposal(root,file,config)).changed,2);
    const [[untouched]] = await db.query('SELECT lua_content FROM quests WHERE id=?',[quest.id]);
    assert.equal(untouched.lua_content,quest.lua_content);
    assert.equal((await applyProposal(root,file,config,{apply:true})).changed,2);
    assert.equal((await applyProposal(root,file,config,{apply:true})).alreadyApplied,2);
    const [[updated]] = await db.query('SELECT lua_content FROM quests WHERE id=?',[quest.id]);
    assert.equal(updated.lua_content,lua);
    await restore();
  });
  await t.test('generated deployment SQL applies, repeats and rolls back on a later stale row', async () => {
    const checked=await readProposal(root,file);
    const sql=await generateMigration(root,checked.manifest,checked.proposal,'a'.repeat(40));
    const run=async()=>{
      const connection=await mysql.createConnection({...config,multipleStatements:true});
      try { await connection.query(sql); } finally { await connection.end(); }
    };
    await run();
    await run();
    const [[applied]]=await db.query('SELECT lua_content FROM quests WHERE id=?',[quest.id]);
    assert.equal(applied.lua_content,lua);
    await restore();
    await db.query('UPDATE npc_types SET hp=? WHERE id=?',[npc.hp+2,npc.id]);
    await assert.rejects(run(),/Check constraint/);
    const [[unchanged]]=await db.query('SELECT lua_content FROM quests WHERE id=?',[quest.id]);
    assert.equal(unchanged.lua_content,quest.lua_content);
    await restore();
  });
  await t.test('stale second row rolls back the first row', async () => {
    await db.query('UPDATE npc_types SET hp=? WHERE id=?',[npc.hp+2,npc.id]);
    await assert.rejects(applyProposal(root,file,config,{apply:true}),/Stale database row/);
    const [[untouched]] = await db.query('SELECT lua_content FROM quests WHERE id=?',[quest.id]);
    assert.equal(untouched.lua_content,quest.lua_content);
    await restore();
  });
  await t.test('missing loot-table reference rolls back all changes', async () => {
    const altered = structuredClone(proposal);
    altered.rows[1].after.loottable_id = 4294967000;
    await save(altered);
    await assert.rejects(applyProposal(root,file,config,{apply:true}),/Missing reference/);
    const [[untouched]] = await db.query('SELECT lua_content FROM quests WHERE id=?',[quest.id]);
    assert.equal(untouched.lua_content,quest.lua_content);
    await save(proposal);
  });
  await t.test('schema drift fails before writes', async () => {
    await db.query('ALTER TABLE quests ADD COLUMN content_test_drift int DEFAULT 0');
    try { await assert.rejects(applyProposal(root,file,config,{apply:true}),/Schema drift/); }
    finally { await db.query('ALTER TABLE quests DROP COLUMN content_test_drift'); }
  });
  await t.test('baseline, source and row contracts reject malformed proposals', async () => {
    for (const [mutate, error] of [
      [p => p.baseManifestSha256 = 'wrong', /baseline pin/],
      [p => p.rows.push(p.rows[0]), /Duplicate proposal row/],
      [p => p.rows[0].before.lua_content = 'newer fix', /preimage differs/],
      [p => p.sources = [], /requires maintained source/],
      [p => p.sources[0].afterSha256 = 'wrong', /source checksum/],
    ]) {
      const altered = structuredClone(proposal); mutate(altered); await save(altered);
      await assert.rejects(readProposal(root,file),error);
    }
    await save(proposal);
  });
});
