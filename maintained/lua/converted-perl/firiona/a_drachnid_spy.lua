-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/a_drachnid_spy.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("looks upon you with evil eyes and you hear a horrid chatter. Hairs rise from the spider's thorax. 'Greetings, creature. What a fine meal you would make!'")
		eq.attack(e.other:GetName())
		e.self:Say("You shall not take the tome from me!! I shall snack upon your blood-drained corpse.")
	end
end

function event_death_complete(e)
	eq.signal(84319, 0) -- Hero_Goxnok
end
