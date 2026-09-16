-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Feskr_Drinkmaker.pl
-- items: 12360, 14914, 14915, 17969, 17032

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Erh?  If you not be here to help Feskr with his [problem] then Feskr want you to leave.")
	elseif e.message:findi("problem") then
		e.self:Say("You wish to help?  Orrderrr of supplies I rrequest not arrive; ship sink.  Now Feskr needs supplies.  Feskr need bottle of Tunare's Finest. thunderhoof mushroom. tea leaf. and handmade backpack.  Rrrr. strange items but Feskr need to sell.  You bring. Feskr give you nice bag.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12360, item2 = 14914, item3 = 14915, item4 = 17969}) then
		e.self:Say("Ahhh. This will help. Many Kerrans will like these. Here. Take this old bag. I have too many. Maybe it help you.")
		e.other:SummonItem(17032)
		e.other:Faction(382, 5, 0)
		e.other:AddEXP(5000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
