-- Source: airplane/Ogog.lua
-- P99 audit: Warrior Plane of Sky Tests
-- items: 20983, 20963, 20981, 20982, 11675, 20980, 20979, 20956, 11674, 20976, 20949, 20977, 20978, 11673

function event_spawn(e)
	eq.set_timer("depop",300000)
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Ogog not smart, but Ogog smarter than you.  You ready for Ogog or no?")
	elseif(e.message:findi("ready")) then
		e.self:Say("Ok, " .. e.other:GetName() .. ".  Ogog got some hard things for you.  You do bash, smash, or think test?")
	elseif(e.message:findi("think")) then
		e.self:Say("Ogog think you can do this one maybe.  Ogog no know, though.  You bring Ogog efreeti belt, pegasus statue, a spiroc wind totem, and a wind tablet.  Ogog say good luck!")
	elseif(e.message:findi("smash")) then
		e.self:Say("Ogog smash good. . . Ogog no think you can smash good.  But Ogog let you try.  You get Ogog Djinni War Blade, some virulent wasp poison, and a mottled spiroc feather.  Ogog say you good warrior if you do this!")
	elseif(e.message:findi("bash")) then
		e.self:Say("This one hard, Ogog like it.  Ogog need efreeti battle axe, some honey nectar, bottled djinni, and ethereal emerald. Then Ogog make you best basher.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20983, item2 = 20963, item3 = 20981, item4 = 20982}) then
		e.other:SummonItem(11675) -- Fangol
		e.other:AddEXP(100000)
		e.self:Say("Yuz do good! Take dis!")
		eq.depop()
	elseif item_lib.check_turn_in(e.trade, {item1 = 20980, item2 = 20979, item3 = 20956}) then
		e.other:SummonItem(11674) -- Dagas
		e.other:AddEXP(100000)
		e.self:Say("Yuz do good! Take dis!")
		eq.depop()
	elseif item_lib.check_turn_in(e.trade, {item1 = 20976, item2 = 20949, item3 = 20977, item4 = 20978}) then
		e.other:SummonItem(11673) -- Belt of the Four Winds
		e.other:AddEXP(100000)
		e.self:Say("Yuz do good! Take dis!")
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer ~= "depop" then return end
	eq.stop_timer("depop")
	eq.depop()
end
