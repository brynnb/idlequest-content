function event_say(e)

	if(e.message:findi("Hail")) then
		e.self:Say("Greetings, " .. e.other:GetCleanName() .. ", Perhaps you've come to purchase some of my rare supplies? I have a special blend of eleven herbs and spices......oh wait.....I'm sold out of that......anyway. What can I do for you?");
	end
end
