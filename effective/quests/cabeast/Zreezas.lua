-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Zreezas.pl
-- items: 48062, 48063, 48064

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Sorry, I am busy trying to track down a traitor planning on overthrowing the Patriarchs. Unless you are [willing to help], I will have to send you on your way.")
	elseif e.message:findi("help") then
		e.self:Say("Clues have lead me to believe that some corrupt individuals are working in the City of Mist and Kaesora. I have been searching in spiritual areas for clues to this traitor's name. Return to me any information which may help in my investigation.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 48062, item2 = 48063}) then
		e.self:Say("Good work, " .. e.other:GetName() .. ".")
		e.self:Emote("fits the pieces of the plans together and studies them for a moment.")
		e.self:Say("Ah, so the plot thickens. It seems that the rumored attacks are set to be conducted soon. Seek out Ixthal and tell him about these attacks. If he does not believe you, show him these plans as proof.")
		e.other:SummonItem(48064)
		e.other:AddEXP(15000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
