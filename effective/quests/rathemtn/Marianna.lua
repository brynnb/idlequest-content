-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Marianna.pl
-- items: 12310, 12300

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Rodcet Nife welcomes you into our noble camp. I am the keeper of the [Vambraces of Ro].")
	elseif e.other:GetModCharacterFactionLevel(341) < 25 then
		e.self:Say("In the name of Rodcet Nife, I must ask you to venture to Qeynos and find the Temple of Life. There you shall serve until High Priestess Jhanda responds when you ask her, am [I an honored member]?")
	elseif e.message:findi("vambraces of ro") then
		e.self:Say("The mold will be offered to you when you have performed a task for the Temple of Life. The oceans near our home are host to a plague.. the plague sharks!! They have been infected with a deadly malady which has been turning up in the Qeynos Hills. Kill the sharks and bring me two of their rotten shark portions as proof.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:GetModCharacterFactionLevel(341) > 24 and item_lib.check_turn_in(e.trade, {item1 = 12310, item2 = 12310}) then
		e.self:Say("You now own a mold for the Vambracers of Ro. Go and ask Thomas of [Lord Searfire] for the final component.")
		e.other:SummonItem(12300)
		e.other:Faction(341, 20, 0)
		e.other:Faction(280, 6, 0)
		e.other:Faction(262, 10, 0)
		e.other:Faction(221, -5, 0)
		e.other:Faction(219, 3, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
