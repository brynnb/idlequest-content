-- Source: airplane/Abec_Ianor.lua
-- P99 audit: Wizard Plane of Sky Tests
-- items: 20951, 20747, 20748, 11686, 20958, 20749, 20750, 27710, 14556, 20753, 20965, 20751, 20752, 11685

function event_spawn(e)
	eq.set_timer("depop", 300000)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome. I am Apprentice Abec. Do you wish to test your powers? Or have you already finished all your tests?")
	elseif e.message:findi("test my powers") then
		e.self:Say("Great, let us waste no more time! Do you wish to begin your test of conception, visualization, or preparation?")
	elseif e.message:findi("already finished") or e.message:findi("finished all") then
		e.self:Say("We recently gave out a batch of inferior Amulets of Planar Transference. If you bring me one of these I will gladly replace it with an upgraded version. After all, you earned it, right?")
	elseif e.message:findi("conception") then
		e.self:Say("Conception is vital. Travel beyond and bring forth an Efreeti Statuette, a Mithril Air Ring, and a Box of Winds. From these I will produce a ring that will protect you where ever you go.")
	elseif e.message:findi("visualization") then
		e.self:Say("Visualize and succeed. Proceed upward and bring to me a White-Tipped Spiroc Feather, a Pulsating Sapphire, and an Amethyst Amulet. With these items, I will be able to produce an amulet that will aid in your travels to our home.")
	elseif e.message:findi("preparation") then
		e.self:Say("Always be prepared. Adventure and return an Efreeti War Staff, some Lush Nectar, a Copper Air Band, and a large Sky Sapphire and you shall be rewarded with the Staff of Storms.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, { item1 = 20951, item2 = 20747, item3 = 20748 }) then
		e.other:SummonItem(11686) -- Solidate Mithril Ring
		e.other:AddEXP(100000)
		e.self:Say("Excellent! Take this.")
		eq.depop()
	elseif item_lib.check_turn_in(e.trade, { item1 = 20958, item2 = 20749, item3 = 20750 }) then
		e.other:SummonItem(27710) -- Amulet of the Void
		e.other:AddEXP(100000)
		e.self:Say("Excellent! Take this.")
		eq.depop()
	elseif item_lib.check_turn_in(e.trade, { item1 = 14556 }) then
		e.other:SummonItem(27710) -- Upgrade old Amulet of Planar Transference to Amulet of the Void
		e.other:AddEXP(1000)
		e.self:Say("Excellent! Take this.")
		eq.depop()
	elseif item_lib.check_turn_in(e.trade, { item1 = 20753, item2 = 20965, item3 = 20751, item4 = 20752 }) then
		e.other:SummonItem(11685) -- Nargon's Staff
		e.other:AddEXP(100000)
		e.self:Say("Excellent! Take this.")
		eq.depop()
	end

	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	eq.stop_timer("depop")
	eq.depop()
end
