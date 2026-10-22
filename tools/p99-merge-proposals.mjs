import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

// Combine reviewed proposals without applying them or mutating the baseline.
// An overlapping key is only accepted when the entire before/after pair agrees.
export function mergeProposals(proposals, id = 'p99-combined-audit', tableKeys = {}) {
  if (!proposals.length) throw new Error('No proposals supplied');
  const manifest = proposals[0].baseManifestSha256;
  const rows = new Map(), sources = new Map(), evidence = new Map();
  const stable = value => JSON.stringify(value, (_, v) => v && typeof v === 'object' && !Array.isArray(v)
    ? Object.fromEntries(Object.entries(v).sort(([a],[b]) => a.localeCompare(b))) : v);
  const add = (map, key, value, label) => {
    if (map.has(key) && stable(map.get(key)) !== stable(value)) throw new Error(`Conflicting ${label}: ${key}`);
    map.set(key, value);
  };
  for (const proposal of proposals) {
    if (proposal.format !== 1 || proposal.baseManifestSha256 !== manifest) throw new Error(`Baseline mismatch: ${proposal.id}`);
    for (const row of proposal.rows) {
      const record = row.before ?? row.after;
      // These authored proposals use ID-keyed tables, except recipe components.
      // Unknown table keys must not silently collapse unrelated records.
      const keys = tableKeys[row.table] ?? { quests: ['id'], quest_lua_modules: ['module_name'], tradeskill_recipe: ['id'],
        tradeskill_recipe_entries: ['id'], items: ['id'], npc_types: ['id'], faction_list: ['id'],
        spawn2: ['id'], spawnentry: ['spawngroupID','npcID'], lootdrop_entries: ['lootdrop_id','item_id'],
        loottable_entries: ['loottable_id','lootdrop_id'] }[row.table];
      if (!keys || !keys.length || keys.some(key => !(key in record))) throw new Error(`Unsupported merge key: ${row.table}`);
      add(rows, `${row.table}:${stable(keys.map(key => record[key]))}`, row, 'row');
    }
    for (const source of proposal.sources) add(sources, source.target, source, 'source');
    for (const item of proposal.evidence) evidence.set(stable(item), item);
  }
  return { format: 1, id,
    summary: 'P99 evidence-backed Lua conversions and quest corrections; preserve immutable baseline and documented IdleQuest adaptations. See coverage and review records for unresolved scope and verification limits.',
    baseManifestSha256: manifest, evidence: [...evidence.values()],
    rows: [...rows.entries()].sort(([a],[b]) => a.localeCompare(b)).map(([,value]) => value),
    sources: [...sources.values()].sort((a,b) => a.target.localeCompare(b.target)) };
}

export async function findProposals(root, directory = 'changes') {
  const found = [];
  async function walk(relative) {
    for (const entry of await fs.readdir(path.join(root,relative), {withFileTypes:true})) {
      const filename = path.posix.join(relative,entry.name);
      if (entry.isDirectory()) await walk(filename);
      else if (entry.isFile() && entry.name.endsWith('.json')) {
        const value = JSON.parse(await fs.readFile(path.join(root,filename),'utf8'));
        if (value.format === 1 && value.id?.startsWith('p99-') && value.id !== 'p99-combined-audit') found.push({filename,value});
      }
    }
  }
  await walk(directory);
  return found.sort((a,b)=>a.filename.localeCompare(b.filename));
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const root = path.resolve(process.argv[2] ?? '.');
  const proposals = await findProposals(root);
  const schema = JSON.parse(await fs.readFile(path.join(root,'manifest.json'),'utf8'));
  const tableKeys = Object.fromEntries(Object.entries(schema.tables).map(([table,metadata])=>[table,metadata.primaryKey]));
  const combined = mergeProposals(proposals.map(p=>p.value),'p99-combined-audit',tableKeys);
  const output = 'changes/p99-combined-audit.json';
  await fs.writeFile(path.join(root,output), JSON.stringify(combined,null,2)+'\n');
  console.log(JSON.stringify({output,proposals:proposals.map(p=>p.filename),rows:combined.rows.length,sources:combined.sources.length},null,2));
}
