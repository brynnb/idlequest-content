-- Modified from ProjectEQ Lua during P99 quest audit.
-- P99: https://wiki.project1999.com/Marr_Minnows_for_Palon
-- items: 13861, 13862, 13002, 13007

local function academy_trusts_player(e)
	return e.other:GetFaction(e.self) < 4 -- kindly or better; P99 notes amiable is not enough to receive the jar
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say(string.format("Pleased to meet you. %s. Have you seen how clear the water is underneath the Academy? All sorts of life could flourish there. What a shame there are no [Marr Minnows] there.",e.other:GetName()));
	elseif(e.message:findi("marr minnow")) then
		e.self:Say("The Marr Minnow swims in the pond near the Temple of Marr. I wish I had one. Not a dead one. A live one. I need someone to [get the minnow].");
	elseif(e.message:findi("get the minnow")) then
		if academy_trusts_player(e) then
			e.self:Say("Please try. Here you are. Take this jar. Offer the jar to the minnows. Maybe they will swim into it.");
			e.other:SummonItem(13861); -- Item: Jar of Liquid
		else
			e.self:Say("The Academy of Arcane Science does not yet trust you with such work. Perform more tasks for the great Tara Neklene, then return when your worth is proven.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 13862})) then
		e.self:Say("Oh!! A beautiful Marr Minnow. This shall look grand in my aquarium!! How lucky that you are a friend to the Academy of Arcane Science. Take your reward.");
		e.other:SummonItem(eq.ChooseRandom(13002,13007)); -- Item(s): Torch (13002), Ration (13007)
		e.other:Ding();
		e.other:Faction(220,5,0); -- Arcane Scientists
		e.other:Faction(281,1,0); -- Knights of Truth
		e.other:Faction(296,-1,0); -- Opal Dark Briar
		e.other:Faction(330,-1,0); -- Freeport Militia
		e.other:AddEXP(100);
		e.other:GiveCash(6,10,0,0);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:freportw -- Palon_Deskeb
