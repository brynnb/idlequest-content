-- Source: oot/Denken_Strongpick.pl
-- Warrior Epic 1.0: Denken Strongpick trades supplies for Ancient Sword Blade.
-- Converted from ProjectEQ Perl quest script.
-- items: 16889, 20665, 20664, 20667

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ". I am Denken Strongpick. I wish I could get off this rock, silly clan honor. My boss broke our rebreathers and we can not go back to the mainland before we gather some goblin relics.")
	elseif e.message:findi("goblin relics") then
		e.self:Say("There are supposedly goblin ruins around here somewhere. Fendlemend thinks we will find paydirt underwater. We did find one thing.")
	elseif e.message:findi("one thing") then
		e.self:Say("We found a very fine sword blade. I can't figure out what type of metal it is and I sure can't figure out what technique was used to forge it. Perhaps you would like to take it off my hands and buy it?")
	elseif e.message:findi("buy") then
		e.self:Say("Out here, money is fairly useless to me. I could sure use a few things from the mainland though.")
	elseif e.message:findi("use") then
		e.self:Say("I would be willing to part with this very fine blade for a keg of Vox tail ale, a block of permafrost to keep it cool and two new rebreathers to get this operation back underway.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 16889, item2 = 16889, item3 = 20665, item4 = 20664}) then
		e.self:Say("Excellent! Here is your sword. I feel like I'm at home already!")
		e.other:SummonItem(20667) -- Ancient Sword Blade
		e.other:AddEXP(50000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
