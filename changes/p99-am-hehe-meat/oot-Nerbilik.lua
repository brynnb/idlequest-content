-- Converted from ProjectEQ Perl quest script.
-- Source: oot/Nerbilik.pl
-- items: 12203

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What you want?!! Face so ugly you scare fish away!! ..sniff, sniff. Smell so bad, too!! Me sure is hungry. Wish had [grub locker].")
	elseif e.message:findi("grub locker") then
		e.self:Say("You gots grub locker!! Give to me. Me sick of fish and not many dwarves fall off ship. Me pay a plat to get me grub locker from the Gobbler in Neriak. Go to him and say you [deliver grub locker] if you wants one plat.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12203}) then
		e.self:Say("Oooh!! Grub locker! There is a loud click. He opens the locker and unwraps dwarf pickles. What this dumb wrapper? R, E, C, I, P, E.. Ahh!! It say pickles!! Me read good. Here your plat. Me give you little more. Me was very hungry for pickles.")
		e.other:Faction(235, 10, 0)
		e.other:Faction(222, -10, 0) -- P99 documents Broken Skull Clan loss.
		e.other:AddEXP(150)
		e.other:GiveCash(0, 0, 0, 2)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
