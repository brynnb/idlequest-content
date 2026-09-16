-- Converted from ProjectEQ Perl quest script.
-- Source: droga/v1/a_goblin_dirt_criminal.pl

function event_combat(e)
	if not e.joined then
		return
	end
	e.self:Say(eq.ChooseRandom("Your kind is not welcome here! Prepare to die!", "Your dead corpse will soon line my pockets with gold!", "How dare you enter our realm!", "Death will come quickly!", "Halt! who enters here?"))
end
