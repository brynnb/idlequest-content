-- Converted from ProjectEQ Perl quest script.
-- Source: oggok/Kogna.pl
-- P99: https://wiki.project1999.com/Lizard_Meat_Quest
-- items: 13410, 5025

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You be tinking you be [real tuff Craknek]?")
	elseif e.message:findi("i am a real tuff craknek") then
		e.self:Say("Me not tinking so. but maybe me wrongs.. no.. me neber wrongs.  You no tuff. only liddle Craknek is you.  You tink you be tuff Craknek. you bringed me four lizard meats.  Me like lizard meats.  You no tuff.  You bringed me lizard [meats].  I make you tuffer Craknek.  Me bestest Craknek.")
	elseif e.message:findi("meats") then
		e.self:Say("Yup, meats.  You brings me four, me gives you sumting.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13410, item2 = 13410, item3 = 13410, item4 = 13410}) then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("Yous really did it. Mebbe you tuff Craknek after all.")
			e.other:SummonItem(5025)
			e.other:Faction(228, 15, 0)
			e.other:Faction(232, 15, 0)
			e.other:Faction(261, -15, 0)
			e.other:AddEXP(500)
			e.other:Ding()
		else
			e.self:Say("You no tuff Craknek yet. Go prove youself first.")
			e.other:SummonItem(13410)
			e.other:SummonItem(13410)
			e.other:SummonItem(13410)
			e.other:SummonItem(13410)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
