-- Source: rathemtn/Glaron_the_Wicked.pl
-- Shaman Epic 1.0: Glaron gives the Obsidian Pebble.
-- Converted from ProjectEQ Perl quest script.
-- items: 1675, 1669

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Are you the one they sent to help our cause? I have a task you must fulfill if you wish to know the blessing of my god and impress your masters.")
	elseif e.message:findi("task") then
		e.self:Emote("brandishes a long, wicked-looking bone dagger.")
		e.self:Say("This festering blade is called Woe, and this scorched one is called Envy. End this idiot follower of Marr's life and bring me proof.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1675}) then
		e.self:Say("Hahahah! Even you were able to do away with that fool. Take this and give it to your master.")
		e.other:SummonItem(1669) -- Obsidian Pebble
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
