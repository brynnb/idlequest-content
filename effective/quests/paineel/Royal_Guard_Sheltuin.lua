-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Royal_Guard_Sheltuin.pl
-- items: 1773, 1774, 1775, 1776, 1777, 18174, 1778, 1764

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("appears to be ignoring you completely.")
	elseif e.message:findi("i wish an audience with the overlord") then
		e.self:Say("The Overlord is not seeing anyone at this time. however. I may have work for you. You seem to have some experience with the kobold annoyance in the region. Are you [interested]. " .. e.other:GetName() .. "?")
	elseif e.message:findi("interested") then
		e.self:Say("Then I shall give you a task. I assume you are aware of the kobold lair nearby. Many of our adventurous knights and priests crusade to destroy those pests so seeing many Erudites frequent the area is normal. However. it is not normal to see someone carry large crates into the lair and return empty handed. This person's movements also show he is attempting to remain unseen.....the [fool].")
	elseif e.message:findi("fool") then
		e.self:Say("Whoever it is. obviously is not an Erudite. even though he appears to be. Only an outsider would take us to be such idiots as to fall for their pitiful attempt at disguise. Or perhaps....well. never mind that. I want you to enter the kobold lair and find these crates. Return one to me and we'll decide what to do from there.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1773}) then
		e.self:Say("Hmmm. Very odd. The dust in the crate implies some sort of stone was transported in it. Perhaps our brothers of the Arcane will be able to find out where this dust came from and what it?s used for. Take this dust sample and note to Keletha Nightweaver. She will examine the dust and send you back with a report. Make haste.")
		e.other:SummonItem(1774)
		e.other:AddEXP(137180)
	elseif item_lib.check_turn_in(e.trade, {item1 = 1775}) then
		e.self:Emote("'s eyes redden with intense anger after reading the report. When he speaks, his voice is suprisingly calm and measured.")
		e.self:Say("'Listen close. When you leave this building, you will find the courier who is bringing the ore. You will kill him, and collect his head and a box of the ore. You will then find the supplier, and collect his head and any other information you find on him. Bring me these four things and you will be rewarded. Do not fail.")
		e.other:AddEXP(137180)
	elseif item_lib.check_turn_in(e.trade, {item1 = 1776, item2 = 1777, item3 = 18174, item4 = 1778}) then
		e.self:Say("'Honestly " .. e.other:GetName() .. ", I thought you would not return. Such strength and intelligence in a Knight of Fear I have not seen for quite some time. Wear this in pride of the ancient Ridossan. Perhaps when you are ready, i will give you a more [important task]. This conspiracy must be stopped.'")
		e.other:AddEXP(137180)
		e.other:SummonItem(1764)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
