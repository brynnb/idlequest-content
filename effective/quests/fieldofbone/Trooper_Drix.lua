-- Converted from ProjectEQ Perl quest script.
-- Source: fieldofbone/Trooper_Drix.pl
-- items: 48006, 48014, 48012, 48008

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Can't you see I am busy on patrol!")
	elseif e.message:findi("calling") then
		e.self:Say("I am the leading authority on restoring and deciphering hidden messages. I can probably make out the message if you can bring me back some [items] I commonly use.")
	elseif e.message:findi("what items") then
		e.self:Say("I will need your message, a frost crystal, a sarnak war braid, and some silver oxide. Bring these items back to me and be quick about it.")
		e.other:SummonItem(48006)
		e.other:SummonItem(48014)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 48006}) then
		e.self:Say("Ah, I see you know my true [calling].")
	elseif item_lib.check_turn_in(e.trade, {item1 = 48012}) then
		e.self:Say("Let me see now.")
		e.self:Emote("Trooper Drix uses the mixture you brought him and spreads it evenly across your document. It settles into all the wrinkles and with the speed of a Master, Trooper Drix uses the sarnak braid to seal the pieces as one.")
		e.other:SummonItem(48008)
		e.self:Say("Take this sealed note back to whoever you need to. I dare not say what it reads out loud.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
