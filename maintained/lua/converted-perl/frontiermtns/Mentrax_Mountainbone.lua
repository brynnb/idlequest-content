-- Source: frontiermtns/Mentrax_Mountainbone.pl
-- Warrior Epic 1.0: Mentrax Mountainbone trades Giant Sized Monocle for Rejesiam Ore.
-- Converted from ProjectEQ Perl quest script.
-- items: 20678, 20666

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What be it you want! Go away before I eat you for dinner!")
	elseif e.message:findi("wenden sent me") then
		e.self:Say("Did he? Perhaps you would like to trade for some Rejesiam ore? Bring me the monocle from the patriarch that wanders around the Dreadlands. I've always wanted one of those.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20678}) then
		e.self:Say("Eh, you actually found one! Thank you, " .. e.other:GetName() .. ". Here is a block of ore for you. Just don't let the other giants know.")
		e.other:SummonItem(20666) -- Rejesiam Ore
		e.other:AddEXP(25000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
