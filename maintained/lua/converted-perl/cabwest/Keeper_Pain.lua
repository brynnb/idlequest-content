-- Converted from ProjectEQ Perl quest script.
-- Source: cabwest/Keeper_Pain.pl
-- items: 12869, 17041, 12885, 15444

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("raises his gaze from his tomes to greet you. 'Ahh!! Welcome, seeker of knowledge! Come to fill your brains, have you? Look closer, adventurer. I have scribed some very powerful spells.")
	elseif e.message:findi("wand of pain") then
		e.self:Emote("drops his tome and monocle and looks at you sharply. 'What?!! Have you seen Revenant Vytrix? I let him borrow my wand for a quest. That was half a season ago!! I fear he is dust and my precious wand is lost.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12869}) then
		e.self:Emote("begins jumping for joy. 'Yoohoo!! My wand!! Thank you. You must be some powerful adventurer. You can help me collect a few components. Fill this chest with a frost crystal, a cockatrice egg, a giant hornet egg and a plains pebble. Return the full chest to me and I shall offer you a spell I recently researched.")
		e.other:AddEXP(100)
		e.other:GiveCash(0, 0, 4, 0)
		e.other:SummonItem(17041)
		e.other:Faction(443, 2, 0)
		e.other:Faction(441, 2, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12885}) then
		e.self:Say("Yes this is exactly what i wanted. Here is your spell.")
		e.other:SummonItem(15444)
		e.other:Faction(443, 2, 0)
		e.other:Faction(441, 2, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
