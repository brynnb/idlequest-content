-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Antus_Shelbra.pl
-- items: 9968, 9969, 13697, 9967

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". You have come to me searching for tasks and tasks I have. Would you judge yourself an [experienced heretic] or one who has [much to learn]?")
	elseif e.message:findi("much to learn") then
		e.self:Say("Very well, " .. e.other:GetName() .. ". I do have a task for you. There is an old and frail Erudite male who now lives in Toxxulia named Aglthin Dasmore. He has left the ways of Cazic-Thule and no longer practices our craft. He has been stripped of his power and wealth, so he spends his time fishing by the river. Our great Lord of Fear has decreed that his life is forfeit. Slay him, and bring me proof of the deed.")
	elseif e.message:findi("experienced heretic") then
		e.self:Say("Ah. Excellent. I have just the task for you, " .. e.other:GetName() .. ". In Kerra Ridge, there is a particular cat named Kirran Mirrah that we have been using to gather information about, well, certain aspects of cat society. He is no longer providing information for us and we have something for him that may encourage him to assist again. Ha! Hand him this sealed bag for us. It may just change his point of view. Hahaha!")
		e.other:SummonItem(9968)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 9969}) then
		e.self:Say("Yes, this will do.")
		e.other:SummonItem(13697)
		e.other:Faction(265, 10, 0)
		e.other:Faction(254, -30, 0)
		e.other:Faction(242, -30, 0)
		e.other:Faction(231, -30, 0)
		e.other:Faction(233, -30, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 9967}) then
		e.self:Say("Ah, it seems as if he was not a very cooperative kitty. So much for family. Oh well, take this token change as a show of my appreciation. Cazic-Thule shines on you in all his glorious fear this day, young one.")
		e.other:Faction(265, 10, 0)
		e.other:Faction(254, -30, 0)
		e.other:Faction(242, -30, 0)
		e.other:Faction(231, -30, 0)
		e.other:Faction(233, -30, 0)
		e.other:GiveCash(2, 8, 0, 2)
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
