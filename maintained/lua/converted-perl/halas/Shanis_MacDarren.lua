-- IdleQuest starting guild note turn-in.
-- Source: halas/Shanis_MacDarren.pl
-- items: 36003, 36009

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 36003}) then
		e.self:Say("I was hoping ye would see the wisdom of joining our fine guild. Take this tunic; it's not much, but it will keep yer bones from freezing and give you a wee bit o' protection.")
		e.other:SummonItem(36009)
		e.other:AddEXP(100)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
