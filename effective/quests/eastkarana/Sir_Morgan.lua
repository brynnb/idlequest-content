-- Modified from ProjectEQ Lua.
-- Source: eastkarana/Sir_Morgan.lua
-- P99 audit: Sir Morgan's Armor
-- P99 removed experience and faction rewards from the 5 gold donation.
-- items: 2106, 2112, 2041, 13944, 2307, 3829, 1331, 17002, 7012, 8306, 10006, 10019, 5013, 5019, 5021, 5022, 6011, 5023, 7007, 7008

function event_waypoint_arrive(e)
	if(e.wp == 1) then
		e.self:Say("Hello, Wimbley, old chap!");
	elseif(e.wp == 8) then
		e.self:Say("Almost there...");
	elseif(e.wp == 9) then
		e.self:Say("Well, here we are! It is just a short jaunt through the pass ahead. Just remember to take the high road. I'm off, then. Good luck!");
		e.self:SetRunning(true);
	elseif(e.wp == 10) then
		e.self:SetRunning(false);
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail, traveler! Might I escort you through to Highpass? The path ahead is filled with giants and many other hungry beasts. I assure you, you will be safe with me. I must admit, I am quite experienced in the ways of the warrior. Do you [wish an escort] or will you [travel alone]?");
	elseif(e.message:findi("an escort")) then
		e.self:Say("I shall be honored to escort you to Highpass, but you shall have to wait for a spell. I make trips every few hours. I also would be grateful to any who wish to donate gold coins to the upkeep of my armor. The rains in the plains cause much rusting.");
	elseif(e.message:findi("travel alone")) then
		e.self:Say("Then, good luck to you! May your faith protect you. Or at the very least, guide you to a grand afterlife.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {gold = 5})) then
		e.self:Say("What a grand donation!! You must be a rich noble to be making such a donation. Here, I am but a simple warrior, but I found this lying on the highway to Highpass Hold. The lifeless corpse next to it had no more need of it.");
		e.other:SummonItem(eq.ChooseRandom(2106,2112,2041,13944,2307,3829,1331,17002,7012,8306,10006,10019,5013,5019,5021,5022,6011,5023,7007,7008));
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
