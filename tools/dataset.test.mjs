import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { hash, validateDataset, readManifest, safeFile, loadScratch } from './dataset.mjs';
import { tablePolicy } from './export-policy.mjs';

import { fixture } from './test-fixture.mjs';

test('valid baseline verifies; private tables cannot be admitted by a changed manifest', async t => {
  const f = await fixture(t);
  await validateDataset(f.root);
  f.manifest.tables.character_data = f.manifest.tables.zone;
  await f.save();
  await assert.rejects(readManifest(f.root), /allowlist mismatch/);
});

test('row integrity catches corruption, malformed rows, duplicate keys and wrong counts', async t => {
  const f = await fixture(t);
  const file = 'data/zone/0.ndjson';
  f.manifest.tables.zone.shards = [file];
  f.manifest.tables.zone.rows = 1;
  await f.write(file, '{"id":1}\n'); await f.save();
  await validateDataset(f.root);
  await fs.appendFile(path.join(f.root, file), 'x');
  await assert.rejects(validateDataset(f.root), /checksum mismatch/);
  await f.write(file, '{\n'); await f.save();
  await assert.rejects(validateDataset(f.root), /malformed JSON/);
  await f.write(file, '{"id":1,"private":"unexpected"}\n'); await f.save();
  await assert.rejects(validateDataset(f.root), /unexpected row columns/);
  await f.write(file, '{"id":1}\n{"id":1}\n'); await f.save();
  await assert.rejects(validateDataset(f.root), /duplicate primary key/);
  await f.write(file, '{"id":1}\n{"id":2}\n'); await f.save();
  await assert.rejects(validateDataset(f.root), /row count mismatch/);
});

test('loader refuses ordinary database names before connecting; path traversal and symlinks fail', async t => {
  const f = await fixture(t);
  await assert.rejects(loadScratch(f.root, {}, 'eqgo'), /Scratch database name/);
  await assert.rejects(safeFile(f.root, '../.env'), /Unsafe dataset path/);
  await fs.symlink('/etc/passwd', path.join(f.root,'external'));
  await assert.rejects(safeFile(f.root, 'external'), /Dataset symlink/);
});

test('metadata cannot reintroduce omitted clock columns or unverified shard paths', async t => {
  const f = await fixture(t);
  f.manifest.tables.spawn_events.columns.push('next_minute'); await f.save();
  await assert.rejects(readManifest(f.root), /invalid columns/);
  f.manifest.tables.spawn_events.columns.pop();
  f.manifest.tables.zone.shards = ['data/items/0.ndjson']; await f.save();
  await assert.rejects(readManifest(f.root), /invalid shards/);
});
