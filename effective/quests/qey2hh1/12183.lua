-- Converted from ProjectEQ Perl quest script.
-- Source: qey2hh1/12183.pl

local werewolf = 0

function event_spawn(e)
	eq.set_timer("Werewolf1Depop", 1800000)
	werewolf = 0
end

function event_death_complete(e)
	werewolf = werewolf + 1
	if werewolf == 4 then
		e.self:Say("Your attack was in vain, fool. The staff was stolen from us by a bandit only hours ago.")
		eq.spawn2(12185, 186, 0, -11080, -2920, 38, 0) -- Shady Bandit
	end
end

function event_timer(e)
	eq.stop_timer("Werewolf1Depop")
	eq.depop()
end

function event_combat(e)
	if e.joined then
		e.self:Emote("moves to attack.")
	else
		e.self:MoveTo(e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading(), true)
	end
end
