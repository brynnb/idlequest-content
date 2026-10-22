-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Feren.pl
-- items: 6348, 1062

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Rarr.  Me is Feren.  Me is fisher.  That means Feren catches [fish].")
	elseif e.message:findi("fish") then
		e.self:Say("All kinds of fish.  Tasty fish.  All day Feren catches the fishes so all Kerran can eat.  I do for good of all Kerran.  Rrrrr.  One thing bother Feren always though.  Is bad fish.  [Razortooth].")
	elseif e.message:findi("razortooth") then
		e.self:Say("Rrrrrr!  Razortooth mean fish.  Razortooth eat fish off Feren's line.  Razortooth gnaw Feren's boat.  Razortooth smart and dangerous.  Feren never able to catch Razortooth.  This haunt Feren for months.  If you was able to catch Razortooth. Feren be forever grateful. Maybe even give you possessions.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 6348}) then
		e.self:Say("Razortooth! You catch him!  Truly you be great fisher.  Please take this from me.  Feren is forever owing you.")
		e.other:SummonItem(1062)
		e.other:Faction(382, 10, 0)
		e.other:AddEXP(18000)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
