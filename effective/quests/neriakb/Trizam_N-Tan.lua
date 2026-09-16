-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Trizam_N-Tan.pl
-- P99 audit: Orc Pawn Picks
-- items: 13885, 13021, 13022

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("And who do you think you are? To step into the Cauldron of Hate one should have the black soul of a warrior. For one to speak with Trizam he should have good reason. Perhaps you return with tales of [deathfist] agendas. If so, then you're a year too late.")
	elseif e.message:findi("deathfist") then
		e.self:Say("Have you been spending day and night at the Malden's Fancy?!! The Deathfist Orcs in the Commonlands are up to something. As the inept humans in Freeport hunt down the warrior orcs, the pawns run about on some secret mission. I have been appointed by King Nathox to attend to this matter and hire young warriors who wish to [collect] pawn kills.")
	elseif e.message:findi("collect") then
		e.self:Say("Yes, You will. You need not know the reason why. I command you by order of King Naythox Thex to venture forth to the Commonlands and slay all the orc pawns you see. Return with four pawn picks and maybe I shall even reward you. Leave at once or you shall find yourself hanging from the Hooks of Innoruuk!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13885, item2 = 13885, item3 = 13885, item4 = 13885}) then
		e.self:Say("As instructed, I shall reward your good deed. But I choose to reward you with provisions from the pantries of Neriak. They shall keep you strong.")
		e.other:Faction(270, 5, 0)
		e.other:Faction(326, -5, 0)
		e.other:Faction(311, -5, 0)
		e.other:Faction(1522, -5, 0)
		e.other:AddEXP(25)
		e.other:Ding()
		e.other:SummonItem(13021, 2)
		e.other:SummonItem(13022)
		e.other:GiveCash(0, eq.ChooseRandom(4, 5, 6), 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
