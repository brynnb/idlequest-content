-- Converted from ProjectEQ Perl quest script.
-- Source: nektulos/Kamidra_Voragone.pl
-- items: 13088

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ". I am so hungry, but I have much work to do. Do you think you can [help] me?")
	elseif e.message:findi("help") then
		e.self:Say("Excellent.")
		-- ProjectEQ opens task 154 here. IdleQuest quest Lua captures do not
		-- currently expose task selection, so the direct egg hand-in remains.
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13088, item2 = 13088, item3 = 13088, item4 = 13088})
		or item_lib.check_turn_in(e.trade, {item1 = 13088, item2 = 13088, item3 = 13088})
		or item_lib.check_turn_in(e.trade, {item1 = 13088, item2 = 13088})
		or item_lib.check_turn_in(e.trade, {item1 = 13088}) then
		e.self:Say("Thank you. I am impressed!")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

