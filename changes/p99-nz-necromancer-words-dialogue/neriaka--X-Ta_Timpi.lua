-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/X-Ta_Timpi.pl
-- items: 7036, 10019, 10517, 11835, 1343, 10020, 10515, 11837, 13151, 10298, 10024, 11865, 10521, 10021, 10519, 11851

local function necro_word_reward(e, item_id)
	e.self:Say("You have quested well - With spell and sword - Accept our thanks - And this reward.")
	e.other:SummonItem(item_id)
	e.other:Faction(239, 10, 0)
	e.other:Faction(303, 10, 0)
	e.other:Faction(278, -10, 0)
	e.other:Faction(275, -10, 0)
	e.other:Faction(245, -10, 0)
	e.other:Faction(1522, -10, 0)
	e.other:AddEXP(62000)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("We three are the [Sisters Dark] - [Necromancy] is our Art - Bonded dead, they serve our will - No beat of heart, yet faithful still.")
	elseif e.message:findi("sisters dark") then
		e.self:Say("We three are the Sisters Dark - Keepers of the shadowed Dread - [Lore of Death]. we research now - Join with us and serve [the Dead].")
	elseif e.message:findi("lore of death") or e.message:findi("hid") or e.message:lower() == "words" or e.message:lower() == "word" then
		e.self:Say("The Words are hid in tomes of old. We need [components] for research.")
	elseif e.message:findi("components") then
		e.self:Say("We need components for research - In return for [tasks] that you perform - Words of [reward] we have in mind.")
	elseif e.message:findi("tasks") or e.message:findi("reward") then
		e.self:Say("Bring us components for our research - We give [Word]s by tasks performed - [Possession], [Detachment], [Allure], [Haunting], [Rupturing], [Dark Paths], [Suffering], [Collection], [Obligation], [Requisition] and [Acquisition].")
	elseif e.message:findi("detachment") then
		e.self:Say("From the Estate of Unrest, bring dull bone chips - From Castle Mistmoore, a dagger charred - From a merchant bring a stone of blood - Words of Detachment will be your reward.")
	elseif e.message:findi("rupturing") then
		e.self:Say("From the Estate of Unrest, bring a festering cloak - From Castle Mistmoore, ebon wands - From a merchant bring a jasper stone - Then Words of Rupturing will to you be given.")
	elseif e.message:findi("requisition") then
		e.self:Say("From the Plane of Fear, bring an Eye of Fright and a Stone of the Wraith - From a merchant bring a pearl - Then Words of Requisition will to you be given.")
	elseif e.message:findi("suffering") then
		e.self:Say("From Befallen, bring Iced Bone Chips - From spectres, bring a Globe of Fear - From a merchant bring a Star Rose Quartz - Then Words of Suffering will to you be given.")
	elseif e.message:findi("words of") or e.message:findi("possession") or e.message:findi("detachment") or e.message:findi("allure") or e.message:findi("haunting") or e.message:findi("rupturing") or e.message:findi("dark paths") or e.message:findi("suffering") or e.message:findi("collection") or e.message:findi("obligation") or e.message:findi("requisition") or e.message:findi("acquisition") then
		e.self:Say("The answer to that question is held by another - Ask again of my sister...")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 7036, item2 = 10019, item3 = 10517, item4 = 10517}) then
		necro_word_reward(e, 11835)
	elseif item_lib.check_turn_in(e.trade, {item1 = 1343, item2 = 10020, item3 = 10515, item4 = 10515}) then
		necro_word_reward(e, 11837)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13151, item2 = 10298, item3 = 10024}) then
		necro_word_reward(e, 11865)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10521, item2 = 10021, item3 = 10519, item4 = 10519}) then
		necro_word_reward(e, 11851)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
