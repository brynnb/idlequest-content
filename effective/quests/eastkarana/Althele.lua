-- Source: eastkarana/Althele.pl
-- Ranger Epic 1.0: Althele starts and closes the East Karana druid chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 20448, 20450, 20452, 18959

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, friend. Beautiful is what I would call such a day normally, but lately I sense that something is out of balance.")
	elseif e.message:findi("out of balance") then
		e.self:Say("Please, if you come across anything suspicious bring it to me.")
	end
end

-- Epic 1.0 ceremony from Althele.pl. Delays are milliseconds in Lua.
function event_signal(e)
	if e.signal == 15178 or e.signal == 15167 then
		eq.signal(e.signal, 1)
	elseif e.signal == 1 then
		eq.set_timer("prep", 90000)
		eq.set_timer("attack", 120000)
		eq.set_timer("depop", 600000)
		eq.signal(15170, 1)
	end
end

function event_timer(e)
	if e.timer == "prep" then
		eq.stop_timer("prep")
		e.self:Say("Great mother of life and father of sky, growth and spirit, Tunare and Karana. Innoruuk once again schemes and we have failed in our duties to protect our land. We give our powers in sacrifice for your help. Heed our call and send us your wisdom.")
		eq.signal(15178, 99, 3000)
		eq.signal(15167, 99, 6000)
		eq.signal(15170, 99, 9000)
		eq.signal(15043, 99, 12000)
	elseif e.timer == "attack" then
		eq.stop_timer("attack")
		e.self:Emote("snaps her head towards you. 'Innoruuk's brood is upon us. Go, find the spawn of hatred before they reach this point and destroy them!'")
		-- IdleQuest approximation: players fight the attackers; the druids do
		-- not. Preserve ordinary actor stats/loot. General NPC combat: issue #29.
		eq.spawn2(15153, 0, 0, -996, -1529, 354, 260)
		eq.spawn2(15150, 0, 0, -1090, -1529, 355.4, 260)
		eq.spawn2(15150, 0, 0, -1063, -1490, 367.5, 260)
	elseif e.timer == "depop" then
		eq.stop_timer("depop")
		for _, id in ipairs({15178, 15167, 15170}) do eq.depop(id) end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20448}) then
		e.self:Emote("looks at the coin and nods gravely.")
		e.self:Say("Here, take this amulet and find Sionae. She is nearby.")
		e.other:SummonItem(20450) -- Braided Grass Amulet
		eq.spawn2(15178, 0, 0, -1595, -2595, 3.2, 254)
	elseif item_lib.check_turn_in(e.trade, {item1 = 20452}) then
		e.self:Say("Dire news, indeed. Take this, read of it, follow its instructions.")
		e.other:AddEXP(100000)
		e.other:SummonItem(18959) -- Earth Stained Note
		-- Successful hand-in ends the whole circle, not only its spokesperson.
		for _, id in ipairs({15178, 15167, 15170, 15043, 15042}) do eq.depop(id) end
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
