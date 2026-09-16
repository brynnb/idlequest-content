-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Bugrin_the_Gatherer.pl

function event_spawn(e)
	e.self:Say("You will never take me alive!!")
end

function event_death_complete(e)
	e.self:Say("hisss.. You will never stop the.. Radiant.. Green..")
end
