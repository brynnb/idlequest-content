-- P99 ending: the four items release human Lhranc, whose corpse holds the sword.
-- The later token -> Marl ending in ProjectEQ is not the P99 path. Authority:
-- cached Shadow Knight Epic Quest quick/short walkthroughs and Lhranc NPC page
-- (2026-08-12, SHA256 9deb5f0ab838b59c943d2065fb21253e28f121f4b4787fd35b9069963e90114a).
-- Keep imported human NPC 90187: 90093 is another spectral record, not a safe
-- replacement merely because its ID is printed in the wiki's NPC template.

function event_say(e)
  if e.other:GetModCharacterFactionLevel(e.self:GetPrimaryFaction()) > 42 then
    if e.message:findi("hail") then
      e.self:Say("Ahh, finally! He has sent you. No time to waste now, you must help me lift the curse at once!")
    elseif e.message:findi("curse") then
      e.self:Say("Can you not see my condition! I have been unjustly sentenced to an eternity in this wretched form you see before you, never to leave these walls. In exchange for the cure for this curse, I swear to show you a secret that would make you the most powerful of your kind.")
    elseif e.message:findi("cure") then
      e.self:Say("I require only four things of you, dark one, and one of them you hold now. Bring me the heart of an innocent, the head of the valiant, and the will of Innoruuk. With these, my curse shall be lifted at last and I will craft a weapon that will cast a shadow over all of Norrath.")
    end
  else
    e.self:Emote("seems to ignore you.")
  end
end

function event_trade(e)
  local item_lib = require("items")
  if e.other:GetModCharacterFactionLevel(e.self:GetPrimaryFaction()) >= 72
    and item_lib.check_turn_in(e.trade, {item1 = 14367, item2 = 14368, item3 = 14369, item4 = 14370}) then
    e.self:Say("Ahh, at last I can free myself of this prison! Centuries have passed since I enjoyed the fruits of mortality.")
    e.other:Faction(404, 10)
    eq.spawn2(90187, 0, 0, 85.1, 0.9, 7.8, 192)
    eq.depop_with_timer()
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
