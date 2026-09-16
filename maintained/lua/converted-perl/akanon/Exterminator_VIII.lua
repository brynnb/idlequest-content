-- Converted from ProjectEQ Perl quest script.
-- Source: akanon/Exterminator_VIII.pl
-- items: 10967

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, citizen. Welcome to Akanon. *whirr whirr* Mission *Terminate Vermin* initiated. Bring four clockwork rat leg sections from defective cleaners for reward. All defective models must be eradicated *bzzzt whirr*.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10967, item2 = 10967, item3 = 10967, item4 = 10967}) then
		e.self:Say("Four Clockwork Rat Leg Sections recieved *bzzzt* processing reward. Reward mode initiated. Coins given. Mission *Terminate Vermin* reset one second *bzzt whirr*.")
		e.other:Faction(333, 10, 0) -- King Ak'Anon
		e.other:Faction(245, 10, 0) -- Eldritch Collective
		e.other:Faction(255, 10, 0) -- Gem Choppers
		e.other:Faction(238, -10, 0) -- Dark Reflection
		e.other:Faction(287, -10, 0) -- Meldrath
		e.other:AddEXP(5)
		e.other:GiveCash(1, 1, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
