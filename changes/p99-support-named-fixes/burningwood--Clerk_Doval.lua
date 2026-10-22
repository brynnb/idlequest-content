-- enabled: false
-- P99 source-only scope exclusion: Exclusive Shaman Skull step 6 helper, absent from P99 (first five only).
-- Body preserved; no NPC availability or world-table changes.
function event_death_complete(e)
	e.self:Say("All Iksar residents.. shall learn.. of my demise. Ungghh!!");
	eq.signal(87101,1); -- NPC: Atheling_Plague
end

-------------------------------------------------------------------------------------------------
-- Converted to .lua using MATLAB converter written by Stryd
-- Find/replace data for .pl --> .lua conversions provided by Speedz, Stryd, Sorvani and Robregen
-------------------------------------------------------------------------------------------------
