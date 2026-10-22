-- P99 scope: later Paladin2.0-only hail hint removed; ordinary guard combat preserved.
function event_combat(e)
	if e.joined then
		e.self:Say("Time to die " .. e.other:GetCleanName() .. ".");
	end
end