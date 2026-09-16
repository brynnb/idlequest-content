-- Source: qeynos/Guard_Wenbie.lua
-- P99 audit: Wenbie's Muffins
-- items: 13014, 13053

function event_combat(e)
	if e.joined then
		e.self:Say(string.format("Time to die %s!", e.other:GetCleanName()))
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ". What brings you to Qeynos? Must be the mighty fine muffins over at [Voleen's Bakery]. I just love those muffins!")
	elseif e.message:findi("voleen's bakery") then
		e.self:Say("Oh, it will be easier for us both if I just show you where it is. Follow me. But be quick about it, because I have to get back to my patrol.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local muffin = 0

	if item_lib.check_turn_in(e.trade, { item1 = 13014, item2 = 13014, item3 = 13014, item4 = 13014 }) then
		muffin = 4
	elseif item_lib.check_turn_in(e.trade, { item1 = 13014, item2 = 13014, item3 = 13014 }) then
		muffin = 3
	elseif item_lib.check_turn_in(e.trade, { item1 = 13014, item2 = 13014 }) then
		muffin = 2
	elseif item_lib.check_turn_in(e.trade, { item1 = 13014 }) then
		muffin = 1
	end

	while muffin > 0 do
		e.self:Say("Oh, thank you so much. I do get hungry on patrol. Here, please take this reward for your kindness.")
		e.other:Ding()
		e.other:Faction(262, 1, 0) -- Guards of Qeynos
		e.other:Faction(219, 1, 0) -- Antonius Bayle
		e.other:Faction(291, 1, 0) -- Merchants of Qeynos
		e.other:Faction(230, -1, 0) -- Corrupt Qeynos Guards
		e.other:Faction(223, -1, 0) -- Circle of Unseen Hands
		e.other:AddEXP(75)
		e.other:GiveCash(math.random(3, 5), 0, 0, 0) -- P99: 3-5 copper per muffin
		if math.random(10) == 1 then
			e.other:SummonItem(13053) -- Brass Ring, roughly 1 in 10
		end
		muffin = muffin - 1
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
