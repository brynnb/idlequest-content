-- name: Jaled_Dar-s_shade
-- P99 Key to Sleeper's Tomb: five named first-brood talismans only.
-- Preserve ProjectEQ 500000 XP and zone flag128 as upstream engine fallbacks;
-- wiki does not establish XP amount or keyring flags. No inferred level gate.
function event_say(e)
  if e.message:findi("hail") then
    e.self:Say("Mortal! You MUST aid me.  I will have my revenge, and my rest!");
  elseif e.message:findi("aid you") then
    e.self:Say("You must wake The Sleeper. He is our salvation, he will restore a new golden age to Norrath. It was a terrible mistake to subdue him, jealousy and envy led us to do it. I see all of this clearly now.");
  elseif e.message:findi("the sleeper") then
    e.self:Say("Kerafyrm, the best of us, what we should be. We imprisoned him in a timeless slumber aeons ago. I know how to release him, but I am no longer of the flesh, so I cannot do it myself. But you can accomplish this task!");
  elseif e.message:findi("task") then
    e.self:Say("When the tomb was closed and the entry sealed, many dragons participated in the ceremony. They invested portions of their essence into the seal. The seal is part of them now. With the right talismans, I can show you how to make a key that will allow one to pass, as if they were of the First Brood. If you do not wish to do this for the good of all, perhaps you will be willing to do it for material riches. Priceless treasures are stored in the tomb, yours for the taking, once you are inside and have released The Sleeper.");
  elseif e.message:findi("talismans") then
    e.self:Say("Sontalak, Lendiniara, Klandicar, Yelinak, and Zlandicar are all that are left alive of those who were involved in the sealing of the tomb. Each has a talisman. Bring me any one of these items, or a large enough piece from one of the talismans from a dead first brood, and I shall unlock its power, which will allow you entry into the tomb.");
  end
end

function event_trade(e)
  local item_lib = require("items");
  local accepted = false;
  for _, talisman in ipairs({27255, 27256, 27258, 27259, 27266}) do
    if item_lib.check_turn_in(e.trade, {item1 = talisman}) then
      accepted = true;
      break;
    end
  end
  if accepted then
    e.self:Say("Very well done. Here is how you unlock the entry. Seek out a great dragon statue in the Eastern Wastes, and use this key there. Not very different from how you entered my old domain, Veeshan's Peak, now, is it? Haha, yes, I know many things, even dead.");
    e.other:QuestReward(e.self, 0, 0, 0, 0, 27265, 500000);
    eq.set_zone_flag(128);
  end
  item_lib.return_items(e.self, e.other, e.trade);
end
