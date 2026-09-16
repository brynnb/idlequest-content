-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Lynsalai_T-Nyal.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings. " .. e.other:GetName() .. ". The Neriak signal is a newspaper that reports all the events important to the Teir`Dal. which frankly. is the only news that is truly important.")
	end
end
