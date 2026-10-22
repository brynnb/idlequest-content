-- enabled: false
-- P99 scope: Exclusive Berserker epic support: Enraged Imp death creates Ireblind Imp. Berserker was introduced with Gates of Discord. Historical body retained below.
function event_death_complete(e)
	
	eq.spawn2(72069,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),0); -- NPC: Ireblind_Imp
end
-------------------------------------------------------------------------------------------------
-- Converted to .lua using MATLAB converter written by Stryd
-- Find/replace data for .pl --> .lua conversions provided by Speedz, Stryd, Sorvani and Robregen
-------------------------------------------------------------------------------------------------
