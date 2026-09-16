-- Restored epic 1.0 directions from preserved ProjectEQ Perl and P99.
-- Source: lakerathe/Rykas.pl
-- Magician Epic 1.0: Rykas starts the tale and grants Power of the Orb.
-- Converted from ProjectEQ Perl quest script.
-- items: 28035, 28003, 28004, 28031, 18958

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". I am Rykas, chronicler of knowledge. Are you in search of knowledge?")
	elseif e.message:findi("knowledge") then
		e.self:Say("A small task is needed if you wish to learn more. Do you wish to learn the tale of Magi'kot?")
	elseif e.message:findi("Magi") then
		e.self:Say("If you seek to learn the tale of Trilith Magi'kot, your journey shall begin in the Commonlands. Search for Jahsohn Aksot and give him this token. He will share some of the knowledge I have bestowed upon him, and point you further down your path to Mastery. Bring me the Words of Mastery, Power of the Elements, and the Words of Magi'kot....Then you shall learn more about the power of the orb.")
		e.other:SummonItem(28035) -- Token of Mastery
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 28003, item2 = 28004, item3 = 28031}) then
		e.self:Say("I see that you have completed the quest I laid before you. That speaks well of your dedication, yet you do not realize your journey has just begun. Study this tome.")
		e.other:SummonItem(18958) -- Power of the Orb
		e.other:AddEXP(2000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
