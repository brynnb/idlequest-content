-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/#Triathalon_Swim_Goggles.pl
-- items: 16889

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome, " .. e.other:GetName() .. "!  Good to see that you came out for the event.  here are some swim goggles to help you cross the lake.  Don't forget to hand these to my friend Bike on the far shore so that you can complete the next leg of the race.")
		e.other:SummonItem(16889)
	end
end
