local spawn_x = 0
local spawn_y = 0
local spawn_z = 0
local spawn_h = 0

local function reset_encounter(e)
	e.self:WipeHateList()
	e.self:SetHP(e.self:GetMaxHP())
	e.self:MoveTo(spawn_x, spawn_y, spawn_z, spawn_h, true)
	eq.stop_timer("leash")
	eq.set_next_hp_event(96)
end

function event_spawn(e)
	spawn_x = e.self:GetX()
	spawn_y = e.self:GetY()
	spawn_z = e.self:GetZ()
	spawn_h = e.self:GetHeading()

	local range = 200
	eq.set_proximity(spawn_x - range, spawn_x + range, spawn_y - range, spawn_y + range)
	eq.set_next_hp_event(96)
end

function event_hp(e)
	-- Keep the leash timer active even when damage is pet-driven and normal aggro events are not firing.
	eq.stop_timer("leash")
	event_aggro(e)
	eq.set_next_hp_event(math.max(1, math.floor(e.self:GetHPRatio()) - 9))
end

function event_aggro(e)
	eq.set_timer("leash", 1000)
end

function event_timer(e)
	if e.timer ~= "leash" then
		return
	end

	if e.self:GetX() < -1000 or e.self:GetX() > -650 or e.self:GetY() < -1500 or e.self:GetY() > -1290 then
		reset_encounter(e)
	end
end
