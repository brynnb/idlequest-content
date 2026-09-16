-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/the_Court_Chronicler.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". May I interest you in one of the tomes of our history?")
	end
end
