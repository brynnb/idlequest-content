-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Bidl_Frugrin.pl
-- items: 13276

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings! Do you not find the wine of Kelethin as sweet as their women?")
	elseif e.message:findi("lens") then
		e.self:Say("Oh my!! I forgot I had that. Here you are. You better take it back I need to go elsewhere, bye now.")
		e.other:SummonItem(13276)
	end
end
