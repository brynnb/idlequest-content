import test from 'node:test';
import assert from 'node:assert/strict';
import { canonicalRow, normalizeSchema, quote, partitionRows } from './export.mjs';
import { tablePolicy } from './export-policy.mjs';

test('allowlist excludes private state and live scheduling fields', () => {
  for (const table of ['account', 'character_data', 'inventory', 'quest_globals',
    'object_contents', 'merchantlist_temp', 'respawn_times',
    'quest_runtime_spawns', 'quest_turnin_transactions']) assert.equal(tablePolicy[table], undefined);
  assert.deepEqual(tablePolicy.quest_lua_modules.omit, ['created_at', 'updated_at']);
  assert.deepEqual(tablePolicy.spawn_events.omit, ['next_minute', 'next_hour', 'next_day', 'next_month', 'next_year']);
  assert.equal(tablePolicy.spawn2_disabled.provenance.length, 3);
});

test('shards are deterministic across row order and retain duplicate keyless rows', () => {
  const rows = [{ id: 2, name: 'b' }, { id: 1, name: 'a' }];
  assert.deepEqual(partitionRows(rows, ['id','name'], ['id']), partitionRows([...rows].reverse(), ['id','name'], ['id']));
  assert.equal(partitionRows([rows[0], rows[0]], ['id','name'], [])[0][1].trim().split('\n').length, 2);
});

test('canonical rows preserve binary, null, text and large IDs without leaking omitted fields', () => {
  const row = { id: '9007199254740993', script: 'x\n雪', missing: null, blob: Buffer.from([0, 255]), secret: 'do not export' };
  const result = canonicalRow(row, ['id', 'script', 'missing', 'blob']);
  assert.deepEqual(result, { id: '9007199254740993', script: 'x\n雪', missing: null, blob: { $binary: 'AP8=' } });
  assert.equal(JSON.stringify(result).includes('secret'), false);
});

test('schema normalization removes only the live allocation counter', () => {
  assert.equal(normalizeSchema('CREATE TABLE `x` (`id` int AUTO_INCREMENT) ENGINE=InnoDB AUTO_INCREMENT=22'),
    'CREATE TABLE `x` (`id` int AUTO_INCREMENT) ENGINE=InnoDB;\n');
  assert.equal(quote('odd`name'), '`odd``name`');
});
