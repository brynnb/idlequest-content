-- IdleQuest starting guild note turn-in.
-- Source: paineel/Mandaril_Dark_Knife.pl
-- P99 audit: Guild Summons - The Fell Blade
-- items: 18017, 13573

function event_spawn(e)
	local xloc = e.self:GetX()
	local yloc = e.self:GetY()
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50)
end

function event_enter(e)
	if e.other:HasItem(18017) then
		e.other:Message(MT.Yellow, "Mandaril Dark Knife glances at you with obvious scorn. 'Are you here to seek the ways of the Dark Truth? If that is the case, then read the note in your inventory and then hand it to me. If you are not here for such a purpose, I suggest you leave at once lest you anger me further.'")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Desist in your prattle. If you want idle chitchat. talk to someone else.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18017}) then -- Fell Blade Guild Note
		e.self:Say("You are welcomed into the fold. Now go out and prove yourself, young one. You have much to learn about the Dark Truth.")
		e.other:SummonItem(13573) -- Blood-Spattered Tunic
		e.other:Ding()
		e.other:Faction(265, 100, 0) -- Heretics
		e.other:Faction(242, -100, 0) -- Deepwater Knights
		e.other:Faction(254, -100, 0) -- Gate Callers
		e.other:Faction(231, -100, 0) -- Craftkeepers
		e.other:Faction(233, -100, 0) -- Crimson Hands
		e.other:AddEXP(100)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
