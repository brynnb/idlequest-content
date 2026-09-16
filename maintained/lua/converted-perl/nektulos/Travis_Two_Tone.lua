-- Converted from ProjectEQ Perl quest script.
-- Source: nektulos/Travis_Two_Tone.pl
-- items: 18158

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. " - Are you [interested] in helping the League of Antonican Bards by delivering some [mail]?")
	elseif e.message:findi("what mail") then
		e.self:Say("The League of Antonican Bards has a courier system made up of travelers and adventurers.  We pay good gold to anyone who will take messages from bards such as myself to one of our more central offices.  Are you [interested]?")
	elseif e.message:findi("i am interested") then
		e.self:Say("I have messages that need to go to - well, right now I have one that needs to go to Freeport.  Will you [deliver] mail to [Freeport] for me?")
	elseif e.message:findi("deliver to freeport") then
		e.self:Say("Take this letter to Felisity Starbright in Freeport.  You can find her at the bard guild hall.  I am sure she will compensate you for your troubles.")
		e.other:SummonItem(18158) -- Bardic Letter (Freeport)
	end
end
