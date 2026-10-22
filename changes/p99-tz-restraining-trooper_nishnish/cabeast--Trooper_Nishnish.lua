-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Trooper_Nishnish.pl
-- items: 18244, 12465, 18245

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, citizen! Keep clear of the waterways which run through this grand city. For swimming they are not. Many times have playful broodlings fallen prey to the sharp teeth of barracudas.")
	elseif e.message:findi("sign the restraining order") or e.message:findi("sign this restraining order") then
		e.self:Say("So the legion has sent you to have me sign this order, eh? Nay. I shall not do so unless the messenger, you, gathers two barracuda teeth for me. Hand me the legion order when you hand me the two barracuda teeth and then your task shall be complete.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18244, item2 = 12465, item3 = 12465}) then
		e.self:Emote("grabs the barracuda teeth and attaches them to a necklace. 'Good. Now this barracuda charm shall keep me safe from slipping into the waters and becoming a feast for the barracuda. And you, take this legion order and be gone.'")
		e.other:SummonItem(18245)
		e.other:Faction(441, 5, 0)
		e.other:Faction(440, 5, 0)
		e.other:Faction(445, 5, 0)
		e.other:Faction(442, 5, 0)
		e.other:Faction(444, 5, 0)
		e.other:AddEXP(800)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18244}) then
		e.self:Say("You shall get my signature when I have the legion order and two barracuda teeth.")
		e.other:SummonItem(18244)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12465, item2 = 12465}) then
		e.self:Say("You shall get my signature when I have the legion order and two barracuda teeth.")
		e.other:SummonItem(12465, 2)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12465}) then
		e.self:Say("You shall get my signature when I have the legion order and two barracuda teeth.")
		e.other:SummonItem(12465)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
