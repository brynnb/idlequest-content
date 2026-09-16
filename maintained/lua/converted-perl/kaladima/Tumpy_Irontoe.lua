-- Converted from ProjectEQ Perl quest script.
-- Source: kaladima/Tumpy_Irontoe.pl
-- items: 13340, 13006, 12114

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to Irontoe's! The finest watering hole this side of Oggok! If you're looking for anything special and it ain't behind the bar, just ask. Maybe I can make it.")
	elseif e.message:findi("tumpy tonic") then
		e.self:Say("So you want a Tumpy Tonic? I can make you one. All I need is a flask of water and a kiola nut. The kiola nut can be bought in the Ocean of Tears island chain.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13340, item2 = 13006}) then
		e.self:Say("Here you go. One Tumpy Tonic. Don't drink that too fast now.")
		e.other:SummonItem(12114)
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
