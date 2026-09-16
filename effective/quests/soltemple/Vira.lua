-- Source: soltemple/Vira.pl
-- Magician Sol Ro focus tools.
-- Converted from ProjectEQ Perl quest script. Later LoY-era Vera hand-ins are intentionally omitted.
-- items: 16544, 16543, 16538, 10032, 6360, 10035, 10014, 16545, 16539, 6361, 16540, 16542, 10034, 16547, 6363, 16546, 16534, 10033, 16541, 6362

local function temple_faction(e)
	e.other:AddEXP(1000)
	e.other:Faction(415, 15, 0) -- Temple of Solusek Ro
	e.other:Faction(416, -15, 0) -- Shadowed Men
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am Vira, elementalist of Solusek Ro. I guard the secrets of the tools of [elemental summoning]. If you are a magician, you might be interested.")
	elseif e.message:findi("elemental summoning") then
		e.self:Say("I hold the secrets to the construction of four tools which assist magicians with the summoning of elementals. I know about the [broom of Trilon], the [shovel of Ponz], the [torch of Alna] and the [stein of Ulissa].")
	elseif e.message:findi("broom of trilon") then
		e.self:Say("The broom of Trilon was held by the infamous Mistress of Air of the same name. Are you [interested in the broom]?")
	elseif e.message:findi("interested") and e.message:findi("broom") then
		e.self:Say("I will construct a replica of the broom of Trilon for you, but I will need the following components to make it: a star ruby; a feather from a griffon, a broom from a magician in Najena and the toes of a cyclops. Bring me these four components, and I will fashion for you an object of elemental power.")
	elseif e.message:findi("shovel of ponz") then
		e.self:Say("The shovel of Ponz was crafted by the earthen master of the same name. Are you [interested in the shovel]?")
	elseif e.message:findi("interested") and e.message:findi("shovel") then
		e.self:Say("I will create a replica of the shovel of Ponz for you, but I will need the following components to make it: a ruby, the eyes of a gargoyle, a shovel from a magician in Najena and the toes of a hill giant. Bring me these four components, and I will construct for you an object of elemental power.")
	elseif e.message:findi("stein of ulissa") then
		e.self:Say("The stein of Ulissa was found and used by the mistress of water of the same name. Are you [interested in the stein]?")
	elseif e.message:findi("interested") and e.message:findi("stein") then
		e.self:Say("I will devise a replica of the stein of Ulissa for you, but I will need the following items to make it: a sapphire, a scale from a mermaid, a stein from a magician in Najena and the toes of an ice giant. Bring me these four components, and I will make for you an object of elemental power.")
	elseif e.message:findi("torch of alna") then
		e.self:Say("The torch of Alna was constructed and held by the fire mistress of the same name. Are you [interested in the torch]?")
	elseif e.message:findi("interested") and e.message:findi("torch") then
		e.self:Say("I will make a replica of the torch of Alna for you, but I will need the following items to make it: a fire emerald, a scale from a fire drake, a torch from a magician in Najena and the toes of a fire giant. Bring me these four components, and I will build for you an object of elemental power.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 16544, item2 = 16543, item3 = 16538, item4 = 10032}) then
		e.self:Say("All of the components to make the infamous broom of Trilon! Well done, adventurer. As you have proven yourself worthy, I grant you this broom.")
		e.other:SummonItem(6360) -- Broom of Trilon
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10035, item2 = 10014, item3 = 16545, item4 = 16539}) then
		e.self:Say("Each of the four items needed to construct the famed Shovel of Ponz! Very well. As you have displayed ingenuity, I grant you this shovel.")
		e.other:SummonItem(6361) -- Shovel of Ponz
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 16540, item2 = 16542, item3 = 10034, item4 = 16547}) then
		e.self:Say("The four components required for the stein of Ulissa?! I am impressed! As you have displayed valor, I grant you this stein.")
		e.other:SummonItem(6363) -- Stein of Ulissa
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 16546, item2 = 16534, item3 = 10033, item4 = 16541}) then
		e.self:Say("All of the pieces of the famous Torch of Alna! I never thought you would find them all! As you have displayed courage, I grant you this torch.")
		e.other:SummonItem(6362) -- Torch of Alna
		temple_faction(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
