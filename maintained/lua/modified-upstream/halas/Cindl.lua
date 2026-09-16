-- Source: halas/Cindl.lua
-- P99 audit: Cindl's Polar Bear Collection / Cindl's Wristband Collection
-- items: 12621, 13761, 2136, 2130, 2135, 2132, 2128, 2171, 2131, 2134, 2127, 2126, 2129, 2125, 2133, 12223, 2010, 2147, 2140

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Welcome t' me humble shop, then! I offer fine items fashioned from the skins o' the beasts o' Everfrrost, I do. Leather is me specialty and I can always use the [extra hides], ye know.")
	elseif(e.message:findi("extra hides")) then
		e.self:Say("I'll offer any hunter some used tattered armor fer every polar bear skin I'm brought. I'm sure even ye can wrestle the skins from the backs o' the polar bear cubs, no?")
	elseif(e.message:findi("second job")) then
		e.self:Say("I've seen the warriors bringin' in items called 'wrath orc wristbands.' Apparently, they find them on the lifeless bodies o' the snow orc troopers. They're made from a skin I've yet to find. I'll gladly reward ye with either a rawhide tunic or leggings or even perhaps leather gloves, if ye like. All I'm askin' are two wrath orc wristbands.")
	elseif(e.message:findi("mammoth hide parchment")) then
		e.self:Say("Oh, for Jinkus? Ok, here you go.")
		e.other:SummonItem(12621)
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 13761})) then
		e.self:Say("This is much appreciated! Please accept this used armor in return and a gold piece as well, fer yer troubles. Ye've done well! I may have a [second job] fer ye, if ye like?")
		e.other:SummonItem(eq.ChooseRandom(2136, 2130, 2135, 2132, 2128, 2171, 2131, 2134, 2127, 2126, 2129, 2125, 2133))
		e.other:Ding()
		e.other:Faction(328, 5, 0) -- Merchants of Halas
		e.other:Faction(320, 5, 0) -- Wolves of the North
		e.other:Faction(327, 5, 0) -- Shamen of Justice
		e.other:AddEXP(150)
		e.other:GiveCash(0,0,1,0)
	elseif(item_lib.check_turn_in(e.trade, {item1 = 12223, item2 = 12223})) then
		e.self:Say("Fine work, Hunter!! As yer reward, please accept this item which I've fashion'd fer ye.")
		e.other:SummonItem(eq.ChooseRandom(2010, 2147, 2140))
		e.other:Ding()
		e.other:Faction(328, 10, 0) -- Merchants of Halas
		e.other:Faction(320, 7, 0) -- Wolves of the North
		e.other:Faction(327, 7, 0) -- Shamen of Justice
		e.other:AddEXP(150)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
