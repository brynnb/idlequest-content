-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/Hector_the_highway_bandit.pl

function event_signal(e)
	e.self:Say("Victory is mine!")
	eq.depop()
end
