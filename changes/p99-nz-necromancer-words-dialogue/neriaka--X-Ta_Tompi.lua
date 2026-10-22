-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/X-Ta_Tompi.pl
-- items: 10083, 10035, 14160, 10019, 11829, 10520, 10523, 10021, 11850, 13150, 13152, 8331, 10024, 11866, 10521, 10525, 10023, 11863

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
	elseif e.message:findi("allure") then
		e.self:Say("From the Estate of Unrest, bring a Charred Pearl - From Castle Mistmoore, a wand charred - From a merchant bring a stone of blood and a ruby - Words of Allure will be your reward.")
	elseif e.message:findi("dark paths") then
		e.self:Say("From the Estate of Unrest, bring an globe of darkness - From Guk, an Eye of Urd - From a merchant bring a Star Rose Quartz - Then Words of Dark Paths will to you be given.")
	elseif e.message:findi("acquisition") then
		e.self:Say("From the Plane of Fear, bring Fetid Skin, Scare Straw and a Turmoil Wart - From a merchant bring a pearl - Then Words of Acquisition will to you be given.")
	elseif e.message:findi("obligation") then
		e.self:Say("From Guk, bring an Eye of Jin - From spectres, bring a Globe of Fear - From a merchant bring a jade stone - Then Words of Obligation will to you be given.")
	elseif e.message:findi("words of") or e.message:findi("possession") or e.message:findi("detachment") or e.message:findi("allure") or e.message:findi("haunting") or e.message:findi("rupturing") or e.message:findi("dark paths") or e.message:findi("suffering") or e.message:findi("collection") or e.message:findi("obligation") or e.message:findi("requisition") or e.message:findi("acquisition") then
		e.self:Say("The answer to that question is held by another - Ask again of my sister...")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10083, item2 = 10035, item3 = 14160, item4 = 10019}) then
		necro_word_reward(e, 11829)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10520, item2 = 10523, item3 = 10021}) then
		necro_word_reward(e, 11850)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13150, item2 = 13152, item3 = 8331, item4 = 10024}) then
		necro_word_reward(e, 11866)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10521, item2 = 10525, item3 = 10023}) then
		necro_word_reward(e, 11863)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
