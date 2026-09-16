-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/#a_zombie.pl
-- items: 18804

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18804}) then
		e.self:Say("Rele.. ase.. me.. from.. this.. tor.. ment.. ARGH! You will die for entering the domain of the Bloodsabers!! Karana.. help.. me?")
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_death_complete(e)
	e.self:Say("ARGH!!!!!.. Thank.. you..")
end
