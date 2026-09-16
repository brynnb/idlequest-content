-- Source: kithicor/General_V-ghera.pl
-- Rogue Epic 1.0: General V-ghera accepts Stanos' head.
-- Converted from ProjectEQ Perl quest script.
-- items: 28058, 2475

function event_say(e)
	if e.message:findi("Stanos") then
		e.self:Say("Stanos? Stanos!! That dog, I WILL see him dead for what he cost me. Outcast I am, stripped of my position, my god has forsaken me, blaming ME for the loss of some tome. And you, " .. e.other:GetName() .. ", you have aided him. For that, you will die first. Please, struggle and beg, I do so enjoy watching my victims squirm, and I have little joy left in my life now. If you want my favor, perhaps if you came bearing Stanos' head I would be more forgiving. But I doubt it.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 28058}) then
		e.self:Say("Life is indeed sweet! Thank you, " .. e.other:GetName() .. ", you have done me a great service this day. Take this, Stanos was kind enough to return it to me, and I have no use for it now. Know that you have the blessing of Innoruuk for this deed! But of course, I leave it to you to leave here alive. A leader has to feed his minions, you know.")
		e.other:SummonItem(2475) -- Guise of the Coercer
		e.other:AddEXP(500000)
		e.other:Ding()
		e.other:Faction(420, 20, 0) -- Fallen of Bloody Kithicor
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
