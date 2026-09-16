-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Xenevorash.pl

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 50, x + 50, y - 50, y + 50)
end

function event_enter(e)
	if e.other:GetClassName() == "Monk" and e.other:Level() >= 46 then
		eq.attack(e.other:GetName())
	end
end

function event_death_complete(e)
	e.self:Shout("Grraaaagghhhh!! Not..Possible!")
end
