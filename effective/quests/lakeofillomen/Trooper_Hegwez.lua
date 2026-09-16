-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Trooper_Hegwez.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hail. adventurer!  Stay close to the gates or risk your life.  The Lake of Ill Omen is aptly named.")
	end
end
