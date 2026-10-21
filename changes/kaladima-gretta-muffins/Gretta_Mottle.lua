-- Converted from ProjectEQ Perl quest script.
-- Source: kaladima/Gretta_Mottle.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings. " .. e.other:GetName() .. ".  I'm Gretta Mottle.  Tumpy has been kind enough to let me to set up my bakery in his fine establishment here.  Unfortunately. with that nasty plague corruptin' the crops in the Plains of Karana. things are goin' a bit slow for me.  I keep runnin' out of bread and muffins to sell.  Because of flour bein' easily spoiled now. it takes longer to make 'em just right.  My assistant Buggle is still learnin' how to cook.  Hehe.. All he can make is Meat Pie.  If I don't get any [help to bake] soon I won't be able to keep the supply up with the demand.")
	elseif e.message:findi("help to bake") then
		e.self:Say("Glad to hear it.  Are ye thinkin' of helpin' me to [bake muffins] or did ye want to [fetch some bread] for me?")
	elseif e.message:findi("bake muffins") then
		e.self:Say("Ah, if ye want to help me with the bakin', take this Muffin Crate, fill it up with some of your freshly baked Muffins, then seal them in so they won't become stale. I sure hope you can make 'em good enough.")
		e.other:SummonItem(17881)
	elseif e.message:findi("fetch some bread") then
		e.self:Say("The only one who can make bread almost as good as I can is Jarlen Meadowgreen.  He lives a long way off though.. in the southern Plains of Karana.  If ye travel there. tell him that you are there to pick up some bread loaves for me.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
		e.self:Emote("smells the aroma in the air and says, 'Mmm... Mmm... That sure smells good. You truly are a fine baker. Here, take this payment for such fine bakin.'")
		e.other:Faction(290, 2, 0)
		e.other:Faction(312, 1, 0)
		e.other:Faction(322, -1, 0)
		e.other:Faction(293, 1, 0)
		e.other:Faction(274, 1, 0)
		e.other:GiveCash(0, 0, math.random(5, 8), 0)
		e.other:AddEXP(500)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
