import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';
import mysql from 'mysql2/promise';
import { parse } from 'dotenv';
import { tablePolicy, exclusions, sourceTrees, referenceFiles } from './export-policy.mjs';
import { buildSourceLookup, exportEffectiveScripts, exportWikiIndex } from './source-audit.mjs';

export const hash = value => createHash('sha256').update(value).digest('hex');
export const quote = name => '`' + name.replaceAll('`', '``') + '`';
export const stableJSON = value => JSON.stringify(value, null, 2) + '\n';
export function canonicalRow(row, columns) {
  return Object.fromEntries(columns.map(c => [c, Buffer.isBuffer(row[c])
    ? { $binary: row[c].toString('base64') } : row[c]]));
}
export function normalizeSchema(sql) {
  // Sequence counters are live allocation state, not part of the schema.
  return sql.replace(/ AUTO_INCREMENT=\d+/g, '') + ';\n';
}

export function partitionRows(rows, columns, primaryKey) {
  const shards = new Map();
  for (const raw of rows) {
    const row = canonicalRow(raw, columns);
    // Fixed key-hash partitions avoid shifting every later file after one edit.
    const key = JSON.stringify(primaryKey.length ? primaryKey.map(k => row[k]) : row);
    const shard = hash(key).slice(0, 1);
    if (!shards.has(shard)) shards.set(shard, []);
    shards.get(shard).push(JSON.stringify(row));
  }
  return [...shards].sort(([a],[b]) => a.localeCompare(b)).map(([shard, lines]) => [shard, lines.sort().join('\n') + '\n']);
}

async function walk(root) {
  const result = [];
  for (const entry of (await fs.readdir(root, { withFileTypes: true })).sort((a,b) => a.name.localeCompare(b.name, 'en'))) {
    if (entry.name === '.git') continue;
    const file = path.join(root, entry.name);
    if (entry.isSymbolicLink()) throw new Error(`Source symlink requires explicit review: ${file}`);
    if (entry.isDirectory()) result.push(...await walk(file));
    else if (entry.isFile()) result.push(file);
  }
  return result;
}

export async function exportContent({ repo, output, config }) {
  // Refuse overwriting a previous export, especially a volunteer worktree.
  await fs.mkdir(output, { recursive: false });
  const files = {};
  const write = async (relative, content) => {
    const file = path.join(output, relative);
    await fs.mkdir(path.dirname(file), { recursive: true });
    await fs.writeFile(file, content);
    files[relative] = hash(content);
  };
  const sourceIndex = [];
  for (const [source, destination] of Object.entries(sourceTrees)) {
    for (const file of await walk(path.join(repo, source))) {
      const relative = path.relative(path.join(repo, source), file).split(path.sep).join('/');
      const content = await fs.readFile(file);
      const exported = `${destination}/${relative}`;
      await write(exported, content);
      sourceIndex.push({ source: `${source}/${relative}`, exported, sha256: hash(content) });
    }
  }
  for (const relative of referenceFiles) await write(`reference/${relative}`, await fs.readFile(path.join(repo, relative)));
  // These are source/API/test reference, not a second executable runtime fork.
  for (const directory of ['server/internal/quest', 'server/internal/quest/overrides', 'server/internal/questluasource', 'server/cmd/import-quests', 'server/cmd/check-content-lua']) {
    for (const entry of await fs.readdir(path.join(repo, directory), { withFileTypes: true })) {
      if (entry.isFile() && entry.name.endsWith('.go')) {
        const relative = `${directory}/${entry.name}`;
        await write(`reference/${relative}`, await fs.readFile(path.join(repo, relative)));
      }
    }
  }
  await exportWikiIndex(repo, write);
  const sourceLookup = await buildSourceLookup(output, sourceIndex);
  const tables = {};
  const db = await mysql.createConnection({ ...config, dateStrings: true, supportBigNumbers: true, bigNumberStrings: true });
  try {
    // A single consistent read view prevents cross-table snapshots across commits.
    // Reject nontransactional tables instead of claiming snapshot consistency.
    await db.query('SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ');
    await db.query('START TRANSACTION WITH CONSISTENT SNAPSHOT, READ ONLY');
    for (const name of Object.keys(tablePolicy).sort()) {
      const policy = tablePolicy[name];
      const [status] = await db.query('SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?', [name]);
      if (status[0]?.ENGINE !== 'InnoDB') throw new Error(`${name}: expected an existing InnoDB table`);
      const [fields] = await db.query(`SHOW COLUMNS FROM ${quote(name)}`);
      const columns = fields.map(f => f.Field).filter(c => !policy.omit.includes(c));
      for (const c of policy.omit) if (!fields.some(f => f.Field === c)) throw new Error(`${name}: missing expected omitted column ${c}`);
      const [schema] = await db.query(`SHOW CREATE TABLE ${quote(name)}`);
      const [rows] = await db.query(`SELECT ${columns.map(quote).join(',')} FROM ${quote(name)}${policy.where ? ` WHERE ${policy.where}` : ''}`);
      if (name === 'quests' || name === 'quest_lua_modules') await exportEffectiveScripts(rows, sourceLookup, write, name === 'quest_lua_modules');
      await write(`schema/${name}.sql`, normalizeSchema(schema[0]['Create Table']));
      const [indexes] = await db.query(`SHOW INDEX FROM ${quote(name)}`);
      const primaryKey = indexes.filter(i => i.Key_name === 'PRIMARY').sort((a,b) => a.Seq_in_index-b.Seq_in_index).map(i => i.Column_name);
      const shards = [];
      for (const [shard, text] of partitionRows(rows, columns, primaryKey)) {
        const file = `data/${name}/${shard}.ndjson`;
        await write(file, text);
        shards.push(file);
      }
      const [counts] = await db.query(`SELECT COUNT(*) n FROM ${quote(name)}`);
      tables[name] = { rows: rows.length, sourceRows: Number(counts[0].n), shards, columns, primaryKey, omittedColumns: policy.omit, filter: policy.where ?? null, provenance: policy.provenance ?? [] };
      console.log(`${name}: ${rows.length} rows`);
    }
    await db.rollback();
  } finally { await db.end(); }
  await write('reference/export-exclusions.json', stableJSON(exclusions));
  await write('reference/source-index.json', stableJSON(sourceIndex));
  const sourceCommit = execFileSync('git', ['rev-parse', 'HEAD'], { cwd: repo, encoding: 'utf8' }).trim();
  // Per-file hashes, rather than a HEAD claim, capture dirty/untracked inputs.
  const manifest = { format: 1, sourceCommit, database: 'local-development-content',
    scope: 'Complete reference corpus; not all records are approved or enabled for Classic–Velious.',
    tables, files: Object.fromEntries(Object.entries(files).sort(([a],[b]) => a.localeCompare(b, 'en'))) };
  await fs.writeFile(path.join(output, 'manifest.json'), stableJSON(manifest));
  console.log(`Export complete: ${Object.keys(tables).length} tables, ${Object.keys(files).length} files`);
  return manifest;
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const output = process.argv[2];
  if (!output) throw new Error('Usage: node scripts/content/export.mjs /absolute/new-output-directory');
  const repo = process.cwd();
  const env = parse(await fs.readFile(path.join(repo, '.env')));
  if (!['localhost', '127.0.0.1', '::1'].includes(env.DB_HOST)) throw new Error('Exporter requires a local database; remote access is intentionally unsupported');
  await exportContent({ repo, output: path.resolve(output), config: {
    host: env.DB_HOST, port: Number(env.DB_PORT || 3306), user: env.DB_USER, password: env.DB_PASS, database: env.DB_NAME,
  } });
}
