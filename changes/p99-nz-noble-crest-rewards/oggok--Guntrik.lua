-- IdleQuest starting guild note turn-in plus Classic/P99 Noble Hunters.
-- Source: oggok/Guntrik.pl
-- P99 audit: Noble Hunters
-- items: 18787, 13525, 13361, 5032, 5029, 5033, 5031, 13355

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Mmmph!! Who you? Oh, you " .. e.other:GetName() .. ". You supposed to be promising Craknek. Me need you. There bad things in swamp. You want [help Crakneks] or you [want Guntrik bash your face]!!?")
	elseif e.message:findi("help crakneks") then
		e.self:Say("Go to swamps. Find noble hunters of humans and elves. All have house crests. Return to me and I give things. If you find special item says where hunters sleep, give to me. If meat founded then give to Clurg's cook. She make fine stew and give coins for meat.")
	elseif e.message:findi("want guntrik bash your face") then
		e.self:Say("OK!! Me bash!! You hurt!!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18787}) then
		e.self:Say("Ahh.. good.. good.. here. take.. now you Craknek! You bash good. Bash lizards. Bash froggies. Bash mushrooms. Remember. you no help Greenbloods. Crakneks stronger than Greenbloods. When you [want to help crakneks] you tell Guntrik.")
		e.other:SummonItem(13525)
		e.other:AddEXP(100)
		e.other:Faction(232, 100, 0)
		e.other:Faction(228, 15, 0)
		e.other:Faction(261, -15, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 13361}) then
		e.self:Say("One less trouble. Hunhuh!! You do good work. Keep up. Remember to bring any special things to Guntrik. Here junk for good work. Go away now.")
		e.other:SummonItem(eq.ChooseRandom(5032, 5029, 5033, 5031, 13355, 5037, 6021))
		e.other:AddEXP(100)
		e.other:Faction(232, 10, 0) -- Craknek Warriors
		e.other:Faction(228, 10, 0) -- Clurg
		e.other:Faction(261, -10, 0) -- Green Blood Knights
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
