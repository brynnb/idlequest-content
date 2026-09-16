-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Captain_Nealith.pl
-- items: 12977, 13155, 18076, 12978

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail. adventurer!! Stand tall and fight for the forest folk and all good races of Norrath. We shall claim this land for the kingdom of Thex! My warriors shall not fail. Already we patrol deepin the wilds of Kunark. We welcome all mercenaries and urge adventurers to [join the defense of the outpost].")
	elseif e.message:findi("join the defense") then
		e.self:Say("I salute you!! Join the hunt. Reports from the front line indicate a rise in the drolvarg population. Abandon your fear and slay these beasts for the greater good. Already, they have taken far too many lives, even my sibling's!! I shall pay you your wages upon the return of four drolvarg teeth.")
	elseif e.message:findi("sibling") then
		e.self:Emote("appears saddened by the mention of his sibling. 'My brother Marltek has been missing for quite some time. I found coarse Drolvarg hair inside his tent which leads me to believe he has become a meal for the dogs. CURSE THE EVIL DOGS!! I shall see them all dead!!'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12977, item2 = 12977, item3 = 12977, item4 = 12977}) then
		e.self:Emote("tosses the teeth into a very large cask full of similar teeth.")
		e.self:Say("Fine work, " .. e.other:GetName() .. ". I wish all my own troops showed the same tenacity. I salute you. This will keep you well fed during your long patrols. Use your wages to better equip yourself. Continue the fight!! The General is pleased.")
		e.other:SummonItem(13155, 7)
		e.other:AddEXP(10000)
		e.other:GiveCash(13, eq.ChooseRandom(6, 7, 8, 9), eq.ChooseRandom(2, 3, 4, 5, 6, 7, 8, 9), 0)
		e.other:Faction(248, 1, 0)
		e.other:Faction(326, 1, 0)
		e.other:Faction(312, 1, 0)
		e.other:Faction(441, -3, 0)
		e.other:Faction(313, -3, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18076}) then
		e.self:Emote("nearly faints after reading the letter. 'Dear Marltek!! I shall miss you. There is more evil in this land!! Madness beyond description. Thank you " .. e.other:GetName() .. ". You put my soul at ease and give me new direction. Please accept my brothers blade. He found it in the wilds. May you use it to slay many Drolvarg!!'")
		e.other:AddEXP(25580)
		e.other:GiveCash(0, 0, 0, 14)
		e.other:SummonItem(12978)
		e.other:Faction(248, 50, 0)
		e.other:Faction(326, 50, 0)
		e.other:Faction(312, 50, 0)
		e.other:Faction(313, -50, 0)
		e.other:Faction(441, -50, 0)
	else
		e.self:Emote("holds the canine in his palm.")
		e.self:Say("Good work, but you will have to slay more than this to earn your wages.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
