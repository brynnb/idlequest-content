-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Lianna_Ferasa.pl
-- items: 13899, 19010

function event_say(e)
	if e.message:findi("regis") then
		e.self:Say("Regis was my one true love, but he was [killed] and his soul enslaved by Zahal the Vile.")
	elseif e.message:findi("killed") then
		e.self:Say("He was killed in the northern tree line to the east in North Karana. If you kill Zahal, Regis' body will rise from the place where he died. If my flute is on the body, please bring it to me.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13899}) then
		e.self:Say("Thank you for setting his spirit free. Keep his memory alive with this.")
		e.other:SummonItem(19010)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
