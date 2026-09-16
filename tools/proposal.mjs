import fs from 'node:fs/promises';
import path from 'node:path';
import mysql from 'mysql2/promise';
import { hash, quote, decode, encodedRow, safeFile, tableRows, validateDataset } from './dataset.mjs';
import { normalizeSchema } from './export.mjs';
import { scriptKey } from './source-audit.mjs';
import { checkChangedReferences } from './relations.mjs';
import { sourceKind, sourceEnabled, validateLedger } from './source-policy.mjs';

const exact = (a,b) => JSON.stringify(a) === JSON.stringify(b);
const ordered = (row, columns) => row === null ? null : Object.fromEntries(columns.map(c => [c,row[c]]));

// Proposals never mutate the baseline. Both data and source changes carry exact
// preimages, so applying one cannot overwrite a newer fix unnoticed.
export async function readProposal(root, file) {
  const baseline = await validateDataset(root);
  const proposal = JSON.parse(await fs.readFile(await safeFile(root, file), 'utf8'));
  if (proposal.format !== 1 || proposal.baseManifestSha256 !== baseline.manifestHash) throw new Error('Proposal baseline pin mismatch');
  if (!/^[a-z0-9][a-z0-9-]+$/.test(proposal.id ?? '') || !proposal.summary?.trim()) throw new Error('Proposal requires an ID and summary');
  if (!Array.isArray(proposal.evidence) || !proposal.evidence.length || proposal.evidence.some(e => !e.url || !e.note)) throw new Error('Proposal requires evidence URLs and notes');
  if (!Array.isArray(proposal.rows) || !Array.isArray(proposal.sources)) throw new Error('Proposal requires rows and sources arrays');
  const seen = new Set();
  const groups = new Map();
  for (const change of proposal.rows) {
    const table = baseline.manifest.tables[change.table];
    if (!table || !table.primaryKey.length) throw new Error(`Table is not editable by key: ${change.table}`);
    for (const row of [change.before, change.after]) {
      if (row === null) continue;
      if (!row || !exact(Object.keys(row).sort(), [...table.columns].sort())) throw new Error(`${change.table}: require complete row preimage/postimage`);
    }
    if (change.before === null && change.after === null) throw new Error('Empty row change');
    const key = table.primaryKey.map(k => (change.before ?? change.after)[k]);
    if (change.before && change.after && !exact(key, table.primaryKey.map(k => change.after[k]))) throw new Error('Primary keys cannot be changed; use explicit delete and insert');
    if(change.table==='quests' && change.before && change.after && (change.before.zone!==change.after.zone || change.before.name!==change.after.name)) throw new Error('Quest runtime keys cannot be renamed in place; disable the old key and add a separately reviewed new key');
    const id = `${change.table}:${JSON.stringify(key)}`;
    if (seen.has(id)) throw new Error(`Duplicate proposal row: ${id}`);
    seen.add(id);
    change.key = key;
    change.before = ordered(change.before, table.columns);
    change.after = ordered(change.after, table.columns);
    if (!groups.has(change.table)) groups.set(change.table, new Map());
    groups.get(change.table).set(JSON.stringify(key), change);
  }
  for (const [name, changes] of groups) {
    const table = baseline.manifest.tables[name];
    const found = new Set();
    for await (const row of tableRows(root, name, table)) {
      const key = JSON.stringify(table.primaryKey.map(k => row[k]));
      const change = changes.get(key);
      if (!change) continue;
      if (!exact(row, change.before)) throw new Error(`Proposal preimage differs from baseline: ${name}:${key}`);
      found.add(key);
    }
    for (const [key, change] of changes) if (!found.has(key) && change.before !== null) throw new Error(`Proposal preimage is absent: ${name}:${key}`);
  }
  const paths = new Set();
  const knownQuestKeys=new Map();
  for(const file of Object.keys(baseline.manifest.files).filter(f=>f.startsWith('maintained/lua/')&&f.endsWith('.lua'))) {
    const key=scriptKey(file,await fs.readFile(await safeFile(root,file),'utf8'));
    if(knownQuestKeys.has(key)) throw new Error(`Duplicate maintained quest key: ${key}`);
    knownQuestKeys.set(key,file);
  }
  for (const source of proposal.sources) {
    const kind=sourceKind(source.target);
    if (paths.has(source.target)) throw new Error(`Duplicate source: ${source.target}`);
    paths.add(source.target);
    if ((baseline.manifest.files[source.target] ?? null) !== source.beforeSha256) throw new Error(`Source preimage differs from baseline: ${source.target}`);
    if (!source.proposedFile.startsWith('changes/')) throw new Error('Proposed source must live under changes/');
    source.content = await fs.readFile(await safeFile(root, source.proposedFile), 'utf8');
    if (hash(source.content) !== source.afterSha256) throw new Error(`Proposed source checksum mismatch: ${source.target}`);
    if (kind==='ledger') { validateLedger(source.target,source.content); continue; }
    const key = kind==='module' ? source.target.slice('maintained/modules/'.length,-4) : scriptKey(source.target, source.content);
    if(kind==='quest'&&knownQuestKeys.has(key)&&knownQuestKeys.get(key)!==source.target) throw new Error(`Quest key already has maintained source: ${key}`);
    if(kind==='quest') knownQuestKeys.set(key,source.target);
    const matching = proposal.rows.filter(c => c.table === (kind==='module'?'quest_lua_modules':'quests') && c.after &&
      (kind==='module'?c.after.module_name:`${c.after.zone}/${c.after.name}`) === key && c.after.lua_content === source.content);
    if (matching.length !== 1) throw new Error(`Source must match exactly one effective quest change: ${key}`);
    if (![0,1].includes(matching[0].after.enabled)||Boolean(matching[0].after.enabled)!==sourceEnabled(source.content)) throw new Error(`Enabled state must match source header: ${key}`);
    if (kind==='quest' && Boolean(matching[0].after.has_say_event)!==source.content.toLowerCase().includes('event_say')) throw new Error(`Dialogue metadata must match source: ${key}`);
  }
  for (const change of proposal.rows) {
    if (!['quests','quest_lua_modules'].includes(change.table)) continue;
    if (!change.after) throw new Error('Disable scripts/modules explicitly instead of deleting their provenance');
    const module=change.table==='quest_lua_modules';
    const key=module?change.after.module_name:`${change.after.zone}/${change.after.name}`;
    if (!proposal.sources.some(s=>sourceKind(s.target)===(module?'module':'quest') &&
      (module?s.target.slice('maintained/modules/'.length,-4):scriptKey(s.target,s.content))===key)) throw new Error(`Lua change requires maintained source: ${key}`);
  }
  return { ...baseline, proposal };
}

