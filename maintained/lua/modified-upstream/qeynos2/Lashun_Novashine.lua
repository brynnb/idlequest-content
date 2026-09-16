-- Source: qeynos2/Lashun_Novashine.lua
-- items: 13073
local function reward_bone_chips(e)
	e.self:Say("Ah good, I see you seek healing. But you must offer the remains of one more minion of Bertoxxulous before Rodcet will deem you worthy.");
	e.self:Say("Very well, young one. May the light of the Prime Healer wash away your scars.");
	e.other:Ding();
	e.self:CastSpell(17,e.other:GetID()); -- Spell: Light Healing
	e.other:Faction(341,2,0); -- Faction: Priests of Life
	e.other:Faction(280,2,0); -- Faction: Knights of Thunder
	e.other:Faction(262,2,0); -- Faction: Guards of Qeynos
	e.other:Faction(221,-2,0); -- Faction: Bloodsabers
	e.other:Faction(219,2,0); -- Faction: Antonius Bayle
	e.other:AddEXP(12);
end

local function reward_two_gold(e)
	e.self:Say("Thank you for the donation to the Temple of Life. May Rodcet Nife cleanse your body of all ills.");
	e.other:Ding();
	e.other:Faction(341,2,0); -- Faction: Priests of Life
	e.other:Faction(280,2,0); -- Faction: Knights of Thunder
	e.other:Faction(262,2,0); -- Faction: Guards of Qeynos
	e.other:Faction(221,-2,0); -- Faction: Bloodsabers
	e.other:Faction(219,2,0); -- Faction: Antonius Bayle
	e.other:AddEXP(12);
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say(string.format("Well met, %s. My name is Lashun Novashine and I am a humble priest of Rodcet Nife, the Prime Healer. I wish to spread His word to every corner of Norrath. My job gets more difficult each day with so many so willing to take lives rather than preserve them.",e.other:GetName()));
	end
end

function event_waypoint_arrive(e)
	if(e.wp == 13 or e.wp == 14 or e.wp == 15) then
		e.self:Shout("Cease this endless conflict and seek salvation in the Temple of Life! The glory of Rodcet Nife awaits you!");
	elseif(e.wp == 57) then
		e.self:Say("Greetings, people of Qeynos! Are you lost? Has the chaotic life of an adventurer left you empty and alone? Seek redemption in the glorious light of the Prime Healer. Only through Rodcet Nife and the Temple of Life will you find true health and salvation.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	
	if(item_lib.check_turn_in(e.trade, {item1 = 13073,item2 = 13073,item3 = 13073,item4 = 13073})) then
		reward_bone_chips(e);
		reward_bone_chips(e);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13073,item2 = 13073})) then
		reward_bone_chips(e);
	elseif(item_lib.check_turn_in(e.trade, {gold = 2})) then
		reward_two_gold(e);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
