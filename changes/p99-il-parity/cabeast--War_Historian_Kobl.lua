-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/War_Historian_Kobl.pl
-- P99: https://wiki.project1999.com/Illweed_Parchment_Quest
-- items: 12385, 12389

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("You have come to learn. have you not?  I have knowledge of importance to young warriors of the legion.  Or perhaps you are a scribe seeking my [unique writing materials]!")
	elseif e.message:findi("unique writing materials") then
		e.self:Say("You must be a scribe of sorts?  Always glad to assist a talented youth.  I make two things unique to Cabilis and important to any future master scribe.  I can create [blood ink] and [illweed parchment].")
	elseif e.message:findi("blood ink") then
		e.self:Say("If blood ink is what you seek. then only I can provide it.  I use a unique blend prepared by my secret method.  I can supply you with a vial of blood ink. but first you must fetch me four ingredients.  I need globules of blood from certain creatures.  I need globules from the carnivorous plants. leeches and mosquitoes.  I also need globules from the blood pit of the Tower of Death.  Bring me these and be quick. or the blood will disintegrate.")
	elseif e.message:findi("illweed parchment") then
		e.self:Say("If you wish to obtain a page of my illweed parchment. you only have to perform a simple task.  Bring me four illweed reeds from the Lake of Ill Omen.  You may find that the only way one can find illweed is to go fishing.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12389, item2 = 12389, item3 = 12389, item4 = 12389}) then
		e.self:Say("Here is your illweed parchment. May your writings preserve the glory of the Iksar empire.")
		e.other:SummonItem(12385)
		e.other:Ding()
		e.other:Faction(440, 2, 0) -- Cabilis Residents
		e.other:Faction(442, 2, 0) -- Crusaders of Greenmist
		e.other:Faction(441, 2, 0) -- Legion of Cabilis
		e.other:Faction(445, 2, 0) -- Scaled Mystics
		e.other:Faction(444, 2, 0) -- Swift Tails
		e.other:AddEXP(100)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
