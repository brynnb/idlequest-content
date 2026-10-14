-- Scoped assistance using ordinary NPC hate and movement. The world enumerator
-- includes only living, visible actors in the initiating player's instance.
local M = {}
function M.call(attacker, excluded, included)
  -- Empty combat lookups are null NPC proxies; players do not expose .valid.
  if not attacker or attacker.null == true then return end
  for npc in eq.get_entity_list():GetNPCList().entries do
    -- Already engaged actors retain their current fight and ownership. Repeated
    -- calls do not add hate again or redirect another player's encounter.
    if npc.valid and not excluded[npc:GetNPCTypeID()] and
      (not included or included[npc:GetNPCTypeID()]) and not npc:IsCombatReserved() then
      npc:AddToHateList(attacker, 1)
    end
  end
end
return M
