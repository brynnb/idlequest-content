-- Source: freportw/Captain_Hazran.lua
-- items: 13916
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail citizen. Welcome to the Freeport Militia House. It is time for you to serve the state. You will assist us with our war with [Clan Deathfist] before you are truly accepted within our city. We urge you to be all we command you to be.");
	elseif(e.message:findi("clan deathfist")) then
		e.self:Say("Clan Deathfist are the orcs of the Commonlands. They are a nuisance and Sir Lucan has ordered their extermination. You will go forthh into the Commonlands and kill these orcs. Clan Deathfits is known to wear a Clan Belt. Bring this belt to me as proof of their death and you shall receive your wages and prove your allegiance to Freeport and all that is good.");
	elseif(e.message:findi("bigger problem")) then
		e.self:Say("The bigger problem is the Knights of Truth. We have already started our campaign to rid the city of the Knights. The so-called Knights of Truth are not to be trusted.");
	end
end

local function reward_belts(e, count)
	e.self:Say("Good work warrior. Your are good Militia material. Beware though, there are some who dare to call us foe. You have performed so well.");
	e.other:Ding();
	e.other:Faction(330,5 * count,0); -- Freeport Militia
	e.other:Faction(362,-1 * count,0); -- Priests of Marr
	e.other:Faction(281,-1 * count,0); -- Knights of Truth
	e.other:Faction(336,1 * count,0); -- Coalition of Tradefolk Underground
	e.other:AddEXP(14000 * count);
	e.other:GiveCash(0,0,3 * count,0);
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 13916,item2 = 13916,item3 = 13916,item4 = 13916})) then
		reward_belts(e, 4);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13916,item2 = 13916,item3 = 13916})) then
		reward_belts(e, 3);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13916,item2 = 13916})) then
		reward_belts(e, 2);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13916})) then
		reward_belts(e, 1);
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

-- END of FILE Zone:freportw  ID:9109 -- Captain_Hazran
