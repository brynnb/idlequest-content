-- Modified from ProjectEQ Lua.
-- Source: freeporteast/Armorer_Dellin.lua
-- P99 audit: Reserve Militia
-- items: 12273, 3097

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail!! If you be a new reserve member then show me your Militia Armory Token. If you are not yet initiated then I suggest you head to the Toll Gate in the Commonlands and speak with Guard Valon.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if e.other:GetFaction(e.self) > 4 then
		e.self:Say("You have not yet proven yourself enough to join the Freeport Militia reserves.")
	elseif(item_lib.check_turn_in(e.trade, {item1 = 12273})) then
		e.self:Say("Welcome to the Freeport Militia. As a reserve member we require you to wear this tunic and fight when, who and wherever Sir Lucan commands, no questions asked!! There is no turning back!! Remember to keep clear of North Freeport. You have made a wise decision. Hail Sir Lucan!!")
		e.other:SummonItem(3097) -- Reserve Militia Tunic
		e.other:Ding()
		e.other:Faction(330,10,0) -- Freeport Militia
		e.other:Faction(336,10,0) -- Coalition of Tradefolk Underground
		e.other:Faction(281,-30,0) -- Knights of Truth
		e.other:Faction(362,-30,0) -- Priests of Marr
		e.other:AddEXP(10000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
