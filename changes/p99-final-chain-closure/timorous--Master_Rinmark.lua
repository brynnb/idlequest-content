-- enabled: false
-- Post-Velious exact chain; complete historical callback body retained.
-- Evidence: changes/p99-final-chain-closure/review.json
-- Converted from ProjectEQ Perl quest script.
-- Source: timorous/Master_Rinmark.pl

function event_spawn(e)
	eq.set_timer("Depop2", 90000)
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("Depop2")
	else
		eq.set_timer("Depop2", 90000)
	end
end

function event_timer(e)
	if e.timer == "Depop2" then
		e.self:Emote("stares off into the horizon, lost in his thoughts.")
		eq.spawn2(96320, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- Rinmark
		eq.stop_timer("Depop2")
		eq.depop()
	end
end
