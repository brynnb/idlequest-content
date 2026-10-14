-- name: #_Tunare
-- P99: https://wiki.project1999.com/Tunare_(God)
-- Adapted from upstream/projecteq/growthplane/#_Tunare.lua.
-- The field actor owns the assistance call. Its ordinary combat-entry event
-- executes after it acquires the attacker; the disappearing tree cannot strand
-- the call's receipts or leave the field Tunare unengaged.
function event_combat(e)
  if e.joined then
    local tunare = eq.spawn2(127098, 0, 0, -247, 1609, -40, 424)
    tunare:AddToHateList(e.other, 1)
    eq.depop_with_timer()
  end
end
