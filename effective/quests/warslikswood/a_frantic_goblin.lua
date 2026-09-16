-- Converted from ProjectEQ Perl quest script.
-- Source: warslikswood/a_frantic_goblin.pl

function event_spawn(e)
	eq.set_timer("signal_master", 60000)
end

function event_timer(e)
	if e.timer == "signal_master" then
		eq.stop_timer("signal_master")
		eq.signal(79127, 1) -- Raving_Goblinmaster
	end
end

function event_death_complete(e)
	eq.signal(79127, 2) -- Raving_Goblinmaster
end

function event_signal(e)
	eq.depop()
end
