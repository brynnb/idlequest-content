-- name: #Tunare
-- P99 call: https://wiki.project1999.com/Blue_Raid_Rules#Tunare
-- Exclusions/placement originate in upstream/projecteq/growthplane/#Tunare.lua.
-- IdleQuest delivers this as ordinary aggression, with normal pursuit, death,
-- ownership and disengagement. It does not teleport or resurrect the zone.
-- This replaces the source's signal -> NPC-follow chain (unsupported here).
local assistance = require("zone_assistance")
local excluded = {[127001]=true,[127004]=true,[127097]=true,[127098]=true,
  [127105]=true,[127005]=true,[127006]=true}
function event_combat(e)
  if e.joined then assistance.call(e.other, excluded) end
end
