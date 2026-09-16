-- Converted from ProjectEQ Perl quest script.
-- Source: tox/a_heretic_prophet.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Haha!! Another victory for our lord Cazic-Thule!  May your corpse be a dread-inspiring sign to those who travel this forest!")
	end
end
