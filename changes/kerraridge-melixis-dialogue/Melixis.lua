-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Melixis.pl
-- items: 14042, 13733, 14043, 13731, 14044, 13732

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to Melixis shop.Rrrr. Feel free to brrrowse through my wares.  Melixis also find some [shiny tings] that she may trade you.")
	elseif e.message:findi("shiny tings") then
		e.self:Say("In Melixis travels of the Odus, she find a [dull ring], a [kinda shiny ring] and a [really shiny ring]. Maybe you want to trade for those tings. Rrrr.")
	elseif e.message:findi("dull ring") then
		e.self:Say("For dat ting? You brrring Melixis some bracket mildew. Rarr.")
	elseif e.message:findi("kinda shiny ring") then
		e.self:Say("Hmm Hamed need faerix spores forrr potion. Rrrrr. You bring some to Melixis and she gives you the kinda shiny ring.")
	elseif e.message:findi("really shiny ring") then
		e.self:Say("You go find degenerated guk weed. Melixis gives you the really shiny ring.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 14042}) then
		e.self:Say("Many thanks.. rrrr.. here is dull ring.")
		e.other:SummonItem(13733)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14043}) then
		e.self:Say("Melixis thanks you, Hamed will be pleased. A kinda shiny ring is yours.")
		e.other:SummonItem(13731)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14044}) then
		e.self:Say("You done good job, furless one. Here is really shiny ring. Rarr..")
		e.other:SummonItem(13732)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
