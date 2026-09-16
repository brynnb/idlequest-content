-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Raving_Sphinx_Spiritservant.pl

function event_spawn(e)
	e.self:Emote("has a dark glow in its eye as it rushes toward you.")
end

function event_death_complete(e)
	e.self:Say("babbles incoherently as the glow in its eyes is extinguished")
	eq.spawn2(50231, 0, 0, -3304, 3476, 28, 1180)
end
