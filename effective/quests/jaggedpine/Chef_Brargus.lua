-- Source: jaggedpine/Chef_Brargus.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 8194, 18430, 54240

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Whatchoo want?")
	elseif e.message:findi("dryad pate") then
		e.self:Say("You want my secret recipe for Nymph Pate? You don't look like you could even cook a Patty Melt without making a disgusting mess, let alone something as delicate and refined as Nymph Pate!")
	elseif e.message:findi("patty melt") then
		e.self:Say("Yeah, you know a patty melt! It's like a Grilled Cheese Sandwich with some meat stuck in between the whole mess. Sheesh, are you a vegetarian or something?")
	elseif e.message:findi("grilled cheese sandwich") then
		e.self:Say("Great Brell's gravy, you are inept aren't you! I'll say this slowly. You take some bread, then you take some cheese then you put them together and cook it with a frying pan! I'll tell you what, if you can manage to figure out how to make a Patty Melt, bring it back to me and if it's halfway edible I'll give you my recipe for Nymph Pate.")
	elseif e.message:findi("firwyn") then
		e.self:Say("Ah, talked to Feyana did you? I'm surprised she trusted the likes of you with something like this. I suppose it's no loss to her if you just wind up dead now is it? If you want to know where to find Firwyn you're going to have to bring me some mountain pooka meat. I'm working on a new recipe and I simply must have it. Off with you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8194}) then
		e.self:Emote("wolfs down the Patty Melt in one bite.")
		e.self:Say("Yeah, this isn't too bad I guess. Not nearly as good as I could have done though.")
		e.self:Emote("scribbles on a piece of paper and hands it to " .. e.other:GetName() .. ".")
		e.self:Say("Here is the recipe you wanted.")
		e.other:SummonItem(18430) -- Elegant Pates
	elseif item_lib.check_turn_in(e.trade, {item1 = 54240}) then
		e.self:Say("That should do nicely. Now, about Firwyn. You should be able to find her in the forest nearby but I would be careful if I were you. She can be a bit feisty, and you don't exactly look like a warrior if you know what I mean.")
		eq.spawn2(181226, 0, 0, -386, -37, -27.3, 100) -- #Firwyn
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
