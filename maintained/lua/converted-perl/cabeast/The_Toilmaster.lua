-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/The_Toilmaster.pl
-- items: 24767, 17091, 12660, 12689, 18271, 18272

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Do not bother me unless you wish to join the chain gang. Now go away or I shall have my slaves chop you as they chop this granite!")
	elseif e.message:findi("hammer of exoneration") then
		e.self:Emote("hands you a massive hammer and says, 'So, you can read. Good for you. Don't think that you're going to make an impression on me with that rubbish. Let's see if you can handle this hammer like you can that book, whelp.'")
		e.other:SummonItem(24767)
	elseif e.message:findi("bag") then
		e.self:Emote("turns his head to focus on you and hands you a dusty bag. He then returns to looking into the distance, just over your left shoulder.")
		e.other:SummonItem(17091)
	elseif e.message:findi("granite pebbles") then
		e.self:Say("Ah. Looking for granite pebbles, are we? You must be a Swifttail. I am tired of doing your caste's work when you give nothing in return. Tell you what, I have lost many slaves to escape. If you bash their heads in with your many skills and return at least two busted froglok shackles I will give you one pile of granite pebbles.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12660, item2 = 12660}) then
		e.self:Say("A deal is a deal. Here is one pile of granite pebbles. I hope you need more because I know there are more escaped froglok slaves.")
		e.other:SummonItem(12689)
		e.other:Faction(441, 2, 0)
		e.other:Faction(440, 2, 0)
		e.other:Faction(445, 2, 0)
		e.other:Faction(442, 2, 0)
		e.other:Faction(444, 2, 0)
		e.other:Ding()
		e.other:AddEXP(350)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18271}) then
		e.self:Emote("looks at the tome and speaks to you, scowling, 'Very well Broodling, I have a task for you. I should make you work at the feet of my Froglok Slaves, crushing granite, but the lore of the Brood has a specific rite for this situation. Take this book and learn the will of Cazic-Thule. Read it and ask me any questions that you may have before you start your penance. It would be a shame for you to fail at this task as well... though I wouldn't mind destroying you.")
		e.other:SummonItem(18272)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
