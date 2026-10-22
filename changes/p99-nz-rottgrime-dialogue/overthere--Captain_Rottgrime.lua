-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/Captain_Rottgrime.pl
-- items: 12982, 12981

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("has numerous cracks and holes in his skull from many battles. 'Attention, marine!! You will go into battle and fear nothing! You shall prevail over one enemy and then you shall be sent back into battle! We [shall not allow those sarnak to overtake the Danak shipyards]! Is that clear marine?!!'")
	elseif (e.message:findi("shall not allow those sarnak to overtake the danak shipyards") or e.message:findi("shall not allow those sarnaks to overtake the danak shipyards")) then
		e.self:Say("Stand up straight!! That is correct marine!! YOU shall not allow the sarnak to overtake the shipyards!! Head out to the frontlines, marine!! Kill the berzerkers and return their war braids to me!! For every four, you shall earn your wages!! Now get to the front, marine!! Move it!! Move it!!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12982, item2 = 12982, item3 = 12982, item4 = 12982}) then
		e.self:Say("Great job marine!! Word of your heroics shall be passed on to the Admiral. If you don't have a shield then take one, if you do then get back to the frontlines. There is no time for R n R!! Move it marine!! Or you'll be pushing Danak till the cockatrice crow!!")
		e.other:SummonItem(12981)
		e.other:Faction(318, 5, 0)
		e.other:AddEXP(10)
		e.other:GiveCash(0, 0, eq.ChooseRandom(1, 2, 3), 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_waypoint_arrive(e)
	if e.wp == 2 then
		e.self:Say("Atteeennntion !!")
		eq.signal(93126, 0)
	end
end
