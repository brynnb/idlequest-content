-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/#Randel_Stormwind.pl
-- items: 9270, 9271, 9272, 9273, 9226

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Well met, " .. e.other:GetName() .. ". This has been a very stressful time and the sudden [change] has left many on edge.")
	elseif e.message:findi("change") then
		e.self:Say("This story begins when public [access] to Jaggedpine [was restricted].")
	elseif e.message:findi("access was restricted") then
		e.self:Say("The Protectors of the Pine feared retaliation from the Unkempt. For the longest time things were peaceful on the [Throne of Karana's Fury].")
	elseif e.message:findi("Throne of Karana") then
		e.self:Say("We had problems with the odd [poacher].")
	elseif e.message:findi("poacher") then
		e.self:Say("There is one [group] of poachers I'm particularly worried about.")
	elseif e.message:findi("group") then
		e.self:Say("They call themselves the [Pirates of the Pine].")
	elseif e.message:findi("Pirates of the Pine") then
		e.self:Say("If you are able to bring these four to justice, return to me with proof. You will be justly compensated.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 9270, item2 = 9271, item3 = 9272, item4 = 9273}) then
		e.self:Say("Great Karana's blessing!! I see justice by your hand is both swift and eternal. Please take this ring as a token of my gratitude.")
		e.other:SummonItem(9226)
		e.other:Faction(1597, 10, 0)
		e.other:Faction(272, 10, 0)
		e.other:Faction(302, 10, 0)
		e.other:Faction(262, 10, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
