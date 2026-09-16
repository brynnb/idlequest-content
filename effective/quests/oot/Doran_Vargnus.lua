-- Converted from ProjectEQ Perl quest script.
-- Source: oot/Doran_Vargnus.pl
-- items: 13995

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Well 'ello thar! I'm Doran Vargnus, chief armor smith to the court o' Kaladim.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13995}) then
		e.self:Say("Ahh!! You must have been sent by Beno of the Stormguard. I have been wondering when he would return my card. I have not been playing with a full deck. How about a reward? Hmm. Let's see what I have lying around.. Here!! Take this. I cannot possibly give you any of my good armor.")
		e.other:SummonItem(eq.ChooseRandom(
			3047, 3048, 3042, 3050, 3043, 3046,
			3604, 1410, 4210, 4209, 4207, 4211, 4204, 4205, 4208, 4206,
			1001, 1007, 1011, 1008, 1002,
			4233, 4227, 4235, 4226, 4229,
			1030, 1027, 1035, 1028, 1032, 1026,
			3130, 3125, 4230, 2368,
			3104, 3110, 3103, 3108, 3045,
			4216, 4215, 4223, 4214, 4220,
			1018, 1023, 1014,
			3121, 3118, 3116, 3122, 3117, 3123,
			1317
		))
		e.other:Ding()
		e.other:Faction(312, 10, 0) -- Storm Guard
		e.other:Faction(274, 1, 0) -- Kazon Stormhammer
		e.other:Faction(293, 1, 0) -- Miners Guild 249
		e.other:Faction(290, 1, 0) -- Merchants of Kaladim
		e.other:Faction(232, -1, 0) -- Craknek Warriors
		e.other:AddEXP(500)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
