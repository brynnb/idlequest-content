-- P99: https://wiki.project1999.com/Ridossan%27s_Spirit
-- Ported from upstream/projecteq/stonebrunt; existing faction convenience retained.
function event_spawn(e)
  e.self:Emote("gazes upon his lance and begins to laugh maniacally.")
  e.self:Say("AH HAH! I am corporeal once more! I cannot hold this form for long, but it will be long enough for me to rip open that flea brothel and... well, I won't spoil it for you, heheheheh. Come! Assist me in the attack on the Kejekan village! The one that wears the iron beads must die at my hands and NO OTHER! Just make sure I get to him and you will be rewarded.")
  e.self:SetRunning(true)
end
function event_waypoint_arrive(e)
  if e.wp == 6 then eq.unique_spawn(100133, 0, 0, -629, 1219, 1028, 79) end
end
