-- Reviewed P99 Necromancer Epic 1.0: restore omitted quest directions.
-- Source: lakerathe/Emkel_Kabae.pl
-- Necromancer Epic 1.0: Emkel Kabae symbol advancement.
-- Converted from ProjectEQ Perl quest script.
-- items: 20643, 20649, 20644, 20650, 20647

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am Emkel Kabae, first apprentice to Kazen. If you have a symbol, tell me its name.")
	elseif e.message:findi("symbol of the serpent") then
		e.self:Say("There are more reagents to be gathered. The time draws near for our master's ascension. Travel to the lands of Kunark and seek out Ssessthrass. He is a very wise Iksar herbalist helping me in my endeavor to please Master Kazen. Be careful not to insult his speech, or you may end up dead before you serve your purpose to the master. Be sure to show him the symbol as proof or he may consider you dinner.")
	elseif e.message:findi("symbol of testing") then
		e.self:Say("You must ask the master about the symbol of testing. Do not hand the symbol to him for he may interpret that as a breach of conduct.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20643, item2 = 20649}) then
		e.self:Emote("reaches into his robes and pulls out a small symbol.")
		e.other:Ding()
		e.other:AddEXP(500)
		e.other:SummonItem(20644) -- Symbol of the Serpent
	elseif item_lib.check_turn_in(e.trade, {item1 = 20650}) then
		e.self:Say("You are truly worthy of studying with our master. Bear this new symbol and ask the master about the symbol of testing.")
		e.other:Ding()
		e.other:AddEXP(1000)
		e.other:SummonItem(20647) -- Symbol of Testing
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
