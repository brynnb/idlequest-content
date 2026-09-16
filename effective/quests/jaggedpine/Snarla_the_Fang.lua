-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/Snarla_the_Fang.pl
-- items: 8199, 8270, 17263, 9228, 8258, 9229, 8261, 9230, 8257

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Shhh. quiet! This is place of solitude and peace! You [respect temple] while you here if you know what good for you!")
	elseif e.message:findi("respect temple") then
		e.self:Say("One way guests show respect is to bring the host [food]. Something really good would be nice.")
	elseif e.message:findi("food") then
		e.self:Say("Lessee. . . Dryad Pate is what I want. Bring me some [Dryad Pate] and then you be a good guest. Maybe then I return a favor for you.")
	elseif e.message:findi("dryad pate") then
		e.self:Say("I don't know how it made. Talk to the Brargus about it. He the cook.")
	elseif e.message:findi("necklace") then
		e.self:Say("I make many different kinds of necklaces for my friends. Give me your token of friendship and I give you a pouch. Stuff I need is one Anaconda Skin and three matching Wolf, Bear, or Panther Fangs.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8199}) then
		e.self:Say("Ohh. . . This really good, thanks! You take this token of friendship. I can make nice [necklaces] for my friends.")
		e.other:SummonItem(8270)
		e.other:Faction(1598, 50, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 8270}) then
		e.self:Say("Ok, here pouch to collect stuff. Come back when pouch full. Make sure you seal pouch or stuff may fall out.")
		e.other:SummonItem(8270)
		e.other:SummonItem(17263)
	elseif item_lib.check_turn_in(e.trade, {item1 = 9228}) then
		e.self:Say("Oh hello friend, I make this nice necklace for you! You wear this and feel the spirit of the wolf run through you!")
		e.other:SummonItem(8258)
		e.other:Faction(1598, 50, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 9229}) then
		e.self:Say("My friend returns again! I make this nice necklace for you. Wear this and feel the essence of the bear flow through you.")
		e.other:SummonItem(8261)
		e.other:Faction(1598, 50, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 9230}) then
		e.self:Say("Hello again friend. This nice panther fang, here you take this necklace I make you. It imbued with spirit of the cat.")
		e.other:SummonItem(8257)
		e.other:Faction(1598, 50, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
