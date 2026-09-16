-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/Phiz_Frugrin.pl
-- items: 18867

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello my friend. Good to meet you.")
	elseif e.message:findi("lens") then
		e.self:Say("Oh my. I have bad news. It was stolen by a dark elf rogue. She fled very quickly. My little legs could not keep up. Here. She dropped this. You must find her. Get it back. We have very few Lenses.")
		e.other:SummonItem(18867)
	end
end
