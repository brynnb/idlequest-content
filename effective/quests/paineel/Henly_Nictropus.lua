-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Henly_Nictropus.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("The Dark Truth reports the news without all the usual propaganda and lies spewed by the mouthpieces of other Kingdoms and principalities. Buy a copy today for just a few silver and find out the real truth behind current events.")
	end
end
