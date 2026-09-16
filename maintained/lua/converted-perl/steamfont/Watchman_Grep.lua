-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/Watchman_Grep.pl

function event_trade(e)
	e.self:ReturnHandinItems(e.other)
end

function event_signal(e)
	e.self:Say("What a glorious machine the cargo clockwork is!!")
	eq.signal(56105, 1) -- Cargo_Clockwork
end
