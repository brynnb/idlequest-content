-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/David.pl
-- items: 12311, 12301

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I, the keeper of the [Bracers of Ro], welcome you. Come and rest within our camp. You have nothing to fear while such righteous might is gathered.")
	elseif e.other:GetModCharacterFactionLevel(242) < 25 then
		e.self:Say("You and I are not one yet. Go to Erudin and serve the Deepwater Knights. When you can ask Lord Weligon if you are an [honored member] and he answers yes, then this is when we are one with Prexus.")
	elseif e.message:findi("bracers of ro") then
		e.self:Say("When you can swim the waters of Rathe and return two goblin nets from the elusive goblin net masters, then you will be rewarded the bracer mold.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:GetModCharacterFactionLevel(242) > 24 and item_lib.check_turn_in(e.trade, {item1 = 12311, item2 = 12311}) then
		e.self:Say("You have done well. Take the mold for the bracer. Go forth to speak with Thomas of [Lord Searfire]. Then all components shall be known.")
		e.other:SummonItem(12301)
		e.other:Faction(242, 20, 0)
		e.other:Faction(695, 3, 0)
		e.other:Faction(265, -3, 0)
	elseif e.other:GetModCharacterFactionLevel(242) > 24 and item_lib.check_turn_in(e.trade, {item1 = 12311}) then
		e.self:Say("Two Deepwater goblin nets are required.")
		e.other:SummonItem(12311)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
