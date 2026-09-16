-- Source: lakerathe/Shmendrik_Lavawalker.pl
-- Cleric Epic 1.0: Shmendrik Lavawalker starts the Orb of Frozen Water branch.
-- Converted from ProjectEQ Perl quest script.
-- items: 28044, 28045

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, good " .. e.other:GetName() .. "!! Be wary near the waters of Lake Rathe! The Riptide goblin king, Lord Bergurgle, has been commanding his minions to murder and rob all who come near it! I am here seeking his death but I am afraid I am no match for all of his subjects. I shall reward you greatly for the death of Lord Bergurgle. I simply ask that you bring me his crown as proof.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 28044}) then
		e.self:Emote("shoves the crown into a scorch marked leather satchel and cackles uncontrollably as madness twists his features and flames dance in his eyes.")
		e.other:SummonItem(28045) -- Oil of Fennin Ro
		eq.spawn2(51138, 0, 0, 111, 3627.3, 51, 384.8) -- #Natasha_Whitewater
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	if e.signal == 99 then
		e.self:Say("I'll slay you like I slaughtered your fellow missionaries! The Triumvirate can not decide the fate of a follower of the Tyrant!!")
		eq.signal(51138, 199, 2000) -- #Natasha_Whitewater
	elseif e.signal == 299 then
		eq.signal(51138, 399, 2000) -- #Natasha_Whitewater
	elseif e.signal == 499 then
		-- ProjectEQ has Natasha attack Shmendrik here. IdleQuest does not run
		-- full server-side NPC combat, so the e2e harness explicitly defeats
		-- Shmendrik after this signal exchange to continue the encounter.
	end
end

function event_death_complete(e)
	eq.signal(51138, 599, 2000) -- #Natasha_Whitewater
end
