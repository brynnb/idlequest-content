-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/an_undead_knight_.pl
-- items: 12283, 12284, 13921, 3140, 12285, 12286, 16507, 3141, 12288, 12287, 9023, 3142, 12290, 12289, 19075, 3143

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Leave this place or find yourself [bound to this land] as I am.")
	elseif e.message:findi("bound to this land") then
		e.self:Say("I was torn to pieces for my failure to complete a task for my master. I lost my life, my precious [shadowknight armor] and most of all, my [lower body]!!")
	elseif e.message:findi("shadowknight armor") then
		e.self:Say("My darkforge armor!!  It was taken into the land of lizards by the lizardmen crusaders!! It is worthless decayed armor now!! I cannot even wear it any more, but perhaps you can!!  Would you like me to make [darkforge armor] for you?")
	elseif e.message:findi("lower body") then
		e.self:Say("My lower body was taken from me, along with my hands. I was pieced together using portions of other failed champions. Now I can only create [darkforge armor] in the form of helms, breastplates, vambraces and bracers.")
	elseif e.message:findi("darkforge armor") then
		e.self:Say("Darkforge helms require my decayed helm and visor as well as two Freeport militia helms. The breastplate requires the decayed breastplate, decayed mail and two enchanted platinum bars. Vambraces need both decayed vambraces and a Qeynos Guard kite shield. The bracers require both decayed bracers and a horn from a minotaur lord.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12283, item2 = 12284, item3 = 13921, item4 = 13921}) then
		e.self:Say("Well done, " .. e.other:GetName() .. ", here is your reward.")
		e.other:SummonItem(3140)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12285, item2 = 12286, item3 = 16507, item4 = 16507}) then
		e.self:Say("Well done, " .. e.other:GetName() .. ", here is your reward.")
		e.other:SummonItem(3141)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12288, item2 = 12287, item3 = 9023}) then
		e.self:Say("Well done, " .. e.other:GetName() .. ", here is your reward.")
		e.other:SummonItem(3142)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12290, item2 = 12289, item3 = 19075}) then
		e.self:Say("Well done, " .. e.other:GetName() .. ", here is your reward.")
		e.other:SummonItem(3143)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
