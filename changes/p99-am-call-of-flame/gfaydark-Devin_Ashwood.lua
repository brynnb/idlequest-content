-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Devin_Ashwood.pl
-- P99: Lily, not Devin, gives the letter after checking Ranger level 50+.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Good day to you. " .. e.other:GetName() .. "!  I am Devin Ashwood.  Pleased to make your acquaintance.")
	elseif e.message:findi("marry") then
		e.self:Say("Bah! Why would the greatest forester in all of Norrath ask you to marry him? Between his time spent protecting wildlife, hunting poachers and training me, I doubt he has any spare time for a foolish girl like you, sister.")
		e.self:Emote("Lily Ashwood sulks.")
	elseif e.message:findi("ganelorn oast") then
		e.self:Say("Ganelorn Oast! For he has single-handedly caught more poachers than any other ranger. He is credited for helping numerous endangered species recover from certain extinction. I suppose I am lucky he is fond of my sister, as I am soon to train under him as an apprentice. Perhaps one day I will even [call upon the flames] in the way that he does.")
	elseif e.message:findi("call upon the flames") then
		e.self:Say("Aye, Ganelorn is renowned not only for his abilities as an archer and a master of melee combat, but also for his use of powerful magics. Never before have I seen a forester evoke a fireball of such great force. It would be any ranger's dream to become his pupil just to study that one spell. Ganelorn doesn't train just anyone, though. If you want to learn from him, I'm certain you would have to prove yourself as a forester.")
	elseif e.message:findi("i want to learn") then
		e.self:Say("He is a very busy individual. I believe he is currently in the eastern part of the Karanas trying to track down a poacher. Even if you can track him down, don't get your hopes up.")
		e.self:Say("Oh! If you're going to see him, would you please take this letter to him? I trust you, since you're a ranger and all.")
	end
end
