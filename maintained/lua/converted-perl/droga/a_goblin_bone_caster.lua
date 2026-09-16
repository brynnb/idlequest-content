-- Converted from ProjectEQ Perl quest script.
-- Source: droga/v1/a_goblin_bone_caster.pl

function event_combat(e)
	e.self:Say("Your soul shall be mine!")
end

function event_death_complete(e)
	e.self:Emote("'s corpse tries to mumble one last spell before falling over dead.")
end
