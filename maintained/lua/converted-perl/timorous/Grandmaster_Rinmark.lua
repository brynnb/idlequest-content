-- Converted from ProjectEQ Perl quest script.
-- Source: timorous/Grandmaster_Rinmark.pl

function event_spawn(e)
	eq.set_timer("Depop1", 90000)
end

function event_timer(e)
	if e.timer == "Depop1" then
		e.self:Emote("seems to lose a small amount of concentration.")
		eq.spawn2(96319, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- Master_Rinmark
		eq.stop_timer("Depop1")
		eq.depop()
	end
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("Depop1")
	else
		eq.set_timer("Depop1", 90000)
	end
end
