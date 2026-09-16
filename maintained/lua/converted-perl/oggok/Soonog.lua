-- IdleQuest starting guild note turn-in.
-- Source: oggok/Soonog.pl
-- P99: https://wiki.project1999.com/Lizard_Meat_No_2
-- items: 18789, 13527, 13410, 5023

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You [Greenblood]?")
	elseif e.message:findi("greenblood") then
		e.self:Say("Gud. you go kill da lizzies in da Feerrott. Bring Soonog four of dere meatses. Soonog give you gud sword to bash more lizzies wif.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18789}) then
		e.self:Say("Soonog own you now.. fight for Soonog.. Soonog make you power.. Soonog army rule all!")
		e.other:SummonItem(13527)
		e.other:AddEXP(100)
		e.other:Faction(261, 100, 0)
		e.other:Faction(228, 50, 0)
		e.other:Faction(312, -15, 0)
		e.other:Faction(308, -15, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 13410, item2 = 13410, item3 = 13410, item4 = 13410}) then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("Mmm Lizzie meat!! Here, go bash dem lizzies more better wif dis.")
			e.other:SummonItem(5023)
			e.other:AddEXP(500)
			e.other:Faction(228, 10, 0)
			e.other:Faction(261, 10, 0)
			e.other:Faction(312, -10, 0)
			e.other:Faction(308, -10, 0)
			e.other:Ding()
		else
			e.self:Say("Soonog no trust you wif Greenblood work.")
			e.other:SummonItem(13410)
			e.other:SummonItem(13410)
			e.other:SummonItem(13410)
			e.other:SummonItem(13410)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
