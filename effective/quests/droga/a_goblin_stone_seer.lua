-- Converted from ProjectEQ Perl quest script.
-- Source: droga/v1/a_goblin_stone_seer.pl

function event_combat(e)
	e.self:Say("The time has come for you to taste the might of my magic")
end

function event_death_complete(e)
	e.self:Emote("'s corpse tries to mumble one last spell before falling over dead.")
end
