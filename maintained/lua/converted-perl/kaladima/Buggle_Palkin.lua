-- Converted from ProjectEQ Perl quest script.
-- Source: kaladima/Buggle_Palkin.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings. " .. e.other:GetName() .. ".  I am Gretta Mottle's assistant. Buggle.  I tend to the bakery for her during the night.  I can only make one thing though..  Meat Pie.  Poor Gretta is in desperate need of help right now so I'm trying to learn how to make muffins for her.")
	end
end
