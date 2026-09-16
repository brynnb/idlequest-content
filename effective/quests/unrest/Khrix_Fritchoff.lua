-- Modified from ProjectEQ Lua for P99 "The Summoning of Dread".
-- P99 currently requires Fire Beetle Eye for Khrix Fritchoff.
-- P99: https://wiki.project1999.com/The_Summoning_of_Dread
-- items: 10307

function event_say(e)
	if e.message:findi("powder of reanimation") then
		e.self:Say("So you want the powder of reanimation eh? Well you can have it if you can get it from that terrible abomination I have created! Perhaps you have a Fire Beetle Eye for me so that I may see my way out of here!")
	else
		e.self:Say("Close the door and be gone, fool!! You are going to give away my hiding spot!!")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 10307}) then -- Fire Beetle Eye
		e.self:Say("At last I may leave this place!! Good luck destroying my abomination, you will surely need it against my most powerful yet uncontrollable creation!")
		e.other:Ding()
		e.other:Faction(238, 1, 0) -- Dark Reflection
		e.other:Faction(245, -1, 0) -- Eldritch Collective
		e.other:Faction(255, -1, 0) -- Gem Choppers
		e.other:Faction(240, -1, 0) -- Deepmuses
		e.other:AddEXP(1000)
		eq.unique_spawn(63111, 0, 0, 60, 622, 20, 0) -- Khrix_Abomination
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
