-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/Joyce.pl
-- items: 2358, 2359, 2357, 1356

local function temple_faction(e)
	e.other:Faction(415, 15, 0)
	e.other:Faction(416, -15, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am Joyce of the Temple of Solusek Ro. I am the guardian of four of the items of the elementalist. If you are a magician, ask me about the [Robe of the Elements], the [Clay Bracelet], the [Earthen Boots] or the [Circlet of Mist]")
	elseif e.message:findi("circlet of mist") then
		e.self:Say("The Circlet of Mist is a beautiful hoop that would look good atop your head. It produces a fine gleam, and is known to increase your mental power. Are you [interested in the circlet]?")
	elseif e.message:findi("interested in the circlet") then
		e.self:Say("I will be needing the proper components to craft the circlet of mist. I will be needing a Globe of Mist which can be found on festering hags, a Water Ring from a Tidal Lord in Dagnor's Cauldron, a Ring of Evoluoy from an alligator in Feerrott, and a Sapphire, I will craft it for you.")
	elseif e.message:findi("clay bracelet") then
		e.self:Say("The clay bracelet is a wonderful piece of jewelry to wear on your wrist. It provides fine protection, enhances your resistance to magic, and lets you call forth a mystic eye to help you in your travels. Are you [interested in the bracelet]?")
	elseif e.message:findi("interested in the bracelet") then
		e.self:Say("I will make you a clay bracelet, but you will need to bring me the proper components. I will need each of the four runes of clay. Three of them can be found in the Rathe Mountains, held by gnomish necromancers. The fourth one is somewhere in the Ocean of Tears, held by a goblin headmaster. Bring me these four components, and I will make you a clay bracelet.")
	elseif e.message:findi("earthen boots") then
		e.self:Say("Earthen Boots are a fine adornment for the feet of any Magician. They have a wonderful brown color, and are known to enhance the stamina of any Magician who wears them. As an added bonus, animals do not tend to notice those who wear Earthen Boots. Are you [interested in the boots]?")
	elseif e.message:findi("interested in the boots") then
		e.self:Say("I will make you a pair of earthen boots, but you will need to retrieve for me the proper components to craft these. I will be needing a Stone Marker which can be found on a Glyphed Guard in Castle Mistmoore, a Heart of Stone from a Stone Skeleton, a pair of Soiled Boots which can be found on a froglok Tonta Knight in Guk, and a Cats Eye Agate. Bring me these items and I will craft your earthen boots.")
	elseif e.message:findi("robe of the elements") then
		e.self:Say("The Robe of the Elements is a fine cloak for a Magician. It provides protection from the elements, protection from melee attacks and aids the Magician with her focus. Are you [interested in the robe]?")
	elseif e.message:findi("interested in the robe") then
		e.self:Say("I will make for you the Robe of the Elements, but I will be needing the proper components. I will be needing a fire goblin skin, a frost goblin skin, a Twice-Woven Cloak which can be found on Faerie Guards in the Faydark, and a scroll of elemental armor. Return to me with these items and I will craft your robe.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10545, item2 = 10547, item3 = 10034, item4 = 10546}) then
		e.self:Say("You have done well. You are truly a powerful magician. Here is your Circlet of Mist.")
		e.other:SummonItem(2358)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10539, item2 = 10542, item3 = 10540, item4 = 10541}) then
		e.self:Say("One, two, three.. all four runes of clay! I knew you looked competent. I am very impressed! Please take the Clay Bracelet that you have earned.")
		e.other:SummonItem(2359)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10543, item2 = 10026, item3 = 10544, item4 = 2363}) then
		e.self:Say("You have done well. You are truly a powerful magician. Here are your Earthen Boots.")
		e.other:SummonItem(2357)
		temple_faction(e)
		e.other:AddEXP(1000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 2361, item2 = 2362, item3 = 15109, item4 = 2360}) then
		e.self:Say("You have done well. You are truly a powerful magician. Here is your Robe of the Elements.")
		e.other:SummonItem(1356)
		temple_faction(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
