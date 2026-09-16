-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/Teydar.pl
-- items: 14372, 14371, 16507, 14366

function event_say(e)
	local faction = e.other:GetCharacterFactionLevel(404)
	-- Perl's $class name differs from IdleQuest's display spelling. Use the
	-- actual class ID so the greeting keeps its Shadow Knight restriction.
	if e.message:findi("hail") and e.other:GetClass() == 5 then
		e.self:Say("Hello " .. e.other:GetName() .. ", it's good to see another shadowknight around here. I'm Teydar. I've made it my life to fashion suitable scabbards and sheaths for our order.")
	elseif e.message:findi("decrepit sheath") and faction >= 28 then
		e.self:Say("The object you desire is very difficult to fashion. Nearly impossible, really. All I can offer to do is try. The real difficulty is the contents that give the sheath its power. They have to be of an almost equal evil. I think some kind of decrepit hide and a drake spine, along with a bar of enchanted platinum, should prove enough to make this item.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:GetCharacterFactionLevel(404) >= 28 and item_lib.check_turn_in(e.trade, {item1 = 14372, item2 = 14371, item3 = 16507}) then
		e.self:Say("I did it! The pieces you got me were perfect! It took a huge effort on my part to craft this, of course. It saddens me that I'm unable to keep one of my best works, but a deal is a deal. There is honor among shadowknights.")
		e.other:Faction(404, 7, 0)
		e.other:SummonItem(14366)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
