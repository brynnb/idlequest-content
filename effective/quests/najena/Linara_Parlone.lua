-- Converted from ProjectEQ Perl quest script.
-- Source: najena/Linara_Parlone.pl
-- items: 12269, 5573

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Please [help] me out of this horrid place! My family must be terribly worried!")
	elseif e.message:findi("help") then
		e.self:Say("If you can find the [key] to my restraints. I should be able to escape.")
	elseif e.message:findi("key") then
		e.self:Say("Last I knew, Najena's priest had the key. I fear he has left this place though. I heard talk of traveling to some estate. I know not where. Oh dear, oh dear! I shall never leave this place!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12269}) then
		e.self:Say("Oh thank you " .. e.other:GetName() .. "! I must make my escape now. Give this note to my father in Felwithe, he will reward you handsomely for your service.")
		e.other:SummonItem(5573)
		e.other:Faction(275, 10, 0)
		e.other:Faction(246, 1, 0)
		e.other:Faction(279, 2, 0)
		e.other:Faction(239, -2, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
