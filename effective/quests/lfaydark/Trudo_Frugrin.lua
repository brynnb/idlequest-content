-- Converted from ProjectEQ Perl quest script.
-- Source: lfaydark/Trudo_Frugrin.pl
-- items: 13275

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What. what?!! I am quite busy here. I have studies to complete and charts to make!")
	elseif e.message:findi("lens") then
		e.self:Say("Yes, of course. Here you are. Now be off.")
		e.other:SummonItem(13275)
	end
end
