-- Reviewed P99 Necromancer Epic 1.0: restore omitted quest directions.
-- Source: swampofnohope/Ssessthrass.pl
-- Necromancer Epic 1.0: Ssessthrass Manisi herb chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 20644, 20645, 20654, 20650

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("does not wish to be bothered.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20644}) then
		e.self:Say("Sssso, Emkel ssssent you to retrieve the manisi herb? I do not have the herb. The ssssarnak guard the herb. Apparently it is ssssacred to them. Only memberssss of their royal family are allowed to partake of it. They live deep in Chardok. They are hoarding what little of the precious herb there is. If you have an army, perhapssss you can bring me the herb and I can prepare it for Emkel. Bring back this ssssymbol as well.")
		e.other:Ding()
		e.other:AddEXP(500)
		e.other:SummonItem(20645) -- Scaled Symbol of the Serpent
	elseif item_lib.check_turn_in(e.trade, {item1 = 20654, item2 = 20645}) then
		e.self:Emote("looks at you and bows. 'You are truly a fearsome sssshadow weaver!'")
		e.other:Ding()
		e.other:AddEXP(1000)
		e.other:SummonItem(20650) -- Refined Manisi Herb
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
