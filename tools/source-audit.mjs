import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';

const hash = text => createHash('sha256').update(text).digest('hex');
const segment = text => encodeURIComponent(String(text)).replaceAll('.', '%2E');

export function scriptKey(file, lua) {
  const parts = file.split('/');
  const name = path.basename(file, '.lua');
  let explicit = name;
  for (const line of lua.split(/\r?\n/)) {
    const text = line.trim();
    if (text.startsWith('-- name:')) { explicit = text.slice(8).trim() || name; break; }
    if (text && !text.startsWith('--')) break;
  }
  return `${parts.at(-2)}/${explicit}`;
}

export async function buildSourceLookup(output, sourceIndex) {
  const lookup = new Map();
  for (const entry of sourceIndex) {
    if (!entry.exported.endsWith('.lua')) continue;
    const parts = entry.exported.split('/');
    if(entry.exported.startsWith('sources/projecteq/lua_modules/')) {
      lookup.set(`module:${parts.slice(3).join('/').slice(0,-4)}`,[{file:entry.exported,sha256:entry.sha256,maintained:false}]);
      continue;
    }
    if (entry.exported.startsWith('maintained/modules/')) {
      lookup.set(`module:${parts.slice(2).join('/').slice(0,-4)}`, [{ file:entry.exported,sha256:entry.sha256,maintained:true }]);
      continue;
    }
    const maintained = parts[0] === 'maintained';
    // Same one-zone/one-file layout the importer uses; modules handled separately.
    if (maintained ? parts.length !== 5 : parts.length !== 4) continue;
    if (!maintained && parts[2] === 'plugins') continue;
    const lua = await fs.readFile(path.join(output, entry.exported), 'utf8');
    const key = maintained ? scriptKey(entry.exported, lua) : `${parts[2]}/${path.basename(entry.exported, '.lua')}`;
    if (!lookup.has(key)) lookup.set(key, []);
    lookup.get(key).push({ file: entry.exported, sha256: entry.sha256, maintained });
  }
  return lookup;
}

export async function exportEffectiveScripts(rows, lookup, write, modules = false) {
  const index = [];
  for (const row of rows) {
    const key = modules ? row.module_name : `${row.zone}/${row.name}`;
    const lua = row.lua_content ?? '';
    const file = modules ? `effective/modules/${segment(key)}.lua`
      : `effective/quests/${segment(row.zone)}/${segment(row.name)}.lua`;
    await write(file, lua);
    const candidates = lookup.get(modules ? `module:${key}` : key) ?? [];
    const maintained = candidates.filter(c => c.maintained);
    if (maintained.length > 1) throw new Error(`Duplicate maintained source key: ${key}`);
    const preferred = maintained[0] ?? candidates[0] ?? null;
    index.push({ key, id: row.id ?? null, enabled: row.enabled, file, sha256: hash(lua),
      preferredSource: preferred?.file ?? null, candidates,
      sourceStatus: preferred ? preferred.sha256 === hash(lua) ? 'matches-source' : 'database-differs' : lua ? 'database-only' : 'no-lua-body',
    });
  }
  index.sort((a,b) => a.key.localeCompare(b.key, 'en'));
  await write(`reference/effective-${modules ? 'modules' : 'quests'}-index.json`, JSON.stringify(index, null, 2) + '\n');
  return index;
}

export function portableWikiState(bytes) {
  const state = JSON.parse(bytes);
  for (const page of Object.values(state.pages ?? {})) {
    for (const field of ['rawPath', 'metaPath']) {
      if (page[field] === undefined) continue;
      const match = String(page[field]).match(/(?:^|\/)((?:raw-pages|npc-pages)\/[^/]+\.(?:wiki|json))$/);
      if (!match) throw new Error(`Unrecognized wiki state ${field}; refusing to publish a machine path`);
      page[field] = match[1];
    }
  }
  return JSON.stringify(state, null, 2) + '\n';
}

export async function exportWikiIndex(repo, write) {
  const root = path.join(repo, 'data/p99wiki-project1999-api-cache');
  // Preserve the scraped bytes and metadata; no network access is needed.
  // Resume paths are relative to the exported cache, never to a private checkout.
  async function copy(directory = '') {
    for (const entry of (await fs.readdir(path.join(root, directory), { withFileTypes: true })).sort((a,b)=>a.name.localeCompare(b.name))) {
      const relative = path.posix.join(directory, entry.name);
      if (entry.isDirectory()) await copy(relative);
      else if (entry.isFile()) {
        const bytes = await fs.readFile(path.join(root, relative));
        await write(`reference/p99-wiki/${relative}`, ['raw-pages-state.json', 'npc-pages-state.json'].includes(relative) ? portableWikiState(bytes) : bytes);
      }
      else throw new Error(`Unexpected wiki cache entry: ${relative}`);
    }
  }
  await copy();
  const entries = [];
  for (const directory of ['raw-pages', 'npc-pages']) {
    for (const file of (await fs.readdir(path.join(root, directory))).sort()) {
      if (!file.endsWith('.json')) continue;
      const meta = JSON.parse(await fs.readFile(path.join(root, directory, file), 'utf8'));
      if (!meta.title || !meta.url || !meta.sha256) continue;
      const page = `${directory}/${file.replace(/\.json$/, '.wiki')}`;
      const bytes = await fs.readFile(path.join(root, page));
      if (hash(bytes) !== meta.sha256) throw new Error(`Wiki cache hash mismatch: ${page}`);
      entries.push({ title: meta.title, url: meta.url, fetchedAt: meta.fetchedAt ?? null,
        revision: meta.revid ?? meta.revisionId ?? null, sha256: meta.sha256,
        bytes: meta.bytes ?? null, source: `${directory}/${file}`,
        cachePath: `reference/p99-wiki/${page}` });
    }
  }
  await write('reference/p99-evidence-index.json', JSON.stringify(entries, null, 2) + '\n');
}
