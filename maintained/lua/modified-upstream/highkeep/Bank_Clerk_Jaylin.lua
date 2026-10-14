-- Source: highkeep/Assistant_Kiolna.lua
-- P99 Bank Clerk Jaylin (NPC6059) replaces Kiolna for these key turn-ins.
-- Do not copy Kiolna's self-introduction onto Jaylin.
function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12143}) then
		e.self:Say("I am sorry to see you check out. Here is all you had in your box. We hope to serve you again. Have a nice day!! Next!")
		e.other:SummonItem(18936)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12193}) then
		e.self:Say("I am sorry to see you check out. Here is all you had in your box. We hope to serve you again. Have a nice day!! Next!")
		e.other:SummonItem(13323)
		e.other:Ding()
		e.other:AddEXP(500)
		e.other:GiveCash(0,4,5,1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
