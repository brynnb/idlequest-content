-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Trooper_Vaurk.pl
-- items: 8004

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Have you been sent by the War Baron to [assist]? The explorers from Firiona Vie draw closer.")
	elseif e.message:findi("assist") then
		e.self:Say("That is good, I will stay here to halt any advances. Head out near the lake and destroy the trespassers on our land! Bring me four of their knives that they carry for survival. Prove your allegiance to the Legion of Cabilis.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8004, item2 = 8004, item3 = 8004, item4 = 8004}) then
		e.self:Say("Great work, the Legion of Cabilis will not soon forget your dedication. The trespassers shall all be dealt with.")
		e.other:Faction(441, 10, 0)
		e.other:Faction(440, 10, 0)
		e.other:Faction(445, 10, 0)
		e.other:Faction(442, 10, 0)
		e.other:Faction(444, 10, 0)
		e.other:AddEXP(25)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
