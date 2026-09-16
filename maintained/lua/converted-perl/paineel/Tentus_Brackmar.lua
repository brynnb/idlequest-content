-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Tentus_Brackmar.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hey you!  You watch yourself.  These items are priceless.  You break it. you buy it!")
	end
end
