-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Guard_Heridion.pl
-- items: 6378

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Uggg. You needz [keyz]? Rrrrrrr.")
	elseif e.message:findi("key") then
		e.self:Say("Uggggg. Take dis keyz.")
		e.other:SummonItem(6378)
	end
end
