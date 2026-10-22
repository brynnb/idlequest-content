-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Taralani_Rahnta.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings. " .. e.other:GetName() .. ".  You have found the only place to purchase liquor in this fine city.  It seems that many of my countrymen do not appreciate liquor as I do.  Fear not if you spill. I have plenty of [skeletal servants] to clean up the mess.")
	elseif e.message:findi("what skeletal servants") then
		e.self:Say("Can't you see. child?  These dead servants of mine are bussing tables and dancing!  They work incredibly cheaply.  Heh.  Don't try to harm them. though. they don't like that very much. Say. would you like to see something interesting?")
	end
end
function event_trade(e)
    local item_lib = require("items");
    if item_lib.check_turn_in(e.trade, {platinum = 1000}) then
        e.other:SummonItem(17062); -- Kejekan Tool Kit, lore Koajin's Tools
    end
    item_lib.return_items(e.self, e.other, e.trade);
end
