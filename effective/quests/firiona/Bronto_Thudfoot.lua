-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Bronto_Thudfoot.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("What's a kid like you doing in a dangerous place like this?  Shouldn't you be at home having bread. cakes and milk?")
	end
end
