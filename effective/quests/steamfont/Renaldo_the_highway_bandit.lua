-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/Renaldo_the_highway_bandit.pl

function event_signal(e)
	e.self:Say("Your servos belong to me!")
	eq.depop()
end
