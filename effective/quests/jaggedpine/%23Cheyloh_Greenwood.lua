-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/#Cheyloh_Greenwood.pl
-- items: 8790, 8769, 8442, 8796, 8795, 8445, 8877, 8876, 8758, 8865, 8864, 8499, 8871, 8870, 8757, 8883, 8882, 8759

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("gives a warm smile")
		e.self:Say("Greetings traveler and welcome to Fort Jaggedpine. If you have need of my [wares or talents], then please do not hesitate to inquire.")
	elseif e.message:findi("wares or talents") then
		e.self:Say("Here in the Jaggedpine, I serve as a seamstress. My talents aid in weaving pieces of an [ancient suit of leather] worn by dedicated druids.")
	elseif e.message:findi("ancient suit of leather") then
		e.self:Say("The armor is acquired upon a [path of devotion] successfully walked by our most devoted druids.")
	elseif e.message:findi("path of devotion") then
		e.self:Say("One must protect nature to the fullest of their abilities. Once that druid has [proven themselves worthy], I aid in the final steps to create the armor.")
	elseif e.message:findi("prove myself worthy") then
		e.self:Emote("raises a brow and gives another gentle smile toward " .. e.other:GetName())
		e.self:Say("There are several individual [pieces] to this mystic suit of armor.")
	elseif e.message:findi("pieces") then
		e.self:Say("I can create the [leggings], [sleeves], [bracer], [boots], [gloves], and [circlet] of the Armor of the Pine.")
	elseif e.message:findi("leggings") then
		e.self:Say("You will need to return [Polished Jade Acorns] and [Moss Threaded Rawhide Leggings].")
	elseif e.message:findi("polished jade acorns") then
		e.self:Say("The Blackguard family stole many sacred stones. Scouts say Myraephe the Pure now wears a necklace made of Polished Stone Acorns.")
	elseif e.message:findi("rawhide leggings") then
		e.self:Say("Venture to Surefall Glade and speak with Lerian Wyndrunner about Moss Threaded Rawhide Leggings.")
	elseif e.message:findi("sleeves") then
		e.self:Say("Return Polished Jade Leaves and Shark Tooth Sleeves.")
	elseif e.message:findi("boots") then
		e.self:Say("Return Mithril Fern Boots and two Polished Jade Plates.")
	elseif e.message:findi("bracer") then
		e.self:Say("Return Polished Jade Blossoms and the Bracer of Braided Pine.")
	elseif e.message:findi("gloves") then
		e.self:Say("Return Polished Jade Studs and Forest Woven Gloves.")
	elseif e.message:findi("circlet") then
		e.self:Say("Return a Polished Jade Tear and a Shadowjade Circlet.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8790, item2 = 8769}) then
		e.self:Emote("smiles warmly at " .. e.other:GetName())
		e.self:Say("Excellent work, friend. I have sewn the Polished Jade Acorns into your leggings. May they serve you as well as you have served the natural world.")
		e.other:SummonItem(8442)
	elseif item_lib.check_turn_in(e.trade, {item1 = 8796, item2 = 8795}) then
		e.self:Say("Marvelously done, my friend. I have bound the moss thread to the Polished Jade Leaves and your sleeves are complete.")
		e.other:SummonItem(8445)
	elseif item_lib.check_turn_in(e.trade, {item1 = 8877, item2 = 8876, item3 = 8876}) then
		e.self:Say("Aaaah. . . these will do nicely. You have earned this reward justly.")
		e.other:SummonItem(8758)
	elseif item_lib.check_turn_in(e.trade, {item1 = 8865, item2 = 8864}) then
		e.self:Say("Marvelously done, my friend. I have bound the braided pine to the Polished Jade Blossoms and your bracer is complete.")
		e.other:SummonItem(8499)
	elseif item_lib.check_turn_in(e.trade, {item1 = 8871, item2 = 8870}) then
		e.self:Say("Well done, " .. e.other:GetName() .. ". The Jade Studs have been easily bound to the enchantment of the Forest Woven Gloves.")
		e.other:SummonItem(8757)
	elseif item_lib.check_turn_in(e.trade, {item1 = 8883, item2 = 8882}) then
		e.self:Say("Marvelously done, my friend. I have bound the shadowjade circlet to the Polished Jade Tear.")
		e.other:SummonItem(8759)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
