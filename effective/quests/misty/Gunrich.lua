-- Converted from ProjectEQ Perl quest script.
-- Source: misty/Gunrich.pl
-- items: 13131

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ". What can I do for you?")
	elseif e.message:findi("dark rivers flow east") then
		e.self:Say("Heh! Here, here, here.  Tell Rueppy hellos from Gunrich.  She am so perties. Heh, heh.")
		e.other:SummonItem(13131)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
