-- enabled: false
-- P99 source-only scope exclusion: later_tynnonium_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: kaesora/a_tome_keeper.pl
-- items: 4196

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("shows awareness of you, but ignores you completely.")
	elseif e.message:findi("peace of mind") then
		e.self:Emote("begins to speak to you without movement of his rotted mouth, you realize his words are pouring into your mind. 'You seek peace of mind, and may you have it. First though, your Shackle of Steel. One Shackle for one tome.'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 4196}) then
		e.self:Emote("drops a tattered tome at your feet and says nothing more. You pick it up and place it among your things.")
		e.other:SummonItem(eq.ChooseRandom(18359, 18462, 18463, 18464, 18465, 18466, 18467, 18468, 18469, 18470))
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
