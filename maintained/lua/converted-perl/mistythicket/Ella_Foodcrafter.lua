-- Source: mistythicket/Ella_Foodcrafter.pl
-- Ranger Epic 1.0: Ella Foodcrafter handles bowl, stone, and scimitar hand-ins.
-- Converted from ProjectEQ Perl quest script.
-- items: 18959, 17860, 20473, 20460, 20462, 20468, 20440

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hi, hi. I've got a lot to do.")
	elseif e.message:findi("two tasks") then
		e.self:Say("First, I need a mixture. When ya do find how to make it ya can mix it in that bowl.")
		e.other:SummonItem(17860) -- Shiny Tin Bowl
	elseif e.message:findi("second task") then
		e.self:Say("Second, I need a special type of bowl. Seek this knowledge and these items out in the lands.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18959}) then
		e.self:Say("I've been waiting for someone to bring me this. I have two tasks for ya.")
	elseif item_lib.check_turn_in(e.trade, {item1 = 20473, item2 = 20460}) then
		e.self:Emote("smiles slowly as she works the mixture in the bowl and it starts to shine with power.")
		e.other:SummonItem(20462) -- Softly Glowing Stone
	elseif item_lib.check_turn_in(e.trade, {item1 = 20468}) then
		e.self:Emote("hands you a scimitar she usually wears at her side.")
		e.other:SummonItem(20440) -- Elaborate Scimitar
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
