-- IdleQuest epic 1.0 steps have no minimum level; preserve class and item checks.
-- Source: qcat/Reania_Jukle.pl
-- Enchanter Epic 1.0: Reania Jukle grants Empty Ink Vial.
-- Converted from ProjectEQ Perl quest script.
-- items: 10626, 18851, 13596

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". What can I help you with?")
	elseif e.message:findi("ink of the dark") then
		e.self:Say("Ink of the Dark, you say? You are going to need to find your own supply now.")
	elseif e.message:findi("supply") then
		e.self:Say("The ink is the blood of a dark scribe. Tempt him and give him this vial.")
		e.other:SummonItem(10626) -- Empty Ink Vial
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18851}) then
		e.self:Say("A new initiate always pleases me, here is your tunic.")
		e.other:SummonItem(13596) -- Dirty Purple Robe*
		e.other:AddEXP(100)
		e.other:Faction(221, 100, 0) -- Bloodsabers
		e.other:Faction(262, -15, 0) -- Guards of Qeynos
		e.other:Faction(296, 10, 0) -- Opal Dark Briar
		e.other:Faction(341, -25, 0) -- Priest of Life
		e.other:Faction(230, 5, 0) -- Corrupt Qeynos Guards
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
