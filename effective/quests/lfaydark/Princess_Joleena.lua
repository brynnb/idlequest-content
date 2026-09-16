-- Converted from ProjectEQ Perl quest script.
-- Source: lfaydark/Princess_Joleena.pl
-- items: 12339, 12333

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am the Fairie Princess, Joleena. You may stay amongst my people, but do not nibble from our homes.")
	elseif e.message:findi("fairie gold dust") then
		e.self:Say("You wish the magical Fairie Gold Dust? Hmmph!! I refuse to offer it to any of the giants of Faydwer. How can I trust any of you. You have crept up upon my me and snatched one of my wings from my back. There will be no Fairie Gold Dust until my wing has been returned to me. You may not be the stalker [who snatched my wing], but all you giants are similar. Prove me wrong and return my wing.")
	elseif e.message:findi("wing") then
		e.self:Say("I did not see the swift giant, I was blinded by the sun glaring off his balding head. I do remember the smell of rust and refuse. How he got past my Clockwork Guardian, Gearheart, is a mystery to us all.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12339}) then
		e.self:Say("My wing!! I am so happy!! Thank you " .. e.other:GetName() .. ". You have proved that I can trust giants once again. Please take a Pouch of Fairie Gold Dust. Its magical properties are desired by all.")
		e.other:AddEXP(1500)
		e.other:SummonItem(12333)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
