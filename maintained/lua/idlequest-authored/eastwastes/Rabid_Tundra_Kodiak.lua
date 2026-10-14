-- P99 Coldain Ring Quests: the bear attacks Boridain at the final hunt stop.
-- Use the existing concrete NPC hate/retaliation executor. Ordinary ambient
-- NPC-faction aggression is not implemented yet; this scripted opponent is
-- scoped to the hunt's personal Boridain, not a player-target approximation.
function event_spawn(e)
  eq.attack_npc_type(116191)
end
