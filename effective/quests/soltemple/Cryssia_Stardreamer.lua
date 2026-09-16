-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/Cryssia_Stardreamer.pl
-- items: 10564, 10563, 10128, 4156, 4100, 10565, 10118, 4154, 10559, 4099, 10117, 4153, 4113, 10560, 10119, 4155

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Well met " .. e.other:GetName() .. ". I am Cryssia Stardreamer of the Temple of Solusek Ro, protector of a powerful armor that will aid any bard in their journey across Norrath. Are you a bard that desires this armor?")
	elseif e.message:findi("no") then
		e.self:Say("Very well then.")
	elseif e.message:findi("yes") then
		e.self:Say("Very well. I can craft a special type of bardic armor called lambent. I can craft for you a set of [bracers], a [breastplate], a [helm], and [vambraces]. I require a special kind of lambent stone for each of my armor pieces. Find my friends Orstorm, Genni, Gardern, and Vilissia within the temple and they will help you create them.")
	elseif e.message:findi("bracers") then
		e.self:Say("Alright, I will be needing some items. Return to me with them and I will craft your bracers. I will be needing a Dark Boned Bracelet, a Griffenne Charm, and a Lambent Fire Opal.")
	elseif e.message:findi("breastplate") then
		e.self:Say("This is the most difficult piece to make. In order for me to craft it I will be needing a Basalt Carapace, a Gypsy Lute, and a Lambent Ruby. Return to me with these and I will craft your breastplate.")
	elseif e.message:findi("helm") then
		e.self:Say("In order to craft the helm, I will be needing a Mudwater Rune, an Opoline Helm, and a Lambent Star Ruby. Give these items to me and I will craft your helm")
	elseif e.message:findi("vambraces") then
		e.self:Say("Very good, get me some Fiery Vambraces, the top portion of the Rune of the One Eye, and a Lambent Sapphire.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10564, item2 = 10563, item3 = 10128}) then
		e.self:Say("Well done. Here are your Lambent Bracers")
		e.other:SummonItem(4156)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4100, item2 = 10565, item3 = 10118}) then
		e.self:Say("Well done. Here is your Lambent Breastplate.")
		e.other:SummonItem(4154)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10559, item2 = 4099, item3 = 10117}) then
		e.self:Say("Well done. Here is your Lambent Helm")
		e.other:SummonItem(4153)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4113, item2 = 10560, item3 = 10119}) then
		e.self:Say("Well done. Here are your Lambent Vambraces.")
		e.other:SummonItem(4155)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
