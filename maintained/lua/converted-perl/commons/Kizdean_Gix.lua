-- Converted from ProjectEQ Perl quest script.
-- Source: commons/Kizdean_Gix.pl
-- items: 18891, 18889

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("If you have business then out with it!! If not, then please be gone. I have little time to waste on chitchat!")
	elseif e.message:findi("utalk adarev otcin") then
		e.self:Say("You speak the words of the Dead. You must be the assistance Loveal was to send. You must work quickly! Inside Befallen are the three pieces to the [Thex Mallet] which are to be returned to Loveal. Find Hubard L'rodd. He was my assistant. Give him this note and he should have information.")
		e.other:SummonItem(18891)
	elseif e.message:findi("messages for neriak") then
		e.self:Say("It's about time a courier reached these wastelands of humanity. I have urgent news for the Dead. Take this message at once. Let no one stop you. Be on the lookout for the Feir'Dal [Silent Watch]! They have learned of our quest.")
		e.other:SummonItem(18889)
	elseif e.message:findi("silent watch") then
		e.self:Say("The Koada'Dal have created an elite band of paladins, greater even than our own Teir'Dal Dragoons. They exist on the edge of righteousness. They will perform despicable acts in the name of their deity, barely skimming the edge of evil.")
	end
end
