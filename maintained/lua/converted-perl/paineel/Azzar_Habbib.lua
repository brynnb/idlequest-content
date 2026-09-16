-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Azzar_Habbib.pl
-- items: 1528, 1530, 19076, 12096, 22502, 1529

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I'm not in any mood for conversation. My favorite hat was torn right from my head by a gigantic bat the other night and I am quite upset.")
	elseif e.message:findi("other tasks") then
		e.self:Say("I will sew you your own personal dreadful cap if you bring me the necessary components. I will need the pelt of a feared beast, some gold thread, and an imbued amber.")
	elseif e.message:findi("hat") then
		e.self:Say("It is a marvelous cap sewn from the finest textiles and imbued with the divine power of our lord of fear. Cazic Thule!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1528}) then
		e.self:Emote("gasps in astonishment")
		e.self:Say("You...you..found my hat!! This is the most I can repay you but perhaps I can reward you further for some [other tasks]?")
		e.other:SummonItem(1530)
		e.other:Ding()
		e.other:Faction(265, 1, 0)
		e.other:Faction(231, -3, 0)
		e.other:Faction(233, -3, 0)
		e.other:Faction(242, -3, 0)
		e.other:Faction(254, -3, 0)
		e.other:AddEXP(1000)
	elseif item_lib.check_turn_in(e.trade, {item1 = 19076, item2 = 12096, item3 = 22502}) then
		e.self:Say("Here is your dreadful cap as I have promised.")
		e.other:SummonItem(1529)
		e.other:Ding()
		e.other:Faction(265, 1, 0)
		e.other:Faction(231, -3, 0)
		e.other:Faction(233, -3, 0)
		e.other:Faction(242, -3, 0)
		e.other:Faction(254, -3, 0)
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
