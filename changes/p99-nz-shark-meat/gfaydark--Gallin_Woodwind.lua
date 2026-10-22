-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Gallin_Woodwind.pl
-- P99 audit: Shark Meat Quest
-- items: 17953, 12121, 7032

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings. friend! I am Gallin Woodwind of the Emerald Warriors. It is my charge to send forth Fier'Dal to [hunt for meat]. Kelethin's citizens must be nourished and this requires meat. Such is the circle of life.")
	elseif e.message:findi("hunt for meat") then
		e.self:Say("Good!!  We have enough young warriors hunting in our woods. Your duty shall be to take this pack to the ocean and seek out sharks. Fill the bag with shark meat and combine it. I shall reward you with a fine piercing weapon.")
		e.other:SummonItem(17953)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12121}) then
		e.self:Say("Very good. This meat will supply our warriors with much strength. We have found the meat from sharks to be quite nourishing. Here, then, are your wages and your weapon. All of Kelethin appreciates your great deed.")
		e.other:SummonItem(7032) -- Cast-Iron Rapier
		e.other:Faction(326, 10, 0)
		e.other:Faction(270, -10, 0)
		e.other:Faction(325, 10, 0)
		e.other:Faction(276, 10, 0)
		e.other:AddEXP(150)
		e.other:GiveCash(23, 0, 7, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
