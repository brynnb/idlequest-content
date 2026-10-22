-- Source: timorous/Alrik_Farsight.pl
-- Ranger Epic 1.0: Alrik Farsight gives Ancient Pattern.
-- Converted from ProjectEQ Perl quest script.
-- items: 20457, 20474, 18960

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ah. Hello there, adventurer. Come to search for ancient artifacts with Fizzlebik and myself?")
	elseif e.message:findi("artifacts") then
		e.self:Say("Oh. All types of things. This area is great. So many artifacts and remains of things all over. It's starting to fall into the pattern of things.")
	elseif e.message:findi("ancient bowl") or e.message:findi("ancient type of bowl") then
		e.self:Emote("rummages through his tattered bag and throws aside a towel. 'Too many towels. Oh well, someone told me they were good to have once. Here it is, a bowl pattern. Interesting bowl. Looks almost like a magical bowl but I'm no potter. You need it, you say? Well, it is interesting. Part of my research here is for the wizard guild in Felwithe. I'm sure they'd put a high price on this one, the enchanters guild being so interested in trading for magical paraphernalia and all. Of course if you helped me out on a chore I have, I'd be happy to give it to you. I need to deliver an artifact to the guild and I'd much rather stay here exploring. If you wish, you can take the artifact and return with the receipt and I'll give you the pattern.'")
	elseif e.message:findi("take the artifact") then
		e.self:Say("Hah! Okay, then. Here take this to Farios Elianos in Felwithe. He will give you the receipt.")
		e.other:SummonItem(20457) -- Crushed Pot
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20474}) then
		e.self:Emote("grins happily.")
		e.other:SummonItem(18960) -- Ancient Pattern
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
