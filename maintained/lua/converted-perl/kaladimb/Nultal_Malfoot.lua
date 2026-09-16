-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Nultal_Malfoot.pl
-- P99 audit: Skunk Hunting
-- items: 14030, 15203, 15207, 15229, 15201, 15560, 15036, 15011, 15208, 15216

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("May the power of Underfoot be with you. Welcome. I am here to serve the will of the king as should you. If you [need healing], then speak. Or perhaps you are here to [return skunk glands]?")
	elseif e.message:findi("need healing") then
		e.self:Say("Before the power of Underfoot can attempt to bind your wounds you must pay tribute. Three gold coins!!")
	elseif e.message:findi("return skunk glands") then
		e.self:Say("I have made an offer to all clerics of this cathedral. I shall reward one cleric scroll from our scribes for the return of four skunk scent glands. This offer is best left to our clerics.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {gold = 3}) then
		e.self:Say("May your body and soul be rejuvenated.")
		e.self:CastSpell(17, e.other:GetID())
	elseif item_lib.check_turn_in(e.trade, {item1 = 14030, item2 = 14030, item3 = 14030, item4 = 14030}) then
		if e.other:GetFaction(e.self) >= 5 then
			e.self:Say("I have made an offer to all clerics of this cathedral. This offer is best left to those with stronger standing among the Clerics of Underfoot.")
			e.other:SummonItem(14030, 4)
		else
			e.self:Say("I thank you for your good deed. I trust it was not a problem. Take this scroll. A cleric of this cathedral will find it useful. May the power of Underfoot be with you.")
			e.other:SummonItem(eq.ChooseRandom(15203, 15207, 15229, 15201, 15560, 15036, 15011, 15208, 15216))
			e.other:Faction(227, 5, 0)
			e.other:Faction(274, 5, 0)
			e.other:Faction(293, 5, 0)
			e.other:AddEXP(2000)
			e.other:GiveCash(0, 5, 0, 0)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
