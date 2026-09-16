-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/library_assistant.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Lots to do! Many books to place and scrolls to file! Feel free to browse but. please. don't make a mess!")
	end
end
