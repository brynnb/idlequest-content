import fs from 'node:fs/promises';
import path from 'node:path';
import { hash } from './dataset.mjs';
import { tablePolicy } from './export-policy.mjs';

export async function fixture(t) {
  const root = await fs.mkdtemp('/var/tmp/idlequest-content-validator-');
  t.after(() => fs.rm(root, { recursive: true, force: true }));
  const manifest = { format: 1, files: {}, tables: {} };
  const write = async (file, text) => {
    await fs.mkdir(path.dirname(path.join(root,file)), { recursive: true });
    await fs.writeFile(path.join(root,file), text);
    manifest.files[file] = hash(text);
  };
  for (const [name, policy] of Object.entries(tablePolicy)) {
    manifest.tables[name] = { rows: 0, shards: [], columns: ['id'], primaryKey: ['id'], omittedColumns: policy.omit, filter: policy.where ?? null };
    await write(`schema/${name}.sql`, `CREATE TABLE \`${name}\` (\`id\` int PRIMARY KEY);\n`);
  }
  const save = () => fs.writeFile(path.join(root,'manifest.json'), JSON.stringify(manifest));
  await save();
  return { root, manifest, write, save };
}
