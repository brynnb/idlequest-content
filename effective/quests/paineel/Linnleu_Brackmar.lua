-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Linnleu_Brackmar.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings. " .. e.other:GetName() .. ".  My wares are few but valuable. including books of research into the less widely known arts of necromancy.  Perhaps you should have a look.")
	end
end
