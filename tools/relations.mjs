// Ordinary content links shared by proposal checks and the baseline audit.
// Zero/nonpositive IDs mean no linked record in these fields. Dynamic Lua
// references and composite zone/path-grid relationships need runtime review.
export const relations = [
  ['spawn2','spawngroupID','spawngroup','id'],
  ['spawnentry','spawngroupID','spawngroup','id'],
  ['spawnentry','npcID','npc_types','id'],
  ['spawn2_disabled','spawn2_id','spawn2','id'],
  ['npc_types','loottable_id','loottable','id'],
  ['npc_types','npc_spells_id','npc_spells','id'],
  ['npc_types','npc_spells_effects_id','npc_spells_effects','id'],
  ['npc_types','npc_faction_id','npc_faction','id'],
  ['loottable_entries','loottable_id','loottable','id'],
  ['loottable_entries','lootdrop_id','lootdrop','id'],
  ['lootdrop_entries','lootdrop_id','lootdrop','id'],
  ['lootdrop_entries','item_id','items','id'],
  ['merchantlist','item','items','id'],
  ['ground_spawns','item','items','id'],
  ['idlequest_enabled_ground_spawns','ground_spawn_id','ground_spawns','id'],
  ['tradeskill_recipe_entries','recipe_id','tradeskill_recipe','id'],
  ['tradeskill_recipe_entries','item_id','items','id'],
];

const quote = name => '`' + name.replaceAll('`','``') + '`';
export async function checkChangedReferences(db, changes) {
  for (const change of changes) {
    for (const [source, field, target, key] of relations) {
      if (change.table === source && change.after && Number(change.after[field]) > 0 &&
          (!change.before || change.before[field] !== change.after[field])) {
        const [found] = await db.query(`SELECT 1 FROM ${quote(target)} WHERE ${quote(key)}=? LIMIT 1`, [change.after[field]]);
        if (!found.length) throw new Error(`Missing reference: ${source}.${field}=${change.after[field]} -> ${target}.${key}`);
      }
      if (change.table === target && change.before && !change.after) {
        const [replacement] = await db.query(`SELECT 1 FROM ${quote(target)} WHERE ${quote(key)}=? LIMIT 1`, [change.before[key]]);
        if (replacement.length) continue;
        const [inbound] = await db.query(`SELECT 1 FROM ${quote(source)} WHERE ${quote(field)}=? LIMIT 1`, [change.before[key]]);
        if (inbound.length) throw new Error(`Referenced deletion: ${target}.${key}=${change.before[key]} still used by ${source}.${field}`);
      }
    }
  }
}

export async function auditReferences(db) {
  const issues = [];
  for (const [source, field, target, key] of relations) {
    const [missing] = await db.query(`SELECT s.${quote(field)} AS value, COUNT(*) AS affectedRows
      FROM ${quote(source)} s LEFT JOIN ${quote(target)} t ON t.${quote(key)}=s.${quote(field)}
      WHERE s.${quote(field)}>0 AND t.${quote(key)} IS NULL GROUP BY s.${quote(field)} ORDER BY s.${quote(field)}`);
    if (missing.length) issues.push({ source, field, target, key, missing });
  }
  return { scope: 'Declared static ID links only; not proof of dynamic Lua references, composite grids, era correctness or playable content.', issues };
}
