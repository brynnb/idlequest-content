-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Auhrik_Siet-ka.pl
-- items: 17802, 14041, 12993

function event_say(e)
	if e.message:findi("understand common") then
		e.self:Say("Of course you do. Now, listen carefully. It may be too much for your feeble mind to gather all at once, and I hate to repeat myself. Bring me one bat wing, one rat ear, one snake egg, and one fire beetle eye. Take this bag, and make sure it's sealed before you return it to me. Snake eggs spoil. Now, quit staring at me with your jaw hanging open like a dead codfish. I would have mistaken you for one, but dead codfish smell better. Haha!")
		e.other:SummonItem(17802)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 14041}) then
		e.self:Say("Why are you giving this to me? Oh I see. I forgot that rats don't know how to read. Haha! Well, then. I shall read it for you. You do [understand common] don't you? Haha.")
	elseif item_lib.check_turn_in(e.trade, {item1 = 12993}) then
		e.self:Say("Well, that wasn't so hard, was it? I suppose I must now thank you for your services. Now, leave me to my studies. I would tell you what I needed the items for, but that would just cloud your fragile little mind. Off with thee!")
		e.other:AddEXP(2000)
		e.other:GiveCash(5, 3, 0, 0)
		e.other:Faction(265, 5, 0)
		e.other:Faction(242, -5, 0)
		e.other:Faction(254, -5, 0)
		e.other:Faction(231, -5, 0)
		e.other:Faction(233, -5, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
