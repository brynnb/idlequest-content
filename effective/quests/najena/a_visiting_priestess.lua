-- Converted from ProjectEQ Perl quest script.
-- Source: najena/a_visiting_priestess.pl
-- items: 6323, 6324, 6335, 6336, 18401

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetName() .. "! Are you the champion Najena sent for?")
	elseif e.message:findi("champion of Najena") then
		e.self:Say("Very well champion.  Have you heard of The Staff of Ankexfen?")
	elseif e.message:findi("not heard of the staff") then
		e.self:Say("No? Why am I not surprised? You look too weak and frail to be of any use. You probably could not even best one of those intoxicated, weak-minded goblins controlled by that pathetic eye called Xxorb. Away with you, useless creature!")
	elseif e.message:findi("happened to the Ankexfen") then
		e.self:Say("The wrath of the unnamed gods was grim. Thousands of ogres were instantly slain - their empire left to crumble under the hand of retribution. The giants were flung across the face of Norrath like seeds to the wind. The Ankexfen's fates were more severe. The entire race was exterminated, but from the ashes were born the four goblin races. What is known is that each goblin clan was stripped of any knowledge and was neither informed of the other clans nor of their own origins. Each clan was then transported to a separate environment to help preserve the gods' will. However, the gods were not without mercy and each clan was granted a section of the staff. Upon each staff, a crystal was placed. These staves served to aid the goblin clans in understanding their environments. These remnants of the staff of Ankexfen are what I desire. Bring them to me and the Priests of Innoruuk shall reward you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 6323, item2 = 6324, item3 = 6335, item4 = 6336}) then
		e.self:Emote("cackles with glee as she slowly assembles the runed rods, and with a muttered incantation and a flash of light, disappears, leaving only a note that slowly drifts to the ground.")
		e.other:SummonItem(18401)
		e.other:Faction(340, 20, 0)
		e.other:Faction(278, 20, 0)
		e.other:Faction(362, -60, 0)
		e.other:Faction(226, -60, 0)
		e.other:Faction(341, -60, 0)
		e.other:Faction(1522, -60, 0)
		e.other:AddEXP(132775)
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
