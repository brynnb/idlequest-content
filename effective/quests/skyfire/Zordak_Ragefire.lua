-- enabled: false
-- P99 exclusion: see content_exclusions.json quests["skyfire/Zordak_Ragefire"].
-- Converted from ProjectEQ Perl quest script.
-- Source: skyfire/Zordak_Ragefire.pl

function event_death_complete(e)
	eq.spawn2(91090, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
