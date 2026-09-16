-- Converted from ProjectEQ Perl quest script.
-- Source: swampofnohope/Captain_Nedar.pl
-- items: 12439

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Come to serve the garrison? Good. I aim to offer a reward for the return of four froglok tad tongues. Best if we handle the pesky critters before they grow too big and too numerous.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12439, item2 = 12439, item3 = 12439, item4 = 12439}) then
		e.self:Say("Well done. It is good to serve the Warlord. Here is a small reward befitting such a small task.")
		e.other:Faction(441, 5, 0)
		e.other:Faction(440, 5, 0)
		e.other:Faction(445, 5, 0)
		e.other:Faction(442, 5, 0)
		e.other:Faction(444, 5, 0)
		e.other:GiveCash(7, 0, 0, 0)
		e.other:AddEXP(10)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
