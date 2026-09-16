-- Modified from ProjectEQ Lua to route Lion Meat Shipment through Misla per P99.
-- Source: qey2hh1/Einhorst_McMannus.lua
-- P99: https://wiki.project1999.com/Lion_Meat_Shipment_Quest
-- items: 18831, 13962

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". Welcome to the fishing village of Clan McMannus. We sell what we can here. Have a look around but, please do not buy too much. We must save most of our stock for delivery to our home.")
	elseif e.message:findi("searching for the fugitive") then
		e.self:Say("I see they have sent someone to hunt the scoundrel down. I am afraid I haven't seen the barbarian thief in quite some time. You can search and search for him here in the western plains, but I doubt you shall find him. Good luck.")
	elseif e.message:findi("pick up the lion meat shipment for Halas") or e.message:findi("lion meat shipment") then
		e.self:Say("Oh, yes, the lion meat shipment. Aye, it's here somewhere. Just a moment. Ah! Here you go. Apologize for the delay in this.")
		e.self:Say("That would be splendid! Go to Misla and tell her you will deliver the lion meat to Halas. She will instruct you. Thank you, my friend.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 18831}) then
		e.self:Say("What? Ok well, hmm let me see...... Oh there it is. Here is the shipment as ordered!")
		e.other:SummonItem(13962) -- Karana Clover Shipment
		e.other:Ding()
		e.other:Faction(320, 2, 0) -- Wolves of the North
		e.other:Faction(327, 2, 0) -- Shamen of Justice
		e.other:Faction(328, 2, 0) -- Merchants of Halas
		e.other:Faction(311, 2, 0) -- Steel Warriors
		e.other:Faction(305, -3, 0) -- Rogues of the White Rose
		e.other:AddEXP(1600)
		e.other:GiveCash(math.random(99), math.random(99), eq.ChooseRandom(3, 4, 5), 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
