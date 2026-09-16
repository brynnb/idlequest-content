-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Crusader_Zixo.pl
-- items: 18271, 18272, 24770, 5130

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Do you come to me empty handed, knave? Did you lose your pike?")
	elseif e.message:findi("no") then
		e.self:Say("Ah... Yes... very good! Continue to work at this pace and the enemies of the Legion of Cabilis will fall beneath the blades of Cazic-Thule! Now move out... To Victory!")
	elseif e.message:findi("yes") then
		e.self:Emote("shakes his head and growls. 'That is not good, broodling... Not good at all. You will need to take this note and seek out the Toilmaster immediately. Read it on the way and hope that your incompetence can be overcome. The Crusaders of Greenmist have a pit for you, should this prove to be impossible.")
		e.other:SummonItem(18271) -- Ragged Book
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18272, item2 = 24770}) then
		e.self:Emote("takes the bag and tome from you and in return gives you the item that you have been thinking of all of this time.")
		e.self:Say("Lucky you. You have earned a second chance. Praise Cazic-Thule!")
		e.other:SummonItem(5130) -- Partisan's Pike
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
