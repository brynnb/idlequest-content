-- Converted from ProjectEQ Perl quest script.
-- Source: qey2hh1/Renux_Herkanor.pl
-- items: 17148, 24072, 24073

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Master Hanns is going to kill me! I let that dark assassin look at his prized poison collection and he lifted it all when I wasn't looking! He even snatched his Grandmaster's Vial! Master Hanns was so furious he grabbed one of his old blades from his collection and jabbed it at the wall so hard it shattered! I really need some help replacing all that was [ruined] or I have a feeling Master Hanns is going to send me on a suicide mission!")
	elseif e.message:findi("ruined") then
		e.self:Say("Fantastic! I need to replace all those old poisons, the vial and that old scareling blade. I think the bottles had the following written on them Bane, Burn, Essence, Sloth, Rage, Swiftness, Disorientation, and Dimethyl. Please hurry!")
		e.other:SummonItem(17148)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 24072}) then
		e.self:Say("Great! Looks like everything is here! Hopefully Master Hanns won't send me to Steamfront now, I have a really bad feeling about that assignment. Here take this Seal, it was dropped by that dark stranger. It glows with a dark power I just don't understand. Be wary of further sightings of that dark assassin.")
		e.other:SummonItem(24073)
		e.other:AddEXP(200000)
		e.other:Faction(223, 20, 0)
		e.other:Faction(291, -20, 0)
		e.other:Faction(230, 20, 0)
		e.other:Faction(262, -20, 0)
		e.other:Faction(273, 20, 0)
		eq.depop_with_timer()
	else
		e.self:Say("Go away! We don't have time for the likes of you.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
