-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Trooper_Selbat.pl
-- items: 18248, 18249

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Good evening, citizen! It is a fine night for a stroll, but not in the woods. No, no! That would be far too dangerous!")
	elseif e.message:findi("sign the restraining order") or e.message:findi("sign this restraining order") then
		e.self:Say("I knew this time would come. I will slay you for bringing this to me... No... I'd best not make the officers angry. <sigh> Hand me the order and I shall sign it.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18248}) then
		e.self:Emote("signs the note and hands back to you. 'Be off now. Before I do choose to slay the messenger.'")
		e.other:SummonItem(18249)
		e.other:AddEXP(200)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
