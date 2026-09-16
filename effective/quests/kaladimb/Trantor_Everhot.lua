-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Trantor_Everhot.pl
-- items: 12114, 12111

local function has_one_tonic(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["trantor_tumpy_tonics"] == "1"
end

local function reward_spool(e)
	e.self:Say("Thank you, that hit the spot!! Here is the spool, as promised.")
	e.other:SummonItem(12111)
	e.other:AddEXP(1000)
	e.other:Faction(312, 5, 0)
	e.other:Faction(274, 5, 0)
	e.other:Faction(293, 5, 0)
	e.other:Faction(290, 5, 0)
	e.other:Faction(232, -5, 0)
	eq.delete_global("trantor_tumpy_tonics")
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Yes, yes!! I am a very busy man. I've got blueprints to work on, [dwarven wire] to perfect and formulae to calculate. In between those tasks, I have to find time to head down to Irontoe's and down a few Tumpy Tonics.")
	elseif e.message:findi("dwarven wire") then
		e.self:Say("Oh!! Interested in my dwarven wire, are you? Many are. I have no problem letting you use a spool, but I have to warn you that I have not perfected the strength of it yet. I will make you a trade. A couple of [Tumpy Tonics] for a spool.")
	elseif e.message:findi("tumpy tonics") then
		e.self:Say("Aaah!! I love Tumpy Tonics. They were created by Tumpy Irontoe. He was once a member of the famed Irontoe Brigade. Since they disbanded and left for parts unknown he decided to stay in Kaladim and open Irontoe's, the finest well in Faydwer.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12114, item2 = 12114}) then
		reward_spool(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12114}) then
		if has_one_tonic(e) then
			reward_spool(e)
		else
			e.self:Say("Hey!! Only one?!!")
			eq.set_global("trantor_tumpy_tonics", "1", 5, "H1")
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
