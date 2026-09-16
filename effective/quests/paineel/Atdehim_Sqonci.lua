-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Atdehim_Sqonci.pl
-- items: 13716, 16989, 1437, 7005, 1438

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ah, greetings. I hope you are a student of the way of fear. Within this temple there are many who can teach you to harness your gifts. I am an instructor in the [rituals of fear].")
	elseif e.message:findi("rituals of fear") then
		e.self:Say("So you wish to learn, eh? I am working on a ritual to strike fear into the hearts of the other inhabitants of Odus. The reagents I require for this ritual are the doll of a Kerran priestess, the ichor of a giant wooly spider, your initiate symbol of Cazic-Thule, and a giant snake fang with which to carve my glyphs. Fetch me these components. We shall infect this land with fear, and I shall reward you with the station of disciple of this temple.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13716, item2 = 16989, item3 = 1437, item4 = 7005}) then
		e.self:Say("Excellent, with these items we may perform a frightful ritual. Take this for your service to the tabernacle and your lord Cazic-Thule!")
		e.other:SummonItem(1438)
		e.other:AddEXP(2000)
		e.other:Faction(265, 10, 0) -- Heretics
		e.other:Faction(242, -30, 0) -- Deepwater Knights
		e.other:Faction(254, -30, 0) -- Gate Callers
		e.other:Faction(231, -30, 0) -- Craftkeepers
		e.other:Faction(233, -30, 0) -- Crimson Hands
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
