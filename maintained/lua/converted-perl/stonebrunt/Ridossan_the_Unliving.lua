-- P99: https://wiki.project1999.com/Ridossan%27s_Spirit
-- Ported from upstream/projecteq/stonebrunt; existing faction convenience retained.
function event_spawn(e)
  e.self:Shout("I shall have my revenge!!")
  e.self:SetRunning(true)
end
function event_waypoint_arrive(e)
  if e.wp == 6 then eq.unique_spawn(100133, 0, 0, -629, 1219, 1028, 79) end
end
