import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';
import mysql from 'mysql2/promise';
import { parse } from 'dotenv';
import { tablePolicy } from './export-policy.mjs';

export const hash = value => createHash('sha256').update(value).digest('hex');
export const quote = name => '`' + name.replaceAll('`', '``') + '`';
export const decode = value => value && typeof value === 'object' && Object.keys(value).length === 1 && typeof value.$binary === 'string'
  ? Buffer.from(value.$binary, 'base64') : value;
export const encodedRow = (row, columns) => Object.fromEntries(columns.map(c => [c,
  Buffer.isBuffer(row[c]) ? { $binary: row[c].toString('base64') } : row[c]]));

export async function safeFile(root, relative) {
  if (!relative || path.isAbsolute(relative) || relative.split(/[\\/]/).some(p => !p || p === '.' || p === '..') || relative.includes('\\')) {
    throw new Error(`Unsafe dataset path: ${relative}`);
  }
  let file = root;
  for (const segment of relative.split('/')) {
    file = path.join(file, segment);
    if ((await fs.lstat(file)).isSymbolicLink()) throw new Error(`Dataset symlink: ${relative}`);
  }
  return file;
}

export async function readManifest(root) {
  const text = await fs.readFile(await safeFile(root, 'manifest.json'));
  const manifest = JSON.parse(text);
  if (manifest.format !== 1) throw new Error('Unsupported manifest format');
  const names = Object.keys(manifest.tables).sort();
  if (JSON.stringify(names) !== JSON.stringify(Object.keys(tablePolicy).sort())) throw new Error('Dataset table allowlist mismatch');
  for (const name of names) {
    const table = manifest.tables[name];
    const policy = tablePolicy[name];
    if (JSON.stringify(table.omittedColumns) !== JSON.stringify(policy.omit) || table.filter !== (policy.where ?? null)) throw new Error(`${name}: export policy mismatch`);
    if (!Array.isArray(table.columns) || new Set(table.columns).size !== table.columns.length || table.columns.some(c => typeof c !== 'string' || policy.omit.includes(c))) throw new Error(`${name}: invalid columns`);
    if (!Array.isArray(table.primaryKey) || table.primaryKey.some(k => !table.columns.includes(k))) throw new Error(`${name}: invalid primary key`);
    if (table.shards.some(f => !new RegExp(`^data/${name}/[0-9a-f]\\.ndjson$`).test(f)) || new Set(table.shards).size !== table.shards.length) throw new Error(`${name}: invalid shards`);
  }
  return { manifest, manifestHash: hash(text) };
}

export async function* tableRows(root, name, table) {
  for (const file of table.shards) {
    const text = await fs.readFile(await safeFile(root, file), 'utf8');
    const lines = text.split('\n');
    for (const [index, line] of lines.entries()) {
      if (!line && index === lines.length - 1) continue;
      let row;
      try { row = JSON.parse(line); } catch { throw new Error(`${file}:${index + 1}: malformed JSON`); }
      if (!row || Array.isArray(row) || JSON.stringify(Object.keys(row)) !== JSON.stringify(table.columns)) throw new Error(`${file}:${index + 1}: unexpected row columns`);
      yield row;
    }
  }
}

export async function validateDataset(root) {
  const { manifest, manifestHash } = await readManifest(root);
  for (const [file, expected] of Object.entries(manifest.files)) {
    const actual = hash(await fs.readFile(await safeFile(root, file)));
    if (actual !== expected) throw new Error(`Baseline checksum mismatch: ${file}. Author a change proposal; do not edit the baseline.`);
  }
  for (const [name, table] of Object.entries(manifest.tables)) {
    const keys = new Set();
    let count = 0;
    for (const file of [`schema/${name}.sql`, ...table.shards]) if (!manifest.files[file]) throw new Error(`Unhashed dataset file: ${file}`);
    for await (const row of tableRows(root, name, table)) {
      if (table.primaryKey.length) {
        const key = JSON.stringify(table.primaryKey.map(k => row[k]));
        if (keys.has(key)) throw new Error(`${name}: duplicate primary key ${key}`);
        keys.add(key);
      }
      count++;
    }
    if (count !== table.rows) throw new Error(`${name}: row count mismatch ${count} != ${table.rows}`);
  }
  return { manifest, manifestHash };
}

export async function localConfig(envFile, database) {
  const env = parse(await fs.readFile(envFile));
  if (!['127.0.0.1', 'localhost', '::1'].includes(env.DB_HOST)) throw new Error('Only local database connections are supported');
  return { host: env.DB_HOST, port: Number(env.DB_PORT || 3306), user: env.DB_USER,
    password: env.DB_PASS, database, dateStrings: true, supportBigNumbers: true, bigNumberStrings: true };
}

export async function loadScratch(root, config, database) {
  if (!/^idlequest_content_[a-z0-9_]+$/.test(database)) throw new Error('Scratch database name must begin idlequest_content_');
  const { manifest } = await validateDataset(root);
  const db = await mysql.createConnection({ ...config, database: undefined });
  try {
    // No IF NOT EXISTS: never write into an existing database by accident.
    await db.query(`CREATE DATABASE ${quote(database)} CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`);
    await db.query(`USE ${quote(database)}`);
    for (const [name, table] of Object.entries(manifest.tables)) {
      const schema = await fs.readFile(await safeFile(root, `schema/${name}.sql`), 'utf8');
      if (!schema.startsWith(`CREATE TABLE ${quote(name)} (`)) throw new Error(`${name}: unexpected schema statement`);
      await db.query(schema);
      await db.beginTransaction();
      let batch = [];
      const flush = async () => {
        if (!batch.length) return;
        await db.query(`INSERT INTO ${quote(name)} (${table.columns.map(quote).join(',')}) VALUES ?`, [batch]);
        batch = [];
      };
      for await (const row of tableRows(root, name, table)) {
        batch.push(table.columns.map(c => decode(row[c])));
        if (batch.length === 100) await flush();
      }
      await flush();
      await db.commit();
      console.log(`Loaded ${name}: ${table.rows}`);
    }
  } catch (error) {
    await db.rollback();
    // Preserve a failed scratch database for diagnosis; never drop by inference.
    throw error;
  } finally { await db.end(); }
}

export async function verifyDatabase(root, config) {
  const { manifest } = await validateDataset(root);
  const db = await mysql.createConnection(config);
  try {
    for (const [name, table] of Object.entries(manifest.tables)) {
      const expected = [];
      for await (const row of tableRows(root, name, table)) expected.push(JSON.stringify(row));
      const [rows] = await db.query(`SELECT ${table.columns.map(quote).join(',')} FROM ${quote(name)}`);
      const actual = rows.map(row => JSON.stringify(encodedRow(row, table.columns))).sort();
      if (hash(actual.join('\n')) !== hash(expected.sort().join('\n'))) throw new Error(`${name}: scratch round-trip mismatch`);
      console.log(`Verified ${name}: ${rows.length}`);
    }
  } finally { await db.end(); }
}
