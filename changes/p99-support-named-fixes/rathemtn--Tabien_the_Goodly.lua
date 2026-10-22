-- Source: rathemtn/Tabien_the_Goodly.pl
-- Shaman Epic 1.0: Tabien gives the Marble Pebble.
-- Converted from ProjectEQ Perl quest script.
-- items: 1676, 1677, 1670

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Oh thank Marr you are here, " .. e.other:GetName() .. ". I have a task for you to complete in the name of my patron Mithaniel Marr.")
	elseif e.message:findi("task") then
		e.self:Emote("displays his battered shield.")
		e.self:Say("This shield is known as Marr's Promise. A patriarch of the false god, Bertoxxulous, is after my shield and me. He must be stopped!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1676, item2 = 1677}) then
		e.self:Say("Ahh, thank Mithaniel you have put Glaron and his terrible reign to an end! Take this gem and give it to the one who sent you.")
		e.other:SummonItem(1670) -- Marble Pebble
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
