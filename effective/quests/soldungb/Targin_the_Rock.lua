-- Converted from ProjectEQ Perl quest script.
-- Source: soldungb/Targin_the_Rock.pl

local line = "You have much to learn.' and 'Your actions and history are a personal affront to all I stand for."

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say(line)
	end
end

function event_attack(e)
	e.self:Say(line)
end
