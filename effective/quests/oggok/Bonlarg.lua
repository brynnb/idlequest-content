-- Converted from ProjectEQ Perl quest script.
-- Source: oggok/Bonlarg.pl
-- items: 12198, 13527, 12199

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Shadowknight master me be!!  " .. e.other:GetName() .. " prove to me that " .. e.other:GetName() .. " be worthy to be one with Greenblood and me give " .. e.other:GetName() .. " black shadow tunic.  You [want black shadow tunic]?")
	elseif e.message:findi("i want black shadow tunic") and e.other:GetFaction(e.self) < 5 then
		e.self:Say("You hunt lizard scouts.  Them sometimes carry special fife to talk to other lizards far away.  Greenbloods stop them.  Bring Bonlarg three lizard scout fifes and green stained skin tunic you gots when you first talk to Soonog.  Give all to Bonlarg and get tunic.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:GetFaction(e.self) < 5 and item_lib.check_turn_in(e.trade, {item1 = 12198, item2 = 12198, item3 = 12198, item4 = 13527}) then
		e.self:Say("Took you long time! It easy task, but me guess you still earn black shadow tunic. You wear to show all that you young shadowknight. It help you be smarter likes Bonlarg. It only for young Greenblood shadowknight. Maybe later green shadow tunic you earn or maybe dead you be!")
		e.other:SummonItem(12199)
		e.other:AddEXP(231)
		e.other:Ding()
		e.other:Faction(228, 1, 0)
		e.other:Faction(261, 1, 0)
		e.other:Faction(308, -5, 0)
		e.other:Faction(312, -2, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
