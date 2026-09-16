-- Source: qeynos2/Camlend_Serbold.lua
-- items: 69968, 18711, 13506, 13324, 13325, 12238
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18711) then
		e.other:Message(MT.Yellow,"As you get your bearings, a healing energy seems to sweep over you and an almost etheral voice seems to echo in your mind. 'Welcome young paladin of Rodcet. I am Guild Master Camlend Serbold. Read the note in your inventory and hand it to me to begin your training.'");
	end
end

function event_say(e)
	local qglobals = eq.get_qglobals(e.other);
	local fac = e.other:GetFaction(e.self);
	if(qglobals["paladin_epic"] == "9") then
		if(e.message:findi("hail")) then
			e.self:Say("It has been a while, " .. e.other:GetName() .. ". You look troubled, is there anything I can help you with? Do you know anyone that needs the [" .. eq.say_link("curing") .. "] touch of Rodcet Nife?");
		elseif(e.message:findi("curing")) then
			e.self:Say("I might have something that will aid you in curing Kemik. Make a small donation of say 500 platinum to Ziska and she will craft powerful prayer beads that will help Kemik. With the beads Ziska crafts you will need to combine them with [" .. eq.say_link("special gems") .. "].");
		end
	else
		if(e.message:findi("hail")) then
			e.self:Say("I say, good to meet you, " .. e.other:GetName() .. "!  I am Camlend Serbold.  Some call me Serbold the Great.  I am the leader of the righteous order of paladins which serves the Temple of Life.  Together with the clerics of this temple, we defend the will of the great [" .. eq.say_link("Rodcet Nife") .. "] and smite all who dare to oppose us.");
		elseif(e.message:findi("rodcet nife")) then
			e.self:Say("Do you feel your heart beating within your chest?  It is Rodcet Nife, the Prime Healer, whose breath keeps it in perfect rhythm.  If you do not pray to His glory then I assure you, someday when your heart begins to slow, you shall be crying out loud to Rodcet Nife.");
		elseif(fac <= 3) then
			if(e.message:findi("lord grimrot")) then
				e.self:Say("You have heard of Lord Grimrot? He is a shadowknight working with the Bloodsabers. We have word he is trying to build an army of undead. Only a powerful knight can rid the lands of Grimrot. So, did you come here to [" .. eq.say_link("defend life") .. "]?");
			elseif(e.message:findi("defend life")) then
				e.self:Say("Do you feel your heart beating within your chest?  It is Rodcet Nife, the Prime Healer, whose breath keeps it in perfect rhythm.  If you do not pray to His glory then I assure you, someday when your heart begins to slow, you shall be crying out loud to Rodcet Nife.");
			end
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	local fac = e.other:GetFaction(e.self);

	if(item_lib.check_turn_in(e.trade, {item1 = 18711})) then -- Tattered Note
		e.self:Say("Welcome to the Temple of Life. You have much to learn and we have much work to do. Pain, hurt, disease and death lurk everywhere, our job is seemingly endless, but none is more gratifying. Here is our guild tunic, represent us well. Good health be with you.");
		e.other:SummonItem(13506); -- Faded Tunic*
		e.other:Ding();
		e.other:Faction(341,100,0); -- Priest of Life
		e.other:Faction(280,30,0); -- Knight of Thunder
		e.other:Faction(262,50,0); -- Guards of Qeynos
		e.other:Faction(221,-25,0); -- Bloodsabers
		e.other:AddEXP(100);
	elseif(fac <= 2) then -- P99 requires warmly or better faction
		if(item_lib.check_turn_in(e.trade, {item1 = 13324,item2 = 13325})) then -- Pestilence Scythe ID: 13324 # Decaying Heart ID: 13325
			e.self:Say("We thank you for your service. With Lord Grimrot's evil soul trapped in this scythe, all but the truly evil shadowknights would be able to wield it. I would like to present you with this as a token of our appreciation. Your devotion to life is supreme. Go now, and serve life.");
			e.other:SummonItem(12238); -- Aegis of Life ID: 12238
			e.other:Faction(341,30,0); -- Priest of Life
			e.other:Faction(280,30,0); -- Knight of Thunder
			e.other:Faction(262,30,0); -- Guards of Qeynos
			e.other:Faction(221,-55,0); -- Bloodsabers
			e.other:Faction(219,30,0); -- Antonius Bayle
		end
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

-- END of FILE Zone:qeynos2 ID:2092 -- Camlend_Serbold
