-- Source: paineel/Gerot_Kastane.pl
-- Shadow Knight Epic 1.0: Gerot Kastane note/head chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 14375, 14376, 14378, 14369

function event_say(e)
	local faction = e.other:GetCharacterFactionLevel(404) -- True Spirit
	if e.message:findi("hail") and faction >= 43 then
		e.self:Say(e.other:GetName() .. "! My hero! I am at your service. I have been told to tell you all I know of the Head of the Valiant.")
		e.self:Say("Bring me the physical head of a valiant warrior. My family preserved the method for creating the Head of the Valiant, and I already have the other materials needed.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local faction = e.other:GetCharacterFactionLevel(404) -- True Spirit
	if faction >= 42 and item_lib.check_turn_in(e.trade, {item1 = 14375}) then
		e.self:Say("At last! I have been waiting for my brother for weeks! Quickly, return this note to Marl, we must hide!")
		e.other:Faction(404, 1)
		e.other:SummonItem(14376) -- Note to Marl
	elseif faction >= 58 and item_lib.check_turn_in(e.trade, {item1 = 14378}) then
		e.self:Say("Good travels, dark one! May Innoruuk curse your enemies!")
		e.other:Faction(404, 7)
		e.other:SummonItem(14369) -- Head of the Valiant
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
