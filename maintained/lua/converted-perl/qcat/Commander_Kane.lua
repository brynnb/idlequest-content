-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/Commander_Kane.pl
-- items: 13130

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Do you know who I am?!! I am the Commander of the Qeynos Guard!! Do you think I trod through these sewers to speak with you? If so then you are quite mistaken.")
	elseif e.message:findi("bloodsabers") then
		e.self:Say("I have heard whispers of such a group. I believe the Priests of Life spoke the name once. No.. I think it was the Knights of Thunder. Bah!! I cannot remember.")
	elseif e.message:findi("priests of life") then
		e.self:Say("The awe inspiring Temple of Life in North Qeynos is home to the paladins and clerics called the Priest of Life. This temple draws many visitors from far and wide. The resident healer of Qeynos is a member of this temple. They have been assisting us with the extermination of the recent rise of rabid animals within Qeynos Hills.")
	elseif e.message:findi("knights of thunder") then
		e.self:Say("The paladins and clerics of the Knights of Thunder are well respected within this city. They often assist the Qeynos Tower Guards in the Plains of Karana. Their grounds are located to the side of the arena and past a few homes.")
	elseif e.message:findi("nerissa") then
		e.self:Say("You keep you eyes off that sweet innocent girl. She is under my care.")
	elseif e.message:findi("milea") then
		e.self:Say("Milea Clothspinner is an old flame of mine. She would have made a fine wife. Unfortunately for me, she chose to become a fine warrior.")
	elseif e.message:findi("antonius bayle") then
		e.self:Say("How dare you speak the name of Antonius Bayle around me!! Brother he may be, but ruler he is not. We could not possibly have been sired by the same person. The empire of Qeynos would stretch as far to Freeport if I were in control. Emperor Kane.. I like the sound of that.")
	elseif e.message:findi("disease is spreading") then
		e.self:Say("Good to see you, my friend. S'ragg said he would be sending his finest. I pray he is right. Do you feel like [going to Highpass] or [going home]?")
	elseif e.message:findi("highpass") then
		e.self:Say("You will be taking this with you. Give this marked bottle to a man called Barn Bloodstone. He is known to hang around a place called the Golden Rooster. He has a package for me. He will then give you instructions to your next destination. Now, be off! Time is of the essence!")
		e.other:SummonItem(13130)
	elseif e.message:findi("home") then
		e.self:Say("Just as well.  Get the shrine to send me someone of strength.  No more cowards!")
	end
end
