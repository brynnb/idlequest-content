-- Source: timorous/Dolgin_Codslayer.pl
-- Druid Epic 1.0: Dolgin Codslayer accepts Froglok Essence and spawns Faydedar.
-- Converted from ProjectEQ Perl quest script.
-- items: 20696

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("ARGH! Dangit, ya scared me! Tread cautiously, friend. This here place ain't as friendly as it seems. There's a beast lurkin' in this here puddle.")
	elseif e.message:findi("a beast") then
		e.self:Say("Aye lad. I seen it come from the ocean. It was fightin' a group of adventurers, not unlike yerself. The battle raged long and hard, and at the end the beast lay still among countless of the adventurers bodies. They left assuming it had been slain by their hands. But, once they left, I seen it come crawlin in this here place. They called it by the name Fayde, er, Fayred. Hrmm. What was it they called it? I can't remember.")
	elseif e.message:findi("Faydedar") then
		e.self:Say("Ya! That's what they called it! A great water dragon as the legends say. Only way to find him now is to lure him out from hiding. Not that I would suggest doin such a thing. The dern thing's broken, bleedin, and cornered. That's a mighty deadly position to put a critter in if ye ask me. Course if yer wantin' to try it, there might be a way. Ya willin to risk it?")
	elseif e.message:findi("i will risk it") then
		e.self:Say("Well jus' before that there beast ended up in combat, I watched him from the shores. Only reason he got into such a mess was 'cause of his belly. He swam right into those adventurers chasin' down a wandering froglok. You wanna catch a fish, use the right bait. If only we had us some frogloks essence, then mebbe he'd come out agin.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20696}) then
		e.self:Say("What's this? Egads! It's perfect. Now all we gotta do is hope he bites. Dolgin takes a little of the essence and smears it on a piece of bread. He places the bait into the water and watches intently.")
		e.other:SummonItem(20696) -- Froglok Essence
		eq.spawn2(96073, 0, 0, -2178, -11745, -0.63, 126) -- #Faydedar
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
