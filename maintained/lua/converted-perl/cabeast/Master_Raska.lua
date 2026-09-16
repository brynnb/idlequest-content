-- Source: cabeast/Master_Raska.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 17026, 12427, 4191, 4190, 12428, 4192, 18469, 12822, 7881, 18470, 22924, 18232, 18233, 12429

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hmmph!! Expect to be a great master such as I? Maybe. You still appear to be a whiff.")
	elseif e.message:findi("whiff") then
		e.self:Say("A whiff is the sound of a tail striking air. A whiff is you. Inexperienced. I can help you, if you want to earn the second shackle.")
	elseif e.message:findi("second shackle") then
		e.self:Say("Then you shall perform the first rite. Take this pack. To the Outlands you will go. You will fill and combine the pack with one of each of the following: goblin scout beads, a large scorpion pincer, a froglok skipper skipping stone, and a sabertooth cub canine. Bring these to me and you shall prove yourself a monk.")
		e.other:SummonItem(17026) -- First Rite Pack
	elseif e.message:findi("shackle of stone") then
		e.self:Say("Interested in the shackle of stone are we? They are made for monks who have earned their first two shackles and are ready to climb up to the next rung. A monk who feels he is ready to wear the shackle of stone must first perform the task of cleansing.")
	elseif e.message:findi("task of cleansing") then
		e.self:Say("Go forth to the outer gates and seek out the Iksar bandits. They have refused to bow to the will of the empire and shall pay dearly for their traitorous ways. They often wear bandit masks. If you return with two bandit masks and the shackles of dust and clay then I shall reward you with the shackle of stone.")
	elseif e.message:findi("gandan tailfist") then
		e.self:Say("Gandan Tailfist was a powerful commander of the Court of Pain. He went in search of the Whistling Fists, but all that was ever found of him was a worthless flute.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12427}) then
		e.self:Say("You have succeeded, young " .. e.other:GetName() .. "! You have proven yourself a skilled monk. You will now wear the shackle of clay. You will now be required to increase your intensity of training in hopes that you may soon be able to earn your shackle of stone.")
		e.other:SummonItem(4191) -- Shackle of Clay
		e.other:AddEXP(5000)
		e.other:Ding()
		e.other:Faction(444, 10)
		e.other:Faction(441, 2)
		e.other:GiveCash(0, 0, 5, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4190, item2 = 4191, item3 = 12428, item4 = 12428}) then
		e.self:Say("You have done supremely, " .. e.other:GetName() .. ". You have earned your shackle of stone. Mistress Niska will now help you on your way to earning the shackle of rock. May the elements guide you to the next rung.")
		e.other:SummonItem(4192) -- Shackle of Stone
		e.other:AddEXP(10000)
		e.other:Ding()
		e.other:Faction(444, 10)
		e.other:Faction(441, 2)
		e.other:GiveCash(0, 0, 6, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18469, item2 = 12822}) then
		e.self:Emote("smiles at your dedication to Cazic Thule and hands you a small gem.")
		e.other:SummonItem(7881) -- Mark of Clarity
		e.other:AddEXP(20000)
		e.other:Ding()
		e.other:Faction(444, 20)
		e.other:Faction(441, 10)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18470, item2 = 22924}) then
		e.self:Emote("smiles at your dedication to Cazic Thule and hands you a small gem.")
		e.other:SummonItem(7881) -- Mark of Clarity
		e.other:AddEXP(20000)
		e.other:Ding()
		e.other:Faction(444, 20)
		e.other:Faction(441, 10)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18232, item2 = 18233}) then
		e.self:Say("This is all that was ever found of Gandan Tailfist. I wish you luck in your quest. May you fare better than he did.")
		e.other:SummonItem(12429) -- Ancient Thin Flute
		e.other:AddEXP(5000)
		e.other:Ding()
		e.other:Faction(444, 20)
		e.other:Faction(441, 10)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
