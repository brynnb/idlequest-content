-- Converted from ProjectEQ Perl quest script.
-- Source: kithicor/Morin_Shadowbane.pl
-- P99 Orc Impaler final branch restored from page evidence.
-- P99: https://wiki.project1999.com/The_Orc_Impaler
-- items: 16548, 5422, 5405, 20638, 20639

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetName() .. ". I am the leader of this beleagured troop of rangers. Even though the once fair Kithicor slowly succumbs to the [darkness] at hand, we shall not abandon the woods without a fight.")
	elseif e.message:findi("darkness") then
		e.self:Say("The denizens of these woods are slowly being overrun by dark fiends and shadowed men. As valiantly as we have fought, our numbers dwindle. We know very little about our aggressors, but if we [acquire some information] or perhaps [fine weapons], then we may yet have a chance to retake the woods once more.")
	elseif e.message:findi("acquire some information") then
		e.self:Say("Your tracking skills are invaluable to our cause, brave " .. e.other:GetName() .. ". Our scouts have reported of a Ghoul Messenger. They have spotted him traveling between Kithicor and an undead camp in the Plains of Karana. They have attempted to track the monster and obtain any Strategic Domumentation he may be carrying. Perhaps you can succeed where others have failed. Perhaps you can earn my personal short sword.")
	elseif e.message:findi("fine weapons") then
		e.self:Say("My soldiers are valiant, but poorly equipped. I have heard of a magical weapon of great power, some call it the Ebony Blade. Amongst the Froglocks there can be found a Minotaur who wields this sword of might. If you are a ranger and could provide me with this sword then I would gladly exchange it with my own meager weapon. If you prefer, you may attempt to [acquire some information] for us instead.")
	elseif e.message:findi("another service") then
		e.self:Say("Very well then, your help will bring us closer to solving the mystery of Kithicor! Find Bryn Fynndel in Lesser Faydark and tell him Morin sent you. His band of elven warriors are observing the activities of the Crushbone Orcs and Mistmoore dark elves, perhaps you can help them shed some light on our plight.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 16548}) then
		e.self:Say("Excellent work, " .. e.other:GetName() .. "!! It is obvious that you are a highly skilled tracker and warrior. Accept this reward, my personal sword which has served me well in countless battles.")
		e.other:SummonItem(5422)
	elseif item_lib.check_turn_in(e.trade, {item1 = 5405}) then
		e.self:Say("Excellent work, " .. e.other:GetName() .. "!! It is obvious that you are a highly skilled tracker and warrior. Accept this reward, my personal sword which has served me well in countless battles.")
		e.other:SummonItem(5422)
	elseif item_lib.check_turn_in(e.trade, {item1 = 20638}) then
		e.self:Say("We meet again, " .. e.other:GetName() .. ". This log reveals much of the machinations of our dark oppressors, but not enough. Deliver these orders to Bryn in Lesser Faydark, and he will provide you with another weapon to aid in our defense of Kithicor.")
		e.other:Ding()
		e.other:SummonItem(20639)
		e.other:AddEXP(200)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
