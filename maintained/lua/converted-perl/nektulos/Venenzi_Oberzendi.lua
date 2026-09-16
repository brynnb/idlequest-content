-- Source: nektulos/Venenzi_Oberzendi.pl
-- Necromancer Epic 1.0: Venenzi Oberzendi reagent chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 20642, 20643, 1320, 20649

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What is it you want! Can't you see I am gathering reagents for my master?")
	elseif e.message:findi("master") then
		e.self:Say("The great Kazen Fecae! If you fancy yourself a necromancer, travel to Lake Rathetear and tell Kazen you wish to study the dark arts.")
	elseif e.message:findi("reagents") then
		e.self:Say("My master is working on some great project.")
	elseif e.message:findi("task") then
		e.self:Emote("looks down at her robes and back at you. 'Slay Najena and bring me her robe, and I will give you my hard earned reagents.'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20642}) then
		e.self:Say("I see you serve my master as well now. I might consider giving you these reagents, if only you do a small task for me.")
		e.other:Ding()
		e.other:AddEXP(500)
		e.other:SummonItem(20643) -- Twisted Symbol of the Apprentice
	elseif e.other:HasItem(20643) and item_lib.check_turn_in(e.trade, {item1 = 1320}) then
		e.self:Say("Thank you. Don't forget to give his lapdog that symbol with the reagents.")
		e.other:Ding()
		e.other:AddEXP(500)
		e.other:SummonItem(20649) -- Rolling Stone Moss
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
