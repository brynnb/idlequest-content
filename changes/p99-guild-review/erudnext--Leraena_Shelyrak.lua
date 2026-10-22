-- Source: erudnext/Leraena_Shelyrak.lua
-- P99 audit: Clear Water, Kobold Shaman Paws and Quellious Symbol Quests.
-- Catman Alliance restored from https://wiki.project1999.com/Catman_Alliance.
-- items: 13989, 18723, 13546, 13883, 15213, 15011, 17090, 14582, 14583, 14585, 1564, 1565, 1566, 1772, 1780, 1781
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18723)) then
		e.other:Message(MT.Yellow,"A commanding, yet kind looking Erudite turns towards you as you attempt to get your bearings. 'Do not be startled. I am Leraena Shelyrak, Guild Master for the Clerics of Quellious. Read the note in your inventory and hand it to me when you are ready to begin your training.'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Welcome, my child. I am Leraena Shelyrak, overseer of the Temple of Divine Light. Inside this temple, you may find the path to inner peace. Introduce yourself to each of the priests and priestesses of the temple as well as the paladins. Together we shall put an end to such disruptive influences as the [kobold shaman].");
	-- The specific offer must precede the broader matching topic.
	elseif(e.message:findi("slay the kobold shaman")) then
		e.self:Say("Go to Toxxulia Forest and slay the kobold shamans. Bring me three Odd Kobold Paws as proof of your work.");
	-- P99's displayed hint and accepted response use both shaman and shamen.
	-- Match these specific stages before the generic paw-quest topic.
	elseif(e.message:findi("greater kobold shaman") or e.message:findi("greater kobold shamen")) then
		e.self:Say("Return to the Warrens and obtain eight of the bronze symbols worn by the kobolds greater shaman. Place them in this sack that has been blessed by the powers of Quellious to protect you from the evil influence of the evil symbols. Return the full sack with your initiate symbol of Quellious.");
		e.other:SummonItem(17090);
	elseif(e.message:findi("powerful kobold shaman") or e.message:findi("powerful kobold shamen") or e.message:findi("powerful shamen")) then
		e.self:Say("There have been sightings of kobold lesser shaman, greater shaman, and even a kobold high shaman. If you wish to continue Quellious' work take this sack and bring me eight of the odd bone necklaces worn by the lesser shaman.");
		e.other:SummonItem(17090);
	elseif(e.message:findi("ready to advance")) then
		e.self:Say("You are ready to strike at the body of the kobold shamans power. There is no reasoning with the Kobolds thus there shall be no peace in our beloved lands until their devotion to their wicked deity ceases. Return once again to the Warrens and bring me the unholy symbol worn by the High Shaman.");
	elseif(e.message:findi("kobold shaman")) then
		e.self:Say("The kobold shamans have learned to heal their kin. Will you [slay the kobold shaman] for our temple?");
	elseif(e.message:findi("guild coin")) then
		e.self:Say("Yes, of course. Here it is. Remember that it is not a form of currency.");
		e.other:SummonItem(13989); -- Item: Peacekeeper Token
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18723})) then --  Tattered Note
		e.self:Say("Greetings. and welcome to the Temple of Divine Light! Here is your guild tunic. Serve Quellious well.");
		e.other:SummonItem(13546); --  Faded Silver Tunic*
		e.other:Ding();
		e.other:Faction(298,100,0); --  Peace Keepers.
		e.other:Faction(266,25,0); --  High Council of Erudin.
		e.other:Faction(265,-25,0); --  Heretics.
		e.other:AddEXP(100); 
	elseif(item_lib.check_turn_in(e.trade, {item1 = 2049})) then --  rolled up strip of cloth
		e.self:Say("This is important news indeed. It seems there is a tribe of cat men in the Stonebrunt Mountains that wishes to form an alliance with Erudin. I must alert the High Council of this immediately, thank you for your services."); 
		e.other:AddMoneyToPP(9, 0, 0, 0, true);
		e.other:Faction(298,5,0); --  Peace Keepers.
		e.other:Faction(266,5,0); --  High Council of Erudin.
		e.other:Faction(265,-5,0); --  Heretics.
		e.other:AddEXP(1000);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13883, item2 = 13883, item3 = 13883})) then
		e.self:Say("Fine work. These paws prove your service to our temple. Accept this small reward, then help us investigate the [more powerful kobold shamen].");
		e.other:SummonItem(eq.ChooseRandom(15213, 15011));
		e.other:Ding();
		e.other:Faction(298,20,0);
		e.other:Faction(266,5,0);
		e.other:Faction(265,-5,0);
		-- Retain upstream XP where P99 provides no exact amount. The cached
		-- walkthrough documents a 17-silver payment; use that fixed amount.
		e.other:AddEXP(500);
		e.other:AddMoneyToPP(0,17,0,0);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 14582})) then
		e.self:Say("I am unfamiliar with the markings that adorn these necklaces. You have done well thus far in hindering the kobolds worship of their evil deity. I award you the Initiate Symbol of Quellious. Return to me when you feel you are ready to deal with the [greater kobold shaman].");
		e.other:SummonItem(1564);
		e.other:Ding();
		-- P99 confirms XP/faction without amounts for this stage. Use the
		-- preceding temple quest's modest reward rather than invent a new scale.
		e.other:Faction(298,20,0);
		e.other:Faction(266,5,0);
		e.other:Faction(265,-5,0);
		e.other:AddEXP(500);
	-- The real level gate must run before check_turn_in consumes anything.
	elseif(e.other:GetLevel() >= 20 and item_lib.check_turn_in(e.trade, {item1 = 14583, item2 = 1564})) then
		e.self:Say("Your service to this temple is commendable. I award you the rank of Disciple for your devotions to The Tranquil. When you are [ready to advance] return to me and I will set you upon another task.");
		e.other:SummonItem(1565);
		e.other:Ding();
		e.other:Faction(298,30,0);
		e.other:Faction(266,7,0);
		e.other:Faction(265,-7,0);
		e.other:AddEXP(500);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 14585})) then
		e.self:Say("It is imperative that we discern the nature of these symbols and the source of the kobolds shamanistic powers. There is a citizen of Erudin residing in Freeport named Glyssa Sonshaw. She is quite possibly the most knowledgeable individual in the field of heraldic and hieroglyphic studies. Take the high shamans necklace and this note to her. When you have discovered the nature of the symbols return to me with the documentation and your Disciple Symbol of Quellious.");
		e.other:SummonItem(14585);
		e.other:SummonItem(1772);
		e.other:Ding();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 1780, item2 = 1781, item3 = 1565})) then
		e.self:Say("You have done well yet again, young disciple. I award you the rank of Regent of the Peacekeepers. With this information we can hopefully gain some insight into the workings of the kobolds' religion.");
		e.other:SummonItem(1566);
		e.other:Ding();
		-- P99 gives directions, but not exact values here; retain upstream.
		e.other:Faction(298,20,0);
		e.other:Faction(266,20,0);
		e.other:Faction(265,-20,0);
		e.other:AddEXP(1000);
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

-- END of FILE Zone:erudnext  ID:98079 -- Leraena_Shelyrak
