-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Roary_Fishpouncer.pl
-- items: 12318, 7027

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Rrrr.. catching and prrreparing fish is my specialty. Perrrhaps you could fetch for me some [rrrare fish] so that I may demonstrate my skill? Rrrr.")
	elseif e.message:findi("rrrare fish") then
		e.self:Say("Rrrr.. my most delectable dish is prrreparrred frrrom rrraw darkwater piranha. Unforrrtunately. the pirrranha only surrrvives in the murrrky waterrrs of the wicked Nektulos forrrest. I will rrreward any brrrave fisherman who can brrring me some rrraw darkwater pirranha.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12318}) then
		e.self:Say("Rrrr... my mouth is waterrring alrrrready. Ourrr trribe shall feast well tonight. You have prrroven yourself a fisherrrman worrrthy of one of my special spearrrs. They are coated with a specially prrrepared fish oil. When all the oil has washed off, you may rrreturn the spear to me along with a frrresh fish and I will rrreapply the oil for you.")
		e.other:SummonItem(7027)
		e.other:Faction(382, 10, 0)
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
