import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';

const read = p => JSON.parse(fs.readFileSync(p, 'utf8'));
const hash = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const table = t => fs.readdirSync(`data/${t}`).filter(p => p.endsWith('.ndjson'))
  .flatMap(p => fs.readFileSync(`data/${t}/${p}`, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse));
const review = read('changes/p99-sky-timer-review/review.json');
const proposal = read('changes/p99-sky-starter-respawn.json');
// Hand-reviewed identities, not derived from the proposal under test.
const expected = [
  [71037, 'Dason_Goldblade', 2087, 2679, 10800],
  [71042, 'Cilin_Spellsinger', 2091, 2687, 10800],
  [71043, 'Strandar_Pinemist', 5473, 2688, 10800],
  [71044, 'Medicine_Man_Veetra', 5474, 2689, 10800],
  [71045, 'Torgon_Blademaster', 5475, 2690, 10800],
  [71046, 'Holwin', 5476, 2691, 10800],
  [71047, 'Wizard_Schrock', 5477, 2692, 10800],
  [71048, 'Sarkis_Ebonblade', 5478, 2693, 10800],
  [71049, 'Enchanter_Jolas', 5479, 2694, 10800],
  [71050, 'Magus_Frinon', 5480, 2695, 10800],
  [71051, 'Thalik_Silenthand', 5481, 2696, 10800],
  [71052, 'Josin_Faithbringer', 5482, 2697, 28800],
  [71053, 'Drakis_Bloodcaster', 5483, 2698, 10800],
  [71054, 'Ranger_Spirit', 5484, 2699, 10800],
];

test('all fourteen class starters have exactly one timer-only correction with complete baseline preimages', () => {
  const spawns = new Map(table('spawn2').map(r => [r.id, r]));
  assert.equal(proposal.format, 1);
  assert.equal(proposal.baseManifestSha256, hash('manifest.json'));
  assert.equal(proposal.rows.length, 14);
  assert.deepEqual(proposal.sources, []);
  assert.deepEqual(proposal.rows.map(r => r.before.id).sort((a, b) => a - b), expected.map(r => r[3]));
  for (const [npc, name, group, id, seconds] of expected) {
    const change = proposal.rows.find(r => r.before.id === id);
    assert.equal(change.table, 'spawn2');
    assert.deepEqual(change.before, spawns.get(id));
    assert.deepEqual(change.after, {...change.before, respawntime: seconds});
    assert.equal(change.before.zone, 'airplane');
    assert.equal(change.before.spawngroupID, group);
    assert.equal(change.before.respawntime, 640);
    assert.equal(change.after.variance, 0);
    const record = review.starters.find(r => r.npcId === npc);
    assert.equal(record.npcName, name);
    assert.equal(record.spawn2Id, id);
    assert.equal(record.proposedRespawnSeconds, seconds);
  }
});

test('exact NPC/group identities are dedicated static starters, never spawned testers or other room NPCs', () => {
  const entries = table('spawnentry');
  const groups = new Map(table('spawngroup').map(r => [r.id, r]));
  const npcs = new Map(table('npc_types').map(r => [r.id, r]));
  const spawns = table('spawn2');
  assert.equal(review.starters.length, 14);
  assert.equal(review.starters.flatMap(r => r.testerNpcs).length, 28);
  for (const [npc, name, group, spawn] of expected) {
    const record = review.starters.find(r => r.npcId === npc);
    assert.equal(npcs.get(npc).name, name);
    assert.deepEqual(entries.filter(e => e.npcID === npc), [record.spawnEntry]);
    assert.deepEqual(entries.filter(e => e.spawngroupID === group), [record.spawnEntry]);
    assert.equal(record.spawnEntry.chance, 100);
    assert.deepEqual(groups.get(group), record.spawnGroup);
    assert.deepEqual(spawns.filter(s => s.spawngroupID === group).map(s => s.id), [spawn]);
    for (const tester of record.testerNpcs) {
      assert.ok(!expected.some(e => e[0] === tester.npcId));
      assert.deepEqual(entries.filter(e => e.npcID === tester.npcId), tester.staticSpawnEntries);
      assert.equal(tester.staticSpawnEntries.length, 0);
    }
  }
});

test('verified cached sources preserve the general three-hour claim and exact Josin eight-hour exception', () => {
  for (const e of review.evidence) assert.equal(hash(e.cachePath), e.sha256, e.title);
  const old = fs.readFileSync(review.broadEvidence.cachePath, 'utf8');
  assert.match(old, /Quest mobs have a 3 hour respawn time/);
  assert.equal((old.match(/<h2> \[\[/g) ?? []).length, 14);
  const josin = fs.readFileSync(review.specificConflict.source.cachePath, 'utf8');
  assert.match(josin, /emu_id\s*=\s*71052/);
  assert.match(josin, /sky quest NPC that summons one of two turn-in NPC/);
  assert.match(josin, /respawn time is 8 hours/);
  assert.equal(review.specificConflict.spawn2Id, 2697);
  assert.equal(review.specificConflict.selectedRespawnSeconds, 28800);
  assert.equal(review.historicalSourceLimit.ledgerEntry.match_status, 'historical_reference_not_current_p99_target');
  for (const r of review.starters) {
    const text = fs.readFileSync(r.classEvidence.cachePath, 'utf8');
    assert.doesNotMatch(text, /respawn|\b\d+\s*hours?/i, r.class);
  }
});

test('starter shortcuts, tester lifetimes, policy and all baseline sources remain unchanged', () => {
  const questPolicy = read('reference/server/internal/quest/content_exclusions.json');
  const npcPolicy = read('reference/server/internal/contentscope/npc_exclusions.json');
  const qi = new Map(read('reference/effective-quests-index.json').map(q => [q.key, q]));
  for (const p of review.policySources) assert.equal(hash(p.file), p.sha256, p.file);
  for (const r of review.starters) {
    assert.equal(hash(r.sourceFile), r.sourceSha256);
    const code = fs.readFileSync(r.sourceFile, 'utf8');
    assert.equal((code.match(/eq\.depop_with_timer\(\)/g) ?? []).length, 2);
    assert.equal(qi.get(r.questKey).enabled, 1);
    assert.ok(!questPolicy.quests[r.questKey]);
    assert.ok(!npcPolicy.npcs.some(n => n.id === r.npcId));
    assert.ok(!npcPolicy.name_patterns.some(p => new RegExp(p.pattern).test(r.npcName)));
    for (const t of r.testerNpcs) {
      assert.equal(hash(t.sourceFile), t.sourceSha256);
      assert.deepEqual(t.scriptTimers, [{name: 'depop', durationMilliseconds: 300000}], t.questKey);
    }
  }
  const fiery = review.evidence.find(e => e.title === 'The Fiery Avenger');
  assert.match(fs.readFileSync(fiery.cachePath, 'utf8'), /he will depop after FIVE minutes/);
});

test('the proposal cannot overlap an existing independently authored airplane spawn correction', () => {
  const proposedIds = new Set(expected.map(e => e[3]));
  const walk = p => fs.readdirSync(p, {withFileTypes: true}).flatMap(d => d.isDirectory() ? walk(`${p}/${d.name}`) : [`${p}/${d.name}`]);
  for (const file of walk('changes').filter(p => p.endsWith('.json') && p !== 'changes/p99-sky-starter-respawn.json')) {
    let value;
    try { value = read(file); } catch { continue; }
    if (value?.format !== 1 || value.id === 'p99-combined-audit') continue;
    for (const row of value.rows ?? []) {
      if (row.table === 'spawn2') assert.ok(!proposedIds.has((row.before ?? row.after).id), file);
    }
  }
});
