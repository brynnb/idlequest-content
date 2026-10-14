-- P99: https://wiki.project1999.com/Ridossan%27s_Spirit
-- Ported from upstream/projecteq/stonebrunt; existing faction convenience retained.
function event_spawn(e) eq.set_timer("depop", 300000) end
function event_timer(e)
  if e.timer == "depop" then eq.stop_timer("depop"); eq.depop() end
end
function event_death_complete(e)
  eq.unique_spawn(100222, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
