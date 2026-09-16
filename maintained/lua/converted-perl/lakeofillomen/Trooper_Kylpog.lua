-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Trooper_Kylpog.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("My father once dove to the depths of the lake.  He said there were many dangers. but reported seeing structures still standing and glints of treasure in the muck below.")
	end
end
