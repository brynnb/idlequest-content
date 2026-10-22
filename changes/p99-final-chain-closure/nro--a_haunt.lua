-- enabled: false
-- Post-Velious exact chain; complete historical callback body retained.
-- Evidence: changes/p99-final-chain-closure/review.json
function event_death_complete(e)
  eq.spawn2(392105,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading()); -- NPC: a_spirit
end

function event_spawn(e)
	e.self:Say("Please, allow us to continue our work. Do not allow this man to return to his ways.");
end