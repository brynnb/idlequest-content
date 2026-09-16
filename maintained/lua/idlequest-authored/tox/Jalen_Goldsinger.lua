-- P99 source: Azraxs' Legacy
-- items: 7113, 7112

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("A fine day. Quite murky and quiet is it not? May your path be filled with fortunes. Be well.");
	elseif(e.message:findi("crystal of capturing")) then
		e.self:Say("Hrm? A crystal of capturing? Aye. I do know the secret of their making. Not that I would tell you. I will, however, create one for you. Provided you bring some of their components and a large coin reserve that is. I require a [Potion of Sorrow] and 1000 gold coins. A tidy sum and for which I will do you the favor of not asking why you need such a... dark item.");
	elseif(e.message:findi("potion of sorrow")) then
		e.self:Say("An interesting little concoction. Gorth Bearsoul is the only alchemist I know of who can make such an item. Loud and quite smelly, he is. Not unusual for a barbarian. He calls the icy city of Halas home.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 7113, gold = 1000})) then -- Potion of Sorrow and 1000 gold
		e.self:Say("You surprise me. There is only a few uses for such a dark item. I need not know which you intend, as was our bargain. Here.");
		e.other:SummonItem(7112); -- Empty Crystal Sphere
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
