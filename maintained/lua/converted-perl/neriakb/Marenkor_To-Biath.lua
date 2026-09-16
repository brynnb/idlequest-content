-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Marenkor_To-Biath.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Come in! Come in! Enjoy the sights of the Blind Fish Tavern! We serve the finest alcohol in Neriak!")
	end
end
