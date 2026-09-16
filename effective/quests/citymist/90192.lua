-- Source: citymist/v1/90192.lua
-- Magician Epic 1.0: black reaver placeholder that can spawn #Neh`Ashiir.
--
-- Numeric NPC scripts under ProjectEQ version folders are not imported by the
-- normal Lua importer, so this source-backed override preserves the classic
-- death trigger for the specific placeholder NPC type.
-- name: 90192

function event_death_complete(e)
	local roll = math.random(100)

	if roll <= 15 then
		eq.unique_spawn(90184, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- #Neh`Ashiir
	else
		eq.spawn2(90192, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
	end
end
