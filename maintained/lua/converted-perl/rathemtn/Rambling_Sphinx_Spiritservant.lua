-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Rambling_Sphinx_Spiritservant.pl

function event_spawn(e)
	e.self:Emote("has a dark glow in its eye as it rushes toward you.")
end

function event_death_complete(e)
	e.self:Say("babbles incoherently as the glow in its eyes is extinguished")
	eq.spawn2(50230, 0, 0, -3241, 3550, 39, 1224)
end
