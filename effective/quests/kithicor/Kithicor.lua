-- Converted from ProjectEQ Perl quest script.
-- Source: kithicor/Kithicor.pl
-- items: 20877, 20878
-- Retain Call of Flame; omit the later rogue epic 1.5 orb branch.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello Traveler, I do not see many this deep into the woods.")

	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20877}) then
		e.self:Say("Wow, this is certainly something I have not seen in a long time. It was said that this species of snake had been wiped out due to the poachers and griffins. It was very noble of you to help in saving this species. I will see that these are raised properly. Please wear this icon with pride so other rangers will know of the good deed you have done.")
		e.other:Faction(269, 50, 0)
		e.other:Faction(302, 50, 0)
		e.other:Faction(272, 50, 0)
		e.other:Faction(324, 50, 0)
		e.other:AddEXP(1000)
		e.other:Ding()
		e.other:SummonItem(20878)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
