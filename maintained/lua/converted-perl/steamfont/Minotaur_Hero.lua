-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/Minotaur_Hero.pl
-- P99: https://wiki.project1999.com/Hero_Bracers_Quest

function event_combat(e)
	if e.joined then
		e.self:Say("<Snort!!>.. For Meldrath!!")
	end
end

function event_death_complete(e)
	e.self:Say("I die soon! Meldrath, help me!")
end
