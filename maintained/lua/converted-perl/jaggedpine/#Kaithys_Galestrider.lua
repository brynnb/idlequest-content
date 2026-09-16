-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/#Kaithys_Galestrider.pl
-- items: 8907, 8908, 8915, 17505

local function silver_state(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["silverbladeofthunder"]
end

local function reward_factions(e)
	e.other:Faction(1597, 20, 0)
	e.other:Faction(272, 20, 0)
	e.other:Faction(302, 20, 0)
	e.other:Faction(262, 20, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("closes his eyes and gives a mid-bow of his head toward you. 'Greetings, traveler. I am Kaithys Galestrider. [I still hold a great knowledge] unique to this old mind.'")
	elseif e.message:findi("great knowledge") then
		e.self:Say("I was found to be adept in the art of blacksmithing, but I am at a loss to continue production of these weapons since the arrival of our most unexpected [threat].")
	elseif e.message:findi("threat") then
		e.self:Say("The gnolls of Blackburrow dug their way to our forest. With them came much more worrisome [turmoil].")
	elseif e.message:findi("turmoil") then
		e.self:Say("Poachers and thieves have taken an [interest] in our ways.")
	elseif e.message:findi("interest") then
		e.self:Say("They are unwittingly [aiding a much greater threat] to all protectors of the natural order.")
	elseif e.message:findi("greater threat") then
		e.self:Say("The Tome of Thunder was stolen. A scout's [report] is disturbing.")
	elseif e.message:findi("report") then
		e.self:Say("The scout believes the tome was commissioned to be stolen by a [group] that may now hold it.")
	elseif e.message:findi("group") then
		e.self:Say("The scout believes them to be a cult of militant so-called druids and rangers. This is very [troubling].")
	elseif e.message:findi("troubling") then
		e.self:Say("Their philosophies threaten ours. Still, the tome must [return the tome] to us.")
	elseif e.message:findi("return the tome") then
		e.self:Say("If you believe you can brave such an endeavor, then retrieve the Tome of Thunder and return it to me with haste.")
	elseif silver_state(e) == "1" and e.message:findi("key materials") then
		e.self:Say("There is a cursed blade that I have held onto for many years. Its story begins with a [horrible danger].")
	elseif silver_state(e) == "1" and e.message:findi("horrible danger") then
		e.self:Say("We found ourselves in the realm of hate. In that place the [tides were turned].")
	elseif silver_state(e) == "1" and e.message:findi("turned") then
		e.self:Say("We engaged an agent of hate. [Victory] seemed impossible.")
	elseif silver_state(e) == "1" and e.message:findi("victor") then
		e.self:Say("We defeated the monster, but not without consequence. I recovered the massive [blade] that the knight wielded.")
	elseif silver_state(e) == "1" and e.message:findi("blade") then
		e.self:Say("Yanous was unable to [purge the corruption] from the blade entirely.")
	elseif silver_state(e) == "1" and e.message:findi("purge the corruption") then
		e.self:Say("The blade was stolen before I could make proper use of it. Return the blade to Gurrin with the Writ of Thunder.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8907}) then
		e.self:Say("Yes... nicely done, child. Take this Writ of Thunder to my assistant, Gurrin Nitestorm, who you may find in the Surefall Glade.")
		e.other:AddEXP(1000)
		e.other:Ding()
		reward_factions(e)
		eq.set_global("silverbladeofthunder", "1", 0, "F")
		e.other:SummonItem(8908)
	elseif silver_state(e) == "1" and item_lib.check_turn_in(e.trade, {item1 = 8915}) then
		e.self:Emote("takes the blade and intently examines it. Satisfied with the purified quality, he nods to himself.")
		e.other:AddEXP(10000)
		e.other:Ding()
		reward_factions(e)
		e.other:SummonItem(17505)
		eq.delete_global("silverbladeofthunder")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
