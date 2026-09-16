-- Source: rathemtn/Brother_Zephyl.pl
-- Monk Epic 1.0: Brother Zephyl gives the Rare Robe Pattern.
-- Converted from ProjectEQ Perl quest script.
-- items: 12317, 10133, 12315, 12256

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings. I am one with the Lost Circle. You have found me. What is it you desire?")
	elseif e.message:findi("lost circle") then
		e.self:Say("The monks of the Whistling Fist are called the Lost Circle by others. Within this realm there are only two. Brother Qwinn and I.")
	elseif e.message:findi("interested monk") then
		e.self:Say("Then venture to the lands of evil. There, seek out a monk called Raster. He has the idol.")
	elseif e.message:findi("idol of zan fi") then
		e.self:Say("The idol of Zan Fi is a totem that is sacred to our brotherhood. Are you an interested monk?")
	elseif e.message:findi("brother qwinn") then
		e.self:Say("Brother Qwinn is searching for one who can return the Code of the Whistling Fist.")
	elseif e.message:findi("return the sash") then
		e.self:Say("Very well. Give to me that which you have been rewarded or the robe, if you have a tailored one.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12317, item2 = 10133}) then
		e.self:Say("We thank you for the return of the idol of Zan Fi. Take this rare robe pattern.")
		e.other:SummonItem(12315) -- Rare Robe Pattern
		e.other:AddEXP(200)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12315}) then
		e.other:SummonItem(10133) -- Red Sash of Order
	elseif item_lib.check_turn_in(e.trade, {item1 = 12256}) then
		e.other:SummonItem(10133) -- Red Sash of Order
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
