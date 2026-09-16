-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/#Jeremy_Leafrunner.pl
-- items: 8969, 8970

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello there " .. e.other:GetName() .. ". Nice day today isn't it? We really appreciate the help that the city of Qeynos has offered us in defense of [Fort Jaggedpine].")
	elseif e.message:findi("Fort Jaggedpine") then
		e.self:Say("That's the name my grandfather and grandmother gave to this place. Are you [planning a trip to Felwithe] any time soon?")
	elseif e.message:findi("planning a trip to Felwithe") then
		e.self:Say("Hey that's great. I don't see much of my grandmother these days, would you be [willing to deliver a letter] to her?")
	elseif e.message:findi("willing to deliver a letter") then
		e.self:Say("Thanks a bunch, I really appreciate it! Here take this to her. Her name is Elishia.")
		e.other:SummonItem(8969)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8970}) then
		e.self:Say("Thank you! It is great to hear from my grandmother.")
		e.other:Faction(1597, 20, 0)
		e.other:Faction(272, 20, 0)
		e.other:Faction(302, 20, 0)
		e.other:Faction(262, 20, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