export async function applyProposal(root, file, config, { apply = false } = {}) {
  const { manifest, manifestHash, proposal } = await readProposal(root, file);
  const db = await mysql.createConnection(config);
  const result = { id: proposal.id, baseline: manifestHash, applied: apply, changed: 0, alreadyApplied: 0 };
  try {
    await db.beginTransaction();
    for (const name of new Set(proposal.rows.map(c => c.table))) {
      const [schema] = await db.query(`SHOW CREATE TABLE ${quote(name)}`);
      const expected = await fs.readFile(await safeFile(root, `schema/${name}.sql`), 'utf8');
      if (normalizeSchema(schema[0]['Create Table']) !== expected) throw new Error(`Schema drift: ${name}`);
    }
    for (const change of proposal.rows) {
      const table = manifest.tables[change.table];
      const where = table.primaryKey.map(k => `${quote(k)} <=> ?`).join(' AND ');
      const [rows] = await db.query(`SELECT ${table.columns.map(quote).join(',')} FROM ${quote(change.table)} WHERE ${where} FOR UPDATE`, change.key.map(decode));
      if (rows.length > 1) throw new Error('Key is not unique');
      const current = rows.length ? encodedRow(rows[0],table.columns) : null;
      if (exact(current, change.after)) { result.alreadyApplied++; continue; }
      if (!exact(current, change.before)) throw new Error(`Stale database row: ${change.table}:${JSON.stringify(change.key)}`);
      if (change.after === null) await db.query(`DELETE FROM ${quote(change.table)} WHERE ${where}`, change.key.map(decode));
      else if (change.before === null) await db.query(`INSERT INTO ${quote(change.table)} (${table.columns.map(quote).join(',')}) VALUES (${table.columns.map(()=>'?').join(',')})`, table.columns.map(c => decode(change.after[c])));
      else {
        const changed = table.columns.filter(c => !table.primaryKey.includes(c));
        await db.query(`UPDATE ${quote(change.table)} SET ${changed.map(c=>`${quote(c)}=?`).join(',')} WHERE ${where}`,
          [...changed.map(c=>decode(change.after[c])), ...change.key.map(decode)]);
      }
      result.changed++;
    }
    await checkChangedReferences(db, proposal.rows);
    // Preview exercises real constraints inside a rolled-back transaction.
    if (apply) await db.commit(); else await db.rollback();
    return result;
  } catch (error) { await db.rollback(); throw error; }
  finally { await db.end(); }
}
