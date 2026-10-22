-- IdleQuest starting guild note turn-in.
-- Source: cabeast/Prime_Hierophant_Vek.pl
-- items: 18206, 5140

function event_say(e)
	if e.message:findi("special potion") then
		e.self:Say("It is a most lecherous distillment and has been the savior of many. Making it is a complicated procedure and collecting the ingredients is a task not for the average scholar. First one must melt the rare [gray ice] in a pot and boil 2 [pondfish spines] until the poison is extracted. Then take the extraction along with a portion of Hopeless Willow Moss and brew this with plain water in a common bottle. After you have the potion force one of our froglok workers to drink it. As it suffers and its life melts into a puddle you must quickly collect the remains. Bring back the ultimate product of that suffering, along with 2 fire emeralds and you will know sacrifice.")
	elseif e.message:findi("gray ice") then
		e.self:Say("Gray ice is a very rare element found only atop the highest peaks in the region known as Frontier Mountains. It is valued for its very caustic nature and is used in many ways by our alchemists.")
	elseif e.message:findi("pondfish spines") then
		e.self:Say("There is a small spring that is the father of two streams. One leads to the ocean while the other is a tributary to the great Lake of Ill Omen. Due to the mineral-rich waters of the spring, many fish in the area have developed poison-based defenses. Some of the larger fish are adorned with spines that carry a deadly poison. These are the spines you must gather.")
	elseif e.message:findi("unique weapon") then
		e.self:Say("This goblin is known as a pit fighter. Though they are small, weak, and unintelligent, they still maintain a level of ferocity that surpasses that of most wild animals. This, along with a disgusting and perverse imagination, has allowed these pit fighters to reach heights of physical power most Iksar never see. This particular fighter uses his tongue liberally while fighting. He has ingested many deadly contagions and licked things from the slimy surfaces of the darkest and dankest crevasses imaginable. His tongue will do well to further our cause in pain and suffering.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18206}) then
		e.self:Say("Welcome, young petitioner. You have been summoned to this temple to join with the Scaled Mystics. Ours is the way of pain and suffering. Here is the weapon of a petitioner. Through you the power of our ancestors shall flow. As your wisdom grows, so shall your power. Someday you may be a vessel for the supreme might of the ancients. Seek knowledge with Oxyn, he is here to help you.")
		e.other:SummonItem(5140)
		e.other:AddEXP(500)
		e.other:Faction(445, 100, 0)
		e.other:Faction(441, 25, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 14790}) then
		e.self:Say("You spoke to the Brothers? You, a simple Legionnaire? You are here to test your virtue of sacrifice. There is a goblin famed for his [unique weapon]. Take this knife and return his weapon, the knife, a sapphire, and an opal to me.")
		e.other:SummonItem(14784)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14784, item2 = 14785, item3 = 10034, item4 = 10030}) then
		e.self:Say("We thank you. It is indeed a lovely specimen. Take your reference and leave this place.")
		e.other:SummonItem(14786)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14795}) then
		e.self:Say("The brothers still seek their redemption? You must brew a [special potion] for us and make use of it in the name of the Mystics.")
	elseif item_lib.check_turn_in(e.trade, {item1 = 14805, item2 = 10033, item3 = 10033}) then
		e.self:Say("Wonderful work, Legionnaire. Here is your reference. Remember the suffering you have caused in the name of your creator.")
		e.other:SummonItem(14787)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
