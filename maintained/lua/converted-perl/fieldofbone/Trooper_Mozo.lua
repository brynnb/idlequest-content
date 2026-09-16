-- Converted from ProjectEQ Perl quest script.
-- Source: fieldofbone/Trooper_Mozo.pl
-- items: 13073

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("look's upon you smugly.")
		e.self:Say("And what are you, some sort of adventurer? Bah!! You will be shaken by the first undead you come across. Wetting your pant's you shall be. Ha Ha!! I doubt you could even [kill the decaying skeletons]!")
	elseif e.message:findi("kill the decaying skeletons") then
		e.self:Say("You kill skeletons?!! I think not!! They will bounce you with no trouble at all. Ten silvers says you cannot collect four bone chips!! When Velious melts!! Hah!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13073, item2 = 13073, item3 = 13073, item4 = 13073}) then
		e.self:Emote("gasp's in astonishment.")
		e.self:Say("Wha...? This!! But... I... Why you... I oughta.. All right!! A bet is a bet. Here you go. A few silver piece's for your achievement. What?!! You thought I would give you ten? Fat chance! Now get lost or I will haul you in for impersonating a froglok.")
		e.other:Faction(441, 1, 0)
		e.other:Faction(440, 1, 0)
		e.other:Faction(445, 1, 0)
		e.other:Faction(442, 1, 0)
		e.other:Faction(444, 1, 0)
		e.other:GiveCash(0, eq.ChooseRandom(1, 2, 3, 4, 5, 6, 7), 0, 0)
		e.other:AddEXP(250)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
