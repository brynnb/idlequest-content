-- Converted from ProjectEQ Perl quest script.
-- Source: fieldofbone/Trooper_Taer.pl
-- items: 18249, 18250

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail! I suggest you stay within the walls of Cabilis. This is no place for you. The Field of Bone is far too close.")
	elseif e.message:findi("sign the restraining order") or e.message:findi("sign this restraining order") then
		e.self:Say("Oh, no! My good times have come to an end. Hand me the note and I shall sign it.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18249}) then
		e.self:Say("Ha ha! Look at all the names. Ozlot and Frogzin. What lushes. Here you are. I can't imagine there being any others to sign. This is the entire Cabilis brew brigade. Alas... Disbanded forever.")
		e.other:SummonItem(18250)
		e.other:Faction(441, 5, 0)
		e.other:Faction(440, 5, 0)
		e.other:Faction(445, 5, 0)
		e.other:Faction(442, 5, 0)
		e.other:Faction(444, 5, 0)
		e.other:AddEXP(200)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
