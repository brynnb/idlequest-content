-- Converted from ProjectEQ Perl quest script.
-- Source: swampofnohope/Footman_Moglok.pl
-- items: 18234, 12435

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("looks at you with sorrowful eyes and wipes his dripping nose.")
		e.self:Say("Woe is me. I am nothing more than a lowly footman. And spare me the smart remarks - 'Moglok the Froglok' - I have heard all the jokes.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18234}) then
		e.self:Emote("beams a big smile.")
		e.self:Say("Oh, joy! They have finally sent someone to help me on my mission! I was once a trooper, but I got demoted. I failed to bring Warlord Hikyg the three heads of the Gubbnubb triplets. Here is one head, but we need them all. Track the other two down and take all three heads and your soldier pike to Warlord Hikyg. I quit this outfit!!")
		e.other:SummonItem(12435)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
