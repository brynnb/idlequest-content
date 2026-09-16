-- Source: highpass/Barn_Bloodstone.lua
-- items: 13130, 18808
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("You seem a little out of place here. You should go back to the nice little village you came from. This place will eat you alive. The [Golden Rooster] is no place for you.");
	elseif(e.message:findi("blackburrow stout")) then
		e.self:Say("Blackburrow Stout is the finest drink available. It is the nectar of the gods. Well.. nectar of the gnolls at least. I can't wait until they hold another drink special in the Rooster. When I hear that. I am there!");
	elseif(e.message:findi("golden rooster")) then
		e.self:Say("The Golden Rooster only happens to be the finest gambling house in Highpass. It is also the only place in these parts that serves [Blackburrow Stout].");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(e.other:GetFaction(e.self) < 6 and item_lib.check_turn_in(e.trade, {item1 = 13130})) then -- Blackburrow Stout, no-drop delivery version
		e.self:Say("So Commander Kane has finally sent someone with my stout. Take this list back with you and be quick about it.");
		e.other:SummonItem(18808); -- Bayle List I
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
