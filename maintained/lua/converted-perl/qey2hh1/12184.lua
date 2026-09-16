-- Converted from ProjectEQ Perl quest script.
-- Source: qey2hh1/12184.pl

function event_spawn(e)
	eq.set_timer("Werewolf2Depop", 1800000)
	eq.set_next_hp_event(75)
end

function event_death_complete(e)
	e.self:Say("Your attack was in vain, fool. The staff was stolen from us by a bandit only hours ago.")
	eq.spawn2(12185, 186, 0, -11080, -2920, 38, 0) -- Shady Bandit
end

function event_timer(e)
	eq.stop_timer("Werewolf2Depop")
	eq.depop()
end

function event_combat(e)
	if e.joined then
		e.self:Emote("moves to attack.")
	else
		e.self:MoveTo(e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading(), true)
	end
end

function event_hp(e)
	if e.hp_event == 75 then
		e.self:ModifyNPCStat("max_hit", "1400")
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		e.self:ModifyNPCStat("max_hit", "1600")
		eq.set_next_hp_event(25)
	elseif e.hp_event == 25 then
		e.self:ModifyNPCStat("max_hit", "1800")
	end
end
