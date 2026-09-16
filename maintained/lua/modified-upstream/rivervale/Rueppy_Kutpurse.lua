-- Source: rivervale/Rueppy_Kutpurse.lua
-- items: 13032, 13131
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hello. " .. e.other:GetName() .. ".  Rueppy's my name.  Why don't you buy us something to [drink] and we can talk?");
	elseif(e.message:findi("drink")) then
		e.self:Say("How about a short beer?  That sounds good.");
	elseif(e.message:findi("blackburrow stout")) then
		e.self:Say("Blackburrow Stout is a special beer brewed by those dirty gnolls, the Sabertooths.  Of course to get it here in Rivervale, you have to [smuggle] it in.");
	elseif(e.message:findi("smuggle")) then
		e.self:Say("You interested in a little Job?  I need you to meet someone who is bringing me some stout.  He was supposed to meet me in the ruins on the other side of the Great Wall but I have other business to attend to.  His name is Gunrich.  You might have to wait for a while for him to show up, he will be skittish of a stranger.  Payment has already been made.  Just tell him. 'Dark rivers flow east,' and he will know you are legit.  Make sure you don't say anything else to him or the deal will sour.  Meet me back here with the stout.");
	elseif(e.message:findi("job")) then
		e.self:Say("You interested in a little Job?  I need you to meet someone who is bringing me some stout.  He was supposed to meet me in the ruins on the other side of the Great Wall but I have other business to attend to.  His name is Gunrich.  You might have to wait for a while for him to show up, he will be skittish of a stranger.  Payment has already been made.  Just tell him. 'Dark rivers flow east,' and he will know you are legit.  Make sure you don't say anything else to him or the deal will sour.  Meet me back here with the stout.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 13032})) then -- Short Beer
		e.self:Say("Oh, thank you. AH!  That sure is good.  Not as good as [Blackburrow Stout] but what is?");
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13131})) then -- Case of Blackburrow Stout
		e.self:Say("Heh heh! You did it! I thought the deputies would get you for sure! I mean..you did it! heh! Here go buy yourself a drink on me.");
		e.other:Ding();
		e.other:AddEXP(5000);
		e.other:GiveCash(4,4,0,0); -- 4 copper, 4 silver
		e.other:Faction(241,5,0); -- DeepPockets
		e.other:Faction(223,5,0); -- Circle of Unseen Hands
		e.other:Faction(292,-5,0); -- Merchants of Rivervale
		e.other:Faction(336,5,0); -- Coalition of Tradefolk Underground
		e.other:Faction(329,5,0); -- Carson McCabe
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:rivervale  ID:19064 -- Rueppy_Kutpurse
