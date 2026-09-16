-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/Fodin_Frugrin.pl
-- items: 17923, 13277

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello " .. e.other:GetName() .. ". Have you ever peered beyond our little world? Somewhere out there in the vast darkness is a world filled with great technology and adventure. Our people should concentrate on reaching these distant worlds beyond the sparkling skies.")
	elseif e.message:findi("Larkon sent me") then
		e.self:Say("There is much more you must do for the Library of Mechanimagica before such things can be revealed to you. Perhaps fetching minotaur horns and returning them to Professor Theardor will earn you membership to the Library of Mechanimagica. But I suppose if Larkon sent you that you truly wish to prove yourself, eh? You'll have to get your hands a bit dirty, though. Take this box and fill it with livers from those infected rats. We need them for research. Well go on. You can take a bath when you're done.")
		e.other:SummonItem(17923)
	elseif e.message:findi("lens") then
		e.self:Say("Spare Telescope Lens?? I am sorry but I do not have any spares right now.. Oh wait!! I do. Here you are my friend. Careful with that. They are very rare.")
		e.other:SummonItem(13277)
	end
end
