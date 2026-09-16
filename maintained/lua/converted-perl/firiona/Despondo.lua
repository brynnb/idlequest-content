-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Despondo.pl
-- items: 10027, 12962, 10021, 12964, 10028, 12963, 12967, 12966, 12965, 12968

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("looks a bit troubled. 'Welcome, Welcome adventurer, I am the wizard tutor Despondo, although few need tutorage around here. It would seem that this is no place for a student of any sorts. The lands of Kunark are quite deadly.'")
	elseif e.message:findi("wrong") then
		e.self:Say("I was bound to this post by General Veredeth. I came to find the lost souls of my friends, but am needed here. I must find a fellow wizard to [rescue their souls].")
	elseif e.message:findi("rescue their souls") then
		e.self:Say("You will need the [three bottles of entrapment]. If you can find their remains in Kunark then you will give the bottle to the body and the soul shall enter. Return all three bottles and I shall give you the wizard spell [Brain Bite].")
	elseif e.message:findi("three bottles of entrapment") then
		e.self:Say("I will need three gems to prepare the bottles. I am afraid I left my currency within the Freeport Vault. You will have to get the gems I need: a peridot, an onyx and a star rose quartz then I will give you the bottles.")
	elseif e.message:findi("brain bite") then
		e.self:Say("Brain Bite is a concussion spell created by my former friends whose souls are now lost to Kunark. The blow to the inner brain of an enraged foe may just cause the loss of memory and lower their rage. If you want a copy you have to [rescue their souls].")
	elseif e.message:findi("where are their souls") then
		e.self:Say("I have had visions of their sourroundings. Hampton is in a forest of trees which rain oranges. Ryla fell within a great fortress of armored dog men. Mardon met his fate high in a palace above the jungle leaves.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10027}) then
		e.other:SummonItem(12962)
		e.self:Say("This bottle is for the one called Hampton. If you look well, you can see his name. ")
	elseif item_lib.check_turn_in(e.trade, {item1 = 10021}) then
		e.other:SummonItem(12964)
		e.self:Say("Identify this when the time comes. It is Ryla's prison.")
	elseif item_lib.check_turn_in(e.trade, {item1 = 10028}) then
		e.other:SummonItem(12963)
		e.self:Say("This bottle is for Mardon. You may be able to identify his name upon it. ")
	elseif item_lib.check_turn_in(e.trade, {item1 = 12967, item2 = 12966, item3 = 12965}) then
		e.self:Emote("embraces the bottles as if they were babes. 'Rejoice my friends!! Your souls are safe. " .. e.other:GetName() .. ", you are a good wizard. You deserve to know the secret of concussion.'")
		e.other:SummonItem(12968)
		e.other:AddEXP(100000)
		e.other:Faction(1022, 20, 0)
		e.other:Faction(326, 20, 0)
		e.other:Faction(312, 20, 0)
		e.other:Faction(441, -60, 0)
		e.other:Faction(313, -60, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
