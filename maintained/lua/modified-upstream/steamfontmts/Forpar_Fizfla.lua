-- Reviewed against P99 Bard Epic Quest: components dialogue supplies the note.
-- Original ProjectEQ lacks that optional-introduction route; preserve both routes.
-- Source: steamfontmts/Forpar_Fizfla.pl
-- Bard Epic 1.0: Forpar Fizfla crafts the Mystical Lute.
-- Converted from ProjectEQ Perl quest script.
-- items: 20378, 20380, 20524, 20525, 5520, 20535, 11602, 11622, 16905, 20536, 20526, 20538

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Get out you pesky " .. e.other:GetRaceName() .. "! I don't need any germs!")
	elseif e.message:findi("mystical instrument") then
		e.self:Say("I have made many mystical instruments in the past. Each one seemed to be better then the last. I have always had a dream of building the world's best lute, but I have yet to find someone brave enough to gather the components needed to make the instrument.")
	elseif e.message:findi("components") then
		e.self:Say("To make a mystical lute I will first need to make several pieces. If you bring me the backbone of an ancient fishman, a strong tentacle from one of the long lost amalgyms, and a petrified skull of a lycanthrope I may be able to create the head and neck of the instrument. If you go out and gather these things, make sure to bring me the note I gave you or I might forget who you are. I am getting quite old, you know.")
		e.other:SummonItem(20380) -- P99: introduction is optional.
	elseif e.message:findi("next pieces") then
		e.self:Say("The next pieces are a little harder to come by than the last set. To make the body of an instrument that will last for ages to come, I need something very special. The scales of a big red dragon and the scales of a big white dragon will make it unbreakable, as well as giving it a unique look. Some metal bits will allow me to hold the body together. Please, if you gather up these things, bring them to me as soon as possible. I have not felt this good in years!")
	elseif e.message:findi("one more to go") then
		e.self:Say("The lute has a head and body. The only thing missing is a set of strings that will never break! I have heard rumors of a living dead poison dragon in the lands of Kunark. If your were somehow able to get your hands on his guts, I could finish the lute. You would have to bring me the head, the body and the undead dragon gut for lute strings!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20378}) then
		e.self:Say("So you know Vedico! What can I do for you? I hope you have not come to have me make another mystical instrument.")
		e.other:SummonItem(20380) -- Forpar's Note to Himself
	elseif item_lib.check_turn_in(e.trade, {item1 = 20380, item2 = 20524, item3 = 20525, item4 = 5520}) then
		e.self:Say("Wow! I didn't think someone like you would be able to gather all of those things.")
		e.other:SummonItem(20535) -- Mystical Lute Head
	elseif item_lib.check_turn_in(e.trade, {item1 = 11602, item2 = 11622, item3 = 16905}) then
		e.self:Say("Wooooooo! You are doing a wonderful job. The body is done! Only one more piece to go!")
		e.other:SummonItem(20536) -- Mystical Lute Body
	elseif item_lib.check_turn_in(e.trade, {item1 = 20535, item2 = 20536, item3 = 20526}) then
		e.self:Say("Goodness! I can hardly contain myself! This will be my greatest creation ever!")
		e.other:SummonItem(20538) -- Mystical Lute
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
