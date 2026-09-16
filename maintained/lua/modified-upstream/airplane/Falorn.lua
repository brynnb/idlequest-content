-- Source: airplane/Falorn.lua
-- P99 audit: Warrior Plane of Sky Tests
-- items: 20935, 20972, 20973, 14569, 20942, 20974, 20975, 4321, 20928, 20795, 20971, 14551, 27701

function event_spawn(e)
	eq.set_timer("depop",300000)
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Do not waste my time, " .. e.other:GetName() .. ".  Do you wish to take the test of blades or not? Or do you have one of my old trinkets you wish to trade in?")
	elseif(e.message:findi("trinkets")) then
		e.self:Say("Ahh, I've given out some lesser trinkets in the past that many have gotten bored with.  I'm willing to accept Aerated Pauldrons in trade for Pauldrons of the Blue Sky.")
	elseif(e.message:findi("blades")) then
		e.self:Say("The test of blades is not easy.  I hope you are as powerful as you are brave.  What do you wish to strive for? Strength, force, or skill?")
	elseif(e.message:findi("strength")) then
		e.self:Say("Remember, true strength lies not only in the body, but in the mind as well. Return to me a bronze disc, a small pick and a stone amulet. If you manage to do this my runed wind amulet will be yours.")
	elseif(e.message:findi("force")) then
		e.self:Say("Foolishness or bravery Gendal?  We shall see. Return to me a pearlescent globe, a silver mesh and a spiroc air totem  In return, you will receive both my deepest respect and the aerated pauldrons.")
	elseif(e.message:findi("skill")) then
		e.self:Say("The test of skill it is. Go upward and retrieve these three items: an ivory tessera, a tiny ruby, and an azure ring. Return these to me and the azure ruby ring shall be yours.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20935, item2 = 20972, item3 = 20973}) then
		e.other:SummonItem(14569) -- Runed Wind Amulet
		e.other:AddEXP(100000)
		e.self:Say("You have proven yourself worthy.")
		eq.depop()
	elseif item_lib.check_turn_in(e.trade, {item1 = 20942, item2 = 20974, item3 = 20975}) then
		e.other:SummonItem(4321) -- Aerated Pauldrons
		e.other:AddEXP(100000)
		e.self:Say("You have proven yourself worthy.")
		eq.depop()
	elseif item_lib.check_turn_in(e.trade, {item1 = 20928, item2 = 20795, item3 = 20971}) then
		e.other:SummonItem(14551) -- Azure Ruby Ring
		e.other:AddEXP(100000)
		e.self:Say("You have proven yourself worthy.")
		eq.depop()
	elseif item_lib.check_turn_in(e.trade, {item1 = 4321}) then
		e.other:SummonItem(27701) -- Pauldrons of the Blue Sky
		e.other:AddEXP(100000)
		e.self:Say("You have proven yourself worthy.")
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	eq.stop_timer("depop")
	eq.depop()
end
