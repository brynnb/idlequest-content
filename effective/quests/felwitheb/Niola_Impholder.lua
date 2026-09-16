-- Source: felwitheb/Niola_Impholder.lua
-- items: 13068, 15310, 15332, 18777, 13592, 18902, 1307
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18777)) then
		e.other:Message(MT.Yellow,"As you enter what seems to be a small bedroom, a beautiful High Elf woman looks your way. 'Hello. You have come for training in the ways of the Keepers of the Art? Very good. Please read the note in your inventory and when you are ready to begin, hand it to me.'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". Welcome to the home of the Keepers of the Art. I am in need of spell components. Would you be willing to [fetch] some for me?");
	elseif(e.message:findi("fetch")) then
		e.self:Say("What I need are some bat wings for a spell I am researching. If you bring me back four bat wings, I would be willing to reward you with a scroll.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 13068,item2 = 13068,item3 = 13068,item4 = 13068})) then
		e.self:Say("Ah yes.  These are exactly what I need.  Thank you very much.");
		e.other:SummonItem(eq.ChooseRandom(15310,15332)); -- Item(s): Spell: Flare (15310), Spell: Shield of Fire (15332)
		e.other:Ding();
		e.other:Faction(275,2,0); -- Faction: Keepers of the Art
		e.other:Faction(279,1,0); -- Faction: King Tearis Thex
		e.other:Faction(246,1,0); -- Faction: Faydarks Champions
		e.other:Faction(239,-1,0); -- Faction: The Dead
		e.other:AddEXP(40);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 18777})) then -- Enrollment Letter
		e.self:Say("Welcome. I am Niola Impholder. Master Magician of the Keepers of the Art. Here is our guild tunic. Once you are ready to begin your training please make sure that you see Yuin Starchaser, he can assist you in developing your hunting and gathering skills.");
		e.other:SummonItem(13592); -- Faded Training Robe*
		e.other:Ding();
		e.other:Faction(275,100,0); -- Keepers of the Art
		e.other:Faction(279,25,0); -- King Tearis Thex
		e.other:Faction(246,15,0); -- Faydark's Champions
		e.other:Faction(239,-25,0); -- The Dead
		e.other:AddEXP(100);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 18902})) then
		e.self:Say("What? Not as supposed? What can he... Well, that's all well and good. You, I assume, wish a reward for your 'valiant work'? Well, here you go, adventurer.");
		e.other:SummonItem(1307); -- Item: Gossamer Robe
		e.other:Ding();
		e.other:AddEXP(30000);
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

--END of FILE Zone:felwitheb  ID:62021 -- Niola_Impholder
