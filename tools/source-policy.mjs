export const ledgerTargets = new Set([
  'reference/server/internal/quest/content_exclusions.json',
  'reference/server/internal/contentscope/npc_exclusions.json',
]);

export function sourceKind(target) {
  if (typeof target !== 'string' || target.split('/').some(p=>!p || p==='.' || p==='..') || target.includes('\\')) throw new Error('Unsafe source target');
  if (/^maintained\/lua\/(converted-perl|modified-upstream|idlequest-authored)\/[^/]+\/[^/]+\.lua$/.test(target)) return 'quest';
  if (/^maintained\/modules\/(?:[^/]+\/)*[^/]+\.lua$/.test(target)) return 'module';
  if (ledgerTargets.has(target)) return 'ledger';
  throw new Error(`Unsupported source target: ${target}`);
}

export function sourceDestination(target) {
  const kind = sourceKind(target);
  if (kind==='quest') return target.replace('maintained/lua/','server/internal/quest/overrides/lua/');
  if (kind==='module') return target.replace('maintained/modules/','server/internal/quest/overrides/modules/');
  return target.slice('reference/'.length);
}

export function sourceEnabled(source) {
  let enabled = true;
  for (const line of source.split('\n')) {
    const text = line.trim();
    if (text.startsWith('-- enabled:')) {
      const value=text.slice('-- enabled:'.length).trim();
      if (!['true','false'].includes(value)) throw new Error(`Invalid enabled header: ${text}`);
      enabled=value==='true';
    }
    if (text && !text.startsWith('--')) break;
  }
  return enabled;
}

export function validateLedger(target, source) {
  const value=JSON.parse(source);
  if (target.endsWith('npc_exclusions.json')) {
    const ids=new Set();
    for (const row of [...value.npcs, ...(value.inactive_npcs??[])]) {
      if (!Number.isSafeInteger(row.id)||row.id<=0||!row.name||typeof row.zone!=='string'||!row.reason||ids.has(row.id)) throw new Error('Invalid or duplicate NPC exclusion');
      ids.add(row.id);
    }
  } else {
    if (!value.quests || Array.isArray(value.quests)|| typeof value.quests!=='object') throw new Error('Invalid quest exclusion ledger');
    for (const [key, entry] of Object.entries(value.quests)) if (!key.includes('/')||!entry.reason) throw new Error(`Invalid quest exclusion: ${key}`);
  }
}
