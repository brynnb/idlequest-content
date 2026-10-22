-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/X-Ta_Tempi.pl
-- items: 7036, 10019, 10516, 11815, 7037, 10020, 10518, 11836, 10520, 10524, 10022, 11858, 10521, 10526, 10023, 11864

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
	elseif e.message:findi("lore of death") then
		e.self:Say("The Lore of Death is shadow bound - Its [words] are [hid]. yet shall be found - Through our research into the dark - Old hexes found and parchment marked.")
	elseif e.message:findi("the dead") then
		e.self:Say("The Dead are the shadowknights and necromancers of Neriak. They were formed by Queen Cristanos herself.")
	elseif e.message:findi("necromancy") then
		e.self:Say("Necromancy - Art of the Dead - Binding bones to serve your will - We research now the [Lore of Death] - Ancient spells with power still.")
	elseif e.message:findi("hid") or e.message:lower() == "words" or e.message:lower() == "word" then
		e.self:Say("The Words are hid in tomes of old - Their yielded lore worth more than gold - Though we search both 'fore and 'hind - [Components] we can not yet find.")
	elseif e.message:findi("components") then
		e.self:Say("We need components for research - These are things that you could find - In return for [tasks] that you perform - Words of [reward] we have in mind.")
	elseif e.message:findi("tasks") or e.message:findi("reward") then
		e.self:Say("Bring us components for our research - We give [Word]s by tasks performed - [Possession], [Detachment], [Allure], [Haunting], [Rupturing], [Dark Paths], [Suffering], [Collection], [Obligation], [Requisition] and [Acquisition].")
	elseif e.message:findi("possession") then
		e.self:Say("From the Estate of Unrest, bring two barbed bone chips - From Castle Mistmoore, a dagger charred - From a merchant bring a stone of blood - Words of Possession will be your reward.")
	elseif e.message:findi("haunting") then
		e.self:Say("From the Estate of Unrest, bring two dark bone chips - From Castle Mistmoore, a dagger ebon - From a merchant bring a jasper stone - Then Words of Haunting will to you be given.")
	elseif e.message:findi("collection") then
		e.self:Say("Two Words of Collection I possess - To obtain Beza to me you must bring - a globe of darkness, an Eye of Kor and an amber gem. To obtain Caza to me you must bring - an Eye of Guk, a globe of fear, and jade.")
	elseif e.message:findi("words of") or e.message:findi("possession") or e.message:findi("detachment") or e.message:findi("allure") or e.message:findi("haunting") or e.message:findi("rupturing") or e.message:findi("dark paths") or e.message:findi("suffering") or e.message:findi("collection") or e.message:findi("obligation") or e.message:findi("requisition") or e.message:findi("acquisition") then
		e.self:Say("The answer to that question is held by another - Ask again of my sister...")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 7036, item2 = 10019, item3 = 10516, item4 = 10516}) then
		necro_word_reward(e, 11815)
	elseif item_lib.check_turn_in(e.trade, {item1 = 7037, item2 = 10020, item3 = 10518, item4 = 10518}) then
		necro_word_reward(e, 11836)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10520, item2 = 10524, item3 = 10022}) then
		necro_word_reward(e, 11858)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10521, item2 = 10526, item3 = 10023}) then
		necro_word_reward(e, 11864)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
