-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/Oracle_Jaarl.pl

function event_say(e)
	if e.message:findi("i have come to worship") then
		e.self:Say("Very well. You worship quietly then. May Brell Serilis bless you.")
	elseif e.message:findi("i have come to pay your respects") then
		e.self:Say("You have. well then! You can pay your respects by bringing me a [present].")
	elseif e.message:findi("i have come to pay my respects") then
		e.self:Say("You have. well then! You can pay your respects by bringing me a [present].")
	elseif e.message:findi("what present") then
		e.self:Say("I like necklaces. I wear necklaces made from every kind of beast. The power of the beast is contained within each necklace. The more necklaces I wear. the greater my power! Bring me a Bear Fang Necklace. a Wolf Fang Necklace and a Panther Fang Necklace. This will show your devotion to the temple. Then perhaps I can do you a [favor].")
	elseif e.message:findi("I") then
		e.self:Say("You have. well then! You can pay your respects by bringing me a [present].")
	elseif e.message:findi("I") then
		e.self:Say("Very well. You worship quietly then. May Brell Serilis bless you.")
	elseif e.message:findi("I have come to pay respects") then
		e.self:Say("You have. well then! You can pay your respects by bringing me a [present].")
	end
end
