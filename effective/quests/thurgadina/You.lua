-- P99 Coldain Prayer Shawl #7: untargeted prayer near the chapel altar creates
-- a ground pattern. Sources/provenance: docs/coldain-quest-chains.md.
-- Original You.pl sha256: 327c93b1c65ffcc854e33b3768e28e571573dcae378b96912c826dfdd082c1f7
-- Original Grand_Historian_Thoridain.pl sha256: a15c4d110cdc19e158f20f6896d7aa18ee56c1260770a1f698852e8d637d1988
-- The original You.pl/Grand_Historian_Thoridain.pl split uses a targeted-say
-- workaround. Use the existing proximity speech and ground-object runtime.
local recitations = 0
local prayer = "oh brell, thank you for protecting me and seeing me through my trials. forgive me for the things i think and say and do that displease you. please reveal to me your will and bless me with the patience and obedience to do that which you desire. amen."

function event_spawn(e)
  -- P99 describes the floor before the altar, but gives no trigger bounds.
  -- Bound this listener around its authored chapel placement (809,-354,-14),
  -- not around the player or the whole zone. Range is an explicit approximation.
  local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
  eq.set_proximity(x - 25, x + 25, y - 25, y + 25, z - 15, z + 15)
  eq.enable_proximity_say()
end

function event_proximity_say(e)
  -- Keep the final punctuation required by P99. Case is not significant.
  if string.lower(e.message) ~= prayer then return end
  recitations = recitations + 1
  if recitations == 1 then
    e.self:Emote("can feel a strong presence beginning to take shape in the chapel. Perhaps you should recite the prayer again.")
  elseif recitations == 2 then
    e.self:Emote("sense a being of great power focusing its attention on you.")
  else
    e.self:Emote("have been inspired. The sacred pattern of the Coldain rune materializes on the ground before you.")
    eq.create_ground_object(1855, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
    recitations = 0
  end
end
