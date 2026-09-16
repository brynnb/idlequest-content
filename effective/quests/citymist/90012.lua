-- Source: citymist/v0/90012.lua
-- Shaman Epic 1.0: black reaver placeholder that can spawn Lord Ghiosk.
--
-- Numeric NPC scripts under ProjectEQ version folders are not imported by the
-- normal Lua importer, so this source-backed override preserves the classic
-- death trigger for the specific placeholder NPC type.
-- name: 90012

function event_death_complete(e)
	local chance_spawn = math.random(100)
	if chance_spawn <= 80 then
		eq.spawn2(90012, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
	else
		eq.unique_spawn(90180, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- Lord_Ghiosk
	end
end

