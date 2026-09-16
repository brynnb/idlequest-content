-- Source: rivervale/Hendi_Mrubble.lua
-- P99 audit: Wall Squad Ring
-- items: 14029, 13870, 13935, 13936

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Why, hello there!! Welcome to the Church of Mischief. I am Hendi Mrubble. The 'R' is silent. I am the resident healer of the church, so if you are in [need of healing], or want me to [cure poison] or [cure disease], let me know. If you've got a touch of the crazy brain, I can't do a thing for you.")
	elseif(e.message:findi("healing")) then
		e.self:Say("Hmmm. I would love to help you with that, but you will have to make a donation to the temple. The Guardians asked me to charge one of the Rivervale piranha teeth.")
	elseif(e.message:findi("cure disease")) then
		e.self:Say("Eeww!! Careful, don't touch Hendi. I figured there must have been something not quite right about you. Well, now, before we can cast the disease from your body you will have to make a little donation of one gold for the service and eight gold to disinfect this place. That would be 10 total!! Let's see it.")
	elseif(e.message:findi("cure poison")) then
		e.self:Say("Cure poison, eh? Before we do that, you must fetch me three bixie stingers.")
	end
end

local function recharge_squad_ring(e, item_id)
	if e.other:GetFaction(e.self) < 5 then
		e.self:Say("Here you are, " .. e.other:GetName() .. ". May the silent smile of Bristlebane keep you on your feet.")
		e.other:SummonItem(13936) -- charged Squad Ring
	else
		e.self:Say("I do not know you well enough to bless this ring.")
		e.other:SummonItem(item_id)
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {gold = 10}) then
		e.self:Say("May the swift and silent spirit of Fizzlethorpe Bristlebane smile upon your frail soul.")
		eq.SelfCast(213)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14029, item2 = 14029, item3 = 14029}) then
		e.self:Say("May the swift and silent spirit of Fizzlethorpe Bristlebane smile upon your frail soul.")
		eq.SelfCast(203)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13870}) then
		e.self:Say("May the swift and silent spirit of Fizzlethorpe Bristlebane smile upon your frail soul.")
		eq.SelfCast(12)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13935}) then
		recharge_squad_ring(e, 13935)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13936}) then
		recharge_squad_ring(e, 13936)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
