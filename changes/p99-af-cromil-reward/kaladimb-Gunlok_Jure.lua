-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Gunlok_Jure.pl
-- items: 13073, 2116, 2122, 5013, 5014, 5016, 5023, 6011, 13002, 13003, 13332, 15209

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetName() .. "!  Bow before the greatness of the Clerics of Underfoot!  It is good to be a paladin in such an order as ours - to fight the good fight and defend Kaladim from the evil and undead.  If you be a paladin, then I pray you find the [courage to battle the undead].")
	elseif e.message:findi("courage") then
		e.self:Say("Yes!!  To battle the undead is our greatest call.  There has been a rise in the number of dwarven skeletons seen in the Butcherblocks.  If you are a true member of this order, I shall reward you for the return of four bone chips.  We shall defend our land from evil!")
	elseif e.message:findi("remains of cromil") then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("My brother Cromil ventured to the Plains of Karana on the continent of Antonica. He never returned. Rumor has it that his undead skeleton is now part of an undead army in the plains. To end this curse, I ask all good paladins of this temple to return his bones to me. Nothing less than a spell is my reward for such a deed.")
		else
			e.self:Say("The Clerics of Underfoot have yet to see your faith directed towards our wills. Perhaps you should assist Master Gunlok Jure in the crusade against the undead.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13073, item2 = 13073, item3 = 13073, item4 = 13073}) then
		e.self:Say("You have done well. We thank you for your deed with this humble reward. The power behind the raising of our dead shall soon be found. You will earn more respect with more bone chips. I only wish you could assist in the return of the [remains of Cromil].")
		e.other:SummonItem(eq.ChooseRandom(2113, 2114, 2115, 2116, 2117, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 5014, 5016, 5023, 6011, 13002, 13003))
		e.other:Ding()
		e.other:GiveCash(6, 15, 0, 0)
		e.other:Faction(227, 10, 0)
		e.other:Faction(274, 10, 0)
		e.other:Faction(293, 7, 0)
		e.other:AddEXP(250)
	elseif e.other:GetFaction(e.self) <= 4 and item_lib.check_turn_in(e.trade, {item1 = 13332}) then
		e.self:Say("Many thanks, my friend. Now my brother can rest in peace. Please take this spell. May it serve you well.")
		e.other:Ding()
		e.other:Faction(227, 25, 0)
		e.other:Faction(274, 25, 0)
		e.other:Faction(293, 25, 0)
		e.other:AddEXP(10000)
		e.other:GiveCash(0, 0, 2, 0)
		-- P99 completion report says Spook the Dead; header says Hammer of Wrath.
		-- Prefer observed completion; previous Flash of Light was unsupported by either.
		e.other:SummonItem(15209)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
