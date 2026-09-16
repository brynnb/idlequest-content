-- Converted from ProjectEQ Perl quest script.
-- Phara Dar warded-door behavior in Veeshan's Peak.

local sealed_by = {
	108053, -- Xygoz
	108040, -- Druushk
	108047, -- Nexona
	108043, -- Hoshkar
	108050, -- Silverwing
}

function event_click_door(e)
	local door_id = e.door_id
	if e.door ~= nil then
		door_id = e.door:GetDoorID()
	end
	if door_id ~= 56 and door_id ~= 57 then
		return
	end

	local dragons_up = 0
	local entity_list = eq.get_entity_list()
	for _, npc_type_id in ipairs(sealed_by) do
		if entity_list:IsMobSpawnedByNpcTypeID(npc_type_id) then
			dragons_up = dragons_up + 1
		end
	end

	if dragons_up == 0 then
		e.other:Message(0, "You got the door open.")
		eq.force_door_open(56)
		eq.force_door_open(57)
	else
		e.other:Message(0, "A seal has been placed on this door by Phara Dar. Perhaps there is a way to remove it.")
	end
end
