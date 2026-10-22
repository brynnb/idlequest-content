-- Converted from ProjectEQ Perl quest script.
-- Source: lfaydark/Grynnaf_Einoom.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("looks at " .. e.other:GetName() .. " and wonders if he is looking for the Scalekeeper?")
	elseif e.message:findi("Who is the scalekeeper?") then
		e.self:Say("Ahh...Ye be lookin' for Nortlav then. Nortlav is a strong fella. Ye dunna want to mess with the likes of him. He's known as a dragonslayer. I heard that he keeps the scales of the dragons he's slain. Yer not impressed eh? All the dragons he's killed have died by the blade of a [rusty weapon].")
	elseif e.message:findi("What rusty weapon?") then
		e.self:Say("Aye. I dunno know why he does what he does. But every dragon he's killed died by the likes of a rusty weapon. I dunno where he is now. but I heard he can be found in the depths of Norrath. surrounded by darkness.")
	end
end
