-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Pardas_Nalue.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Oh. hello there. " .. e.other:GetName() .. "!  I have been absolutely slaving all day to choose a new [advertisement] for my wonderful store here.  Care to hear what I have?")
	elseif e.message:findi("what advertisement?") then
		e.self:Say("Excellent!  Here goes.  Come to Pardas Nalue's Sinfully Handsome Tailor!  You can get everything you need to be just as good looking as Pardas.  Well. almost everything!  So. do you like it?")
	elseif e.message:findi("Yes, I like it") then
		e.self:Say("I just knew you would!  Come on folks. let's watch the money just come pouring in!  Isn't this absolutely fabulous?!")
	elseif e.message:findi("yes, its absolutely fabulous") then
		e.self:Say("I just knew you would!  Come on folks. let's watch the money just come pouring in!  Isn't this absolutely fabulous?!")
	end
end
