-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/Vurgo.pl
-- P99 audits: Harvester Quest, Words of Darkness Quest
-- items: 5103, 18944, 10538, 7331, 10031, 5316, 10529, 18945, 10536, 10537, 10527

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome! I am Vurgo, follower of Solusek Ro and holder of the [harvester] and the [Words of Darkness].")
	elseif e.message:findi("harvester") then
		e.self:Say("I can forge you one, but you will need to bring me the correct [scythe components].")
	elseif e.message:findi("scythe components") then
		e.self:Say("The first thing I need is a shadowed scythe from our mortal enemies, the shadowed men.")
	elseif e.message:findi("words of darkness") then
		e.self:Say("I can scribe for you the Words of Darkness, but you will need to bring me the correct [word components].")
	elseif e.message:findi("word components") then
		e.self:Say("The first thing that I need is a shadowed book from our mortal enemies, the shadowed men.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 5103}) then -- Shadowed Scythe
		e.self:Say("A Shadowed Scythe - well done. The only good Shadowed Man is a banished one. As the weapons of the Shadowed Man have a tendency to disappears, I have given you a note to remind me that you have indeed supplied me with a Scythe. Give me the note with the following items and I will forge you a Harvester: A Fungus Eye from a Mortuary Fungus in the Estate of Unrest, A Shadowed Knife from an Island Goblin Headmaster in the Ocean of Tears and fire opal. Give me these items, and I will forge for you a Harvester.")
		e.other:SummonItem(18944) -- Note, VurgoHarv
		e.other:Faction(415, 1, 0) -- Temple of Solusek Ro
		e.other:Faction(416, -1, 0) -- Shadowed Men
		e.other:AddEXP(1000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 18944, item2 = 10538, item3 = 7331, item4 = 10031}) then -- VurgoHarv note, Fungus Eye, Shadowed Knife, Fire Opal
		e.self:Say("All of the necessary components for me to forge a Harvester! Very good, adventurer. Take your scythe, you have earned it.")
		e.other:SummonItem(5316)
		e.other:Faction(415, 1, 0) -- Temple of Solusek Ro
		e.other:Faction(416, -1, 0) -- Shadowed Men
		e.other:AddEXP(1000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 10529}) then -- Shadowed Book
		e.self:Say("A shadowed book! Well done! The more banished shadowed men the better. As the items of the shadowed men tend to disappear, I have given you a note to remind me that you have indeed supplied me with a book. Give me the note with the following items, and I will scribe for you Words of Darkness: a book of darkness from the Erudites in the tower by Lake Rathe, a book of frost from the icy goblin in Permafrost Keep and 300 golden coins. Bring me these items, and I will scribe for you the Words of Darkness.")
		e.other:SummonItem(18945) -- Note, VurgoWord
		e.other:Faction(415, 1, 0) -- Temple of Solusek Ro
		e.other:Faction(416, -1, 0) -- Shadowed Men
		e.other:AddEXP(1000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 18945, item2 = 10536, item3 = 10537, gold = 300}) then -- VurgoWord note, Book of Darkness, Book of Frost, 300 gold
		e.self:Say("All of the necessary components for me to scribe the Words of Darkness! Very good, adventurer. Take your tome, you have earned it.")
		e.other:SummonItem(10527)
		e.other:Faction(415, 1, 0) -- Temple of Solusek Ro
		e.other:Faction(416, -1, 0) -- Shadowed Men
		e.other:AddEXP(1000)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
