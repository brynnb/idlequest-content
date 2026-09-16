-- Source: kaladimb/Usbak_the_Old.pl
-- Ranger Epic 1.0: Usbak refines the Ancient Longsword.
-- Converted from ProjectEQ Perl quest script.
-- items: 20477, 20481

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Took ya long enough! If ye had an ancient blade or somethin ta be smithin, lemme see it.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20477}) then
		e.self:Emote("admires the blade and starts to bang the edge with a hammer.")
		e.other:SummonItem(20481) -- Refined Ancient Sword
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
