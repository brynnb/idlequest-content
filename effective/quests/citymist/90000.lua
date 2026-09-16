-- Source: ProjectEQ citymist/v0/90000.lua (vendored original).
-- Authority: https://wiki.project1999.com/A_black_reaver
-- Explicit version-0 override: the normal zone loads these NPC IDs, while
-- the upstream top-level importer deliberately does not merge version folders.
-- Retain the source 80% continuation roll; P99 does not specify an exact rate.
-- name: 90000
-- P99 Neh`Ashiir explicitly permits multiple simultaneous copies. Do not use
-- unique_spawn: another living Neh must not consume this cycle's final spawn.
-- chance for random mob respawn on a black reaver death
function event_death_complete(e)
	local chance_spawn = math.random(100);
	if(chance_spawn <= 80) then
		eq.spawn2(90000,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading());
	else
		eq.spawn2(90184,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading()); -- #Neh'Ashir
	end
end
