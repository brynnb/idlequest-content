-- Source: ProjectEQ citymist/v0/90010.lua (vendored original).
-- Authority: https://wiki.project1999.com/A_black_reaver
-- Explicit version-0 override: the normal zone loads these NPC IDs, while
-- the upstream top-level importer deliberately does not merge version folders.
-- Retain the source 80% continuation roll; P99 does not specify an exact rate.
-- name: 90010
-- chance for random mob respawn on a black reaver death
function event_death_complete(e)
	local chance_spawn = math.random(100);
	if(chance_spawn <= 80) then
		eq.spawn2(90010,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading());
	else
		eq.unique_spawn(90174,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading()); -- #Lord_Rak`Ashiir
	end
end
