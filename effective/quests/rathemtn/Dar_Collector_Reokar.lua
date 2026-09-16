-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Dar_Collector_Reokar.pl
-- items: 13073, 13019, 13050

local function reward_step(e, message, value)
	e.self:Say(message)
	if value == nil then
		eq.delete_global("darcollect")
	else
		eq.set_global("darcollect", tostring(value), 2, "D30")
	end
	e.other:Faction(1719, 4, 0)
	e.other:Faction(1718, 4, 0)
	e.other:Faction(1716, 4, 0)
	e.other:Faction(1717, 4, 0)
	e.other:Faction(1709, 4, 0)
	e.other:AddEXP(100)
	e.other:Ding()
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings! Have you anything for me? Don't look at me like that, you know what I mean. Odds and ends from out there in the swamp. Rat parts are fine, and I could always use some freshly caught fish.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local qglobals = eq.get_qglobals(e.other)
	local state = qglobals["darcollect"]
	if state == nil and item_lib.check_turn_in(e.trade, {item1 = 13073, item2 = 13073, item3 = 13073, item4 = 13073}) then
		reward_step(e, "Thank you!", 1)
	elseif state == "1" and item_lib.check_turn_in(e.trade, {item1 = 13073, item2 = 13073, item3 = 13073, item4 = 13073}) then
		reward_step(e, "I'm going to need some fish now.", 2)
	elseif state == "2" and item_lib.check_turn_in(e.trade, {item1 = 13019, item2 = 13019, item3 = 13019, item4 = 13019}) then
		reward_step(e, "Thank you!", 3)
	elseif state == "3" and item_lib.check_turn_in(e.trade, {item1 = 13019, item2 = 13019, item3 = 13019, item4 = 13019}) then
		reward_step(e, "I'm going to need some rat ears now.", 4)
	elseif state == "4" and item_lib.check_turn_in(e.trade, {item1 = 13050, item2 = 13050, item3 = 13050, item4 = 13050}) then
		reward_step(e, "Thank you!", 5)
	elseif state == "5" and item_lib.check_turn_in(e.trade, {item1 = 13050, item2 = 13050, item3 = 13050, item4 = 13050}) then
		reward_step(e, "I'm going to need some bone chips now.", nil)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
