-- Source: firiona/Foloal_Stormforest.pl
-- Ranger Epic 1.0: Foloal combines the stones.
-- Converted from ProjectEQ Perl quest script.
-- items: 20462, 20461, 20468

function event_say(e)
	if e.message:findi("are you one such as myself") then
		e.self:Emote("stares at you and whispers. 'You must be the one that has been spoken of. Yes, yes I am one of the circle. There are many of us in the lands right now, all seeking answers to the ills that have befallen our homes.'")
	elseif e.message:findi("answers") then
		e.self:Say("I have heard whispers of new Iksar movements in the land. The name of Venril Sathir is on the scaled lips and sharp tongues of every cold blooded lizard in this place.")
	elseif e.message:findi("venril sathir") then
		e.self:Say("All I've heard are whispers of connections between the undead lizards and the dark god of hate. There's some kind of history behind the two. It might be that Venril is the main focus of Innoruuk's will in the land. Then again, maybe not, but this is the best we've gotten so far. If you think you can do it, then find him and remove him from the face of this earth. Bring me the half of the stone I know you have and whatever conduit of power you find on his rotting corpse.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20462, item2 = 20461}) then
		e.self:Emote("blinks and carefully takes the stones from you, cautiously scratching the jagged green stone against the other. Its skin seems to shiver and flake at the contact and eventually begins to shine brightly. 'With the gem nature's balance is complete. Take the stone and walk your path. Blade or lightning caller, burning sword or the mother's walk.'")
		e.other:SummonItem(20468) -- Warmly Glowing Stone
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
