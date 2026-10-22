-- Modified from ProjectEQ Lua.
-- Source: crushbone/Retlon_Brenclog.lua
-- P99 audit: Slave Keys
-- items: 20015, 18887

local function faction_ok(e)
	return e.other:GetFaction(e.self) <= 7 -- dubious or better
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Oh my word!! A rescuer!! Hurry! Get me out of these chains!! Go find the orc who has the keys!");
	elseif(e.message:findi("get me out")) then
		e.self:Say("I am from Ak'Anon! I must return a [spellbook] to the Eldritch Collective.");
	elseif(e.message:findi("spellbook")) then
		e.self:Say("What?! I am stuck here and you are worried about a spellbook?! Forget that! Just get the keys to my shackles from one of the orcs! HURRY!");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {copper = 1})) then
		e.self:Say("No, no!! I do not need this!! Get me key number 15!!");
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20015})) then
		if not faction_ok(e) then
			e.self:Say("The orcs might see you and me talking and slay us both!")
			e.other:SummonItem(20015)
		else
			e.self:Say("Good work!! I shall be on my way. Farewell my friend!!");
			e.other:Ding();
			e.other:Faction(245,1,0); -- Eldritch Collective
			e.other:Faction(238,-1,0); -- Dark Reflection
			e.other:Faction(239,-2,0); -- The Dead
			e.other:Faction(255,1,0); -- Gem Choppers
			e.other:Faction(333,1,0); -- King Ak`Anon
			e.other:AddEXP(1000);
			e.other:GiveCash(0,3,2,0);
			eq.depop_with_timer();
		end
	elseif(item_lib.check_turn_in(e.trade, {item1 = 18887})) then
		e.self:Say("Ah! A letter from my brother! Mmm... no... no I don't have Tergon's spellbook. The orc's prophet took it and then they locked me in chains! Now why don't you go do something useful and get me key number 15!!");
		e.other:Faction(333,1,0); -- King Ak`Anon
		e.other:Faction(245,1,0); -- Eldritch Collective
		e.other:Faction(238,-1,0); -- Dark Reflection
		e.other:Faction(255,1,0); -- Gem Choppers
		e.other:Faction(239,-2,0); -- The Dead
		e.other:AddEXP(500);
		eq.depop_with_timer();
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
