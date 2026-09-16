// An explicit allowlist: never discover exportable tables by name patterns.
// Full reference data is retained, including disabled/later-era definitions.
// Exported does not mean enabled or approved for Classic–Velious gameplay.
export const tablePolicy = Object.fromEntries([
  'zone', 'zone_points', 'spawn2', 'spawngroup', 'spawnentry', 'grid', 'grid_entries',
  'spawn_conditions', 'content_flags', 'npc_types', 'npc_types_tint',
  'npc_spells', 'npc_spells_entries', 'npc_spells_effects', 'npc_spells_effects_entries',
  'npc_faction', 'npc_faction_entries', 'npc_emotes', 'faction_list', 'faction_list_mod',
  'faction_base_data', 'faction_association', 'loottable', 'loottable_entries',
  'lootdrop', 'lootdrop_entries', 'global_loot', 'items', 'spells_new', 'ground_spawns',
  'idlequest_enabled_ground_spawns', 'merchantlist', 'tradeskill_recipe',
  'tradeskill_recipe_entries', 'doors', 'quests', 'start_zones', 'starting_items',
  'npc_zone_weights', 'npc_farming_categories', 'npc_farming_category_items',
  'farming_category_items', 'farming_zone_recommendations', 'crafting_merchant_items',
  'books', 'traps', 'pets', 'pets_equipmentset', 'pets_equipmentset_entries',
].map(name => [name, { omit: [] }]));
tablePolicy.quest_lua_modules = { omit: ['created_at', 'updated_at'] };
tablePolicy.spawn_events = { omit: ['next_minute', 'next_hour', 'next_day', 'next_month', 'next_year'] };
// Type 1 is a player-dropped item. Only static authored objects are reference data.
tablePolicy.object = { omit: [], where: '`type` <> 1' };
// Only migration-authored baseline exclusions; instance_id=0 alone is not proof.
tablePolicy.spawn2_disabled = { omit: [], where: `instance_id = 0 AND EXISTS (
  SELECT 1 FROM spawn2 s JOIN spawnentry e ON e.spawngroupID=s.spawngroupID
  JOIN npc_types n ON n.id=e.npcID WHERE s.id=spawn2_disabled.spawn2_id AND (
    (s.zone='karnor' AND n.id=102112 AND n.name='#Venril_Sathir') OR
    (s.zone='freportw' AND n.id=9150 AND n.name='Phineas_Taylor') OR
    (s.id=7386 AND s.zone='mistmoore' AND s.spawngroupID=6864 AND n.id=59129 AND n.name='Black_Dire')
  ))`, provenance: ['069_disable_static_karnor_venril_for_epic_remains.sql', '125_disable_post_luclin_phineas_taylor.sql', '141_restore_black_dire_death_trigger.sql'] };

export const exclusions = {
  spawn2_disabled: 'Export only records matching reviewed migrations 069, 125 and 141. Other records are omitted as unexplained runtime state.',
  object_contents: 'Live container contents, potentially deposited by players.',
  spawn_condition_values: 'Live per-instance condition values.',
  respawn_times: 'Live respawn timers.',
  merchantlist_temp: 'Player-sold inventory.',
  quest_globals: 'Player or live world quest progress.',
  'quest_runtime_*': 'Live state, spawns, overrides, ground items, timers and triggers.',
  'quest_actor_*': 'Live actor state.',
  quest_effect_outbox: 'Live delivery queue.',
  quest_turnin_transactions: 'Player transactions.',
  '*not explicitly allowlisted*': 'Excluded by default, including accounts, characters, logs and credentials.',
};

export const sourceTrees = {
  'server/internal/quest/upstream/projecteq': 'sources/projecteq',
  'server/internal/quest/overrides/lua': 'maintained/lua',
  'server/internal/quest/overrides/modules': 'maintained/modules',
};
export const referenceFiles = [
  'docs/local-content-updates.md',
  'docs/p99-quest-audit-workflow.md', 'docs/quest-system-roadmap.md',
  'docs/quest-audit-review-notes.md', 'docs/quest-ui-verification-status.md',
  'server/internal/quest/content_exclusions.json',
  'server/internal/quest/deferred_runtime_apis.json',
  'server/internal/quest/classic_kunark_zones.json',
  'server/internal/contentscope/npc_exclusions.json',
  'server/internal/quest/runtime_capabilities.go',
  'server/internal/quest/faction_policy.go',
  'server/internal/quest/service.go',
  'server/internal/quest/overrides/overrides.go',
  'server/cmd/import-quests/main.go',
];
