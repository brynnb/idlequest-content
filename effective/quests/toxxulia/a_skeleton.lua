-- Converted from ProjectEQ Perl quest script, guarded to the mining-cap
-- skeleton NPC type ids so unrelated Toxxulia skeletons do not accept caps.
-- Sources: tox/38016.pl, toxxulia/a_skeleton.pl, P99 Mining Caps page
-- items: 13894, 9304, 12195, 13073, 13074, 10011, 10015, 10016, 10018, 10020, 10022, 10023, 10029

local left_miners = {
	[38017] = true,
	[414103] = true,
}

local right_miners = {
	[38016] = true,
	[414104] = true,
}

local function npc_type_id(e)
	return e.self:GetNPCTypeID()
end

function event_say(e)
	if e.message:findi("hail") then
		local id = npc_type_id(e)
		if left_miners[id] then
			e.self:Say("Can't you see we're busy here?!!")
		elseif right_miners[id] then
			e.self:Say("Grab a pick. Give us a hand!!")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13894}) then
		local id = npc_type_id(e)
		if left_miners[id] then
			e.self:Say("Good work, you should be running this operation instead of that Talrigar fellow. Have a small reward. A little bit of the gems I found while tunneling through this rock.")
			e.other:AddEXP(100)
			e.other:SummonItem(eq.ChooseRandom(10011, 10015, 10016, 10018, 10020, 10022, 10023, 10029))
		elseif right_miners[id] then
			e.self:Say("Aye.. You cut out the middleman..  I shall reward you.. hmm..  I have not found anything, how about..  <CRACK!! SNAP!! RIPP!!>  How about something off meself?")
			e.other:AddEXP(100)
			e.other:SummonItem(eq.ChooseRandom(9304, 12195, 13073, 13074))
		else
			e.self:Say("This old skeleton has no use for a mining cap.")
			e.other:SummonItem(13894)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
