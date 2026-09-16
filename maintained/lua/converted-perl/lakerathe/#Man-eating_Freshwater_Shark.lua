-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/#Man-eating_Freshwater_Shark.pl

function event_spawn(e)
	eq.set_timer("SharkDepop", 1800000)
	eq.set_next_hp_event(75)
end

function event_death_complete(e)
	eq.stop_timer("SharkDepop")
end

function event_timer(e)
	eq.stop_timer("SharkDepop")
	eq.depop()
end

function event_hp(e)
	if e.hp_event == 75 then
		e.self:ModifyNPCStat("max_hit", "1000")
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		e.self:ModifyNPCStat("max_hit", "1250")
		eq.set_next_hp_event(25)
	elseif e.hp_event == 25 then
		e.self:ModifyNPCStat("max_hit", "1300")
	end
end
