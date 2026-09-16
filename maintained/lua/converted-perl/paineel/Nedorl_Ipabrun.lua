-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Nedorl_Ipabrun.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Buy. or leave.  Make up your mind.  I have no time for idle chitchat.")
	end
end
