-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Gearin_Gaxx.pl
-- P99 audit: Guard of Ik Quest
-- items: 12883, 12971, 12972

local function firiona_vie_factions(e)
	e.other:Faction(248, 1, 0) -- Inhabitants of Firiona Vie
	e.other:Faction(326, 1, 0) -- Emerald Warriors
	e.other:Faction(312, 1, 0) -- Storm Guard
	e.other:Faction(441, -1, 0) -- Legion of Cabilis
	e.other:Faction(313, -1, 0) -- Pirates of Gunthak
end

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Welcome. friend!  If armor is what you seek. let the house of Gaxx provide you with the finest.  Our metalwork is second to none.  Every now and again we may even create [rare armor] for the general public to purchase.")
	elseif e.message:findi("rare armor") then
		e.self:Say("I have found many exotic materials in Kunark with which I can create rare armor.  I currently am working on the [Guard of Ik] and the [Hate Tail Guard] shields.  I have no armor as of yet. but I am experimenting with new designs.")
	elseif e.message:findi("Guard of Ik") then
		e.self:Say("The Guards of Ik are made from shields found in the jungles.  I would be selling them if it were not for the unfortunate fact that the shields are spectral and vanish overnight.  Another bit of bad news is that the formula I was working on to stabilize the essence of the metal was stolen by local pirates.  I need two more shields and my formula.  Bring these to me and I shall not charge you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12883, item2 = 12883, item3 = 12971}) then
		e.self:Say("Gearin Gaxx places the formula in a box which appears to have similar copies in it. Thank you!! I can now reward you with this Guard of Ik shield I had lying around.")
		e.other:SummonItem(12972) -- Guard of Ik
		firiona_vie_factions(e)
		e.other:AddEXP(1000)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
