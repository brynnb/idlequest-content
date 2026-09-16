-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/Soulbinder_Novalu.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings " .. e.other:GetName() .. ". When a hero of our world is slain, their soul returns to the place it was last bound and the body is reincarnated. As a member of the Order of Eternity, it is my duty to [bind your soul] to this location if that is your wish.")
	elseif e.message:findi("bind my soul") then
		e.self:Say("Very well. You will return to this spot when you die.")
		eq.self_cast(2049)
		eq.bind_player()
	end
end
