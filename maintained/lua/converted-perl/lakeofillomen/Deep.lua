-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Deep.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("ignores you.")
	end
end

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 50, x + 50, y - 50, y + 50)
end

function event_enter(e)
	if e.other:Class() == "Monk" then
		eq.attack(e.other:GetName())
	end
end
