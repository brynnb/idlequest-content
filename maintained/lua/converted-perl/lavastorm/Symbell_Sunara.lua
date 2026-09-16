-- Converted from ProjectEQ Perl quest script.
-- Source: lavastorm/v1/Symbell_Sunara.pl
-- items: 13418

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ".")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13418}) then
		if e.other:IsTaskActivityActive(1947, 4) then
			e.self:Say("Ah, yes. Thank you.")
		else
			e.self:Say("I have no use for this, " .. e.other:GetName() .. ".")
			e.other:SummonItem(13418)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
