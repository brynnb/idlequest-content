-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Lily_Ashwood.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello there, " .. e.other:GetName() .. ". You wouldn't by chance happen to be a ranger, would you?'")
	elseif e.message:findi("i am a ranger") then
		e.self:Say("I sure love a strong ranger. Especially Ganelorn Oast. He's so dreamy and handsome. I think one day he's going to ask me to marry him.")
	elseif e.message:findi("i will take him the letter") then
		if e.other:GetClassName() == "Ranger" and e.other:GetLevel() >= 50 then
			e.self:Emote("smiles sweetly. 'Thank you sooo much.'")
			e.other:SummonItem(20876) -- Love Letter (Sealed)
		else
			e.self:Say("I'm sorry, I don't trust you with such a task.")
		end
	end
end
