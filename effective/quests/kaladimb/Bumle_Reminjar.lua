-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Bumle_Reminjar.pl
-- items: 12157, 2116, 2118, 2120, 2123, 2124, 12158

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome, " .. e.other:GetName() .. ". The Cathedral of Underfoot welcomes all good persons. May you find peace from the dangers of Butcherblock within these walls. The paladins of this holy place are very much aware of the evils outside Kaladim. The threat of goblins and [birdmen] has increased.")
	elseif e.message:findi("birdmen") then
		e.self:Say("The birdmen I speak of are the aviak krags. These vile creatures have desecrated our land. They have dared to perch upon our great statue. The king has instructed all noble paladins in this order to [destroy the krag chicks].")
	elseif e.message:findi("destroy the krag chicks") then
		e.self:Say("Yes. You are known to have aided our cause. You shall continue by returning any aviak chick talons to me. I will reward you for the return of no fewer than four at a time. Go, and serve the will of the king!")
	elseif e.message:findi("elders") then
		e.self:Say("You have proven yourself worthy, " .. e.other:GetName() .. ". Now, the real threat from the birdmen are the more fully-grown aviaks. Return no less than four talons from these creatures and I shall reward you!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12157, item2 = 12157, item3 = 12157, item4 = 12157}) then
		e.self:Say("Well done, " .. e.other:GetName() .. "! Thanks for the Aviak Chick Talons.")
		e.other:Faction(227, 20, 0)
		e.other:Faction(274, 20, 0)
		e.other:Faction(293, 20, 0)
		e.other:AddEXP(5000)
		e.other:SummonItem(eq.ChooseRandom(2116, 2118, 2120, 2123, 2124))
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12158, item2 = 12158, item3 = 12158, item4 = 12158}) then
		e.self:Say("Ahh! You are truly brave, " .. e.other:GetName() .. "!")
		e.other:Faction(227, 40, 0)
		e.other:Faction(274, 40, 0)
		e.other:Faction(293, 40, 0)
		e.other:AddEXP(80000)
		e.other:GiveCash(0, 4, 5, 2)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
