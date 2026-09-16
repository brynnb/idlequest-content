-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Draxiz_N-Ryt.pl
-- items: 12807, 2284, 18957

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12807}) then
		e.self:Say("I have foreseen your arrival, " .. e.other:GetName() .. ". I see from the mind of this lesser creature you have slain that he was receiving orders from beyond the boundaries of Nektulos. I see an armored Leatherfoot moving cautiously through the commonlands attempting to avoid the eyes of travelers and guard posts. Find this Leatherfoot I see in my visions and return any pertinent information he may be carrying to me so that I may decipher it. I have skinned the face of this druid and enchanted it so that you may learn what you must through your skills of subterfuge. Go now, " .. e.other:GetName() .. ", and do not disappoint me!")
		e.other:SummonItem(2284)
		e.other:Faction(239, -30, 0)
		e.other:Faction(363, 10, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18957}) then
		e.self:Say("I see you are more cunning than you appear, " .. e.other:GetName() .. ". These orders to Whoopal bring disturbing news indeed. It seems there is a Leatherfoot spy somewhere in Neriak who has been providing the raiders with information. Find this spy and return his head and your initiate holy symbol of Innoruuk to Ithvol and if he deems you worthy he will promote you within the ranks of the Spires.")
		eq.unique_spawn(41104, 0, 0, -560, -180, -55, 0)
		e.other:Faction(239, -30, 0)
		e.other:Faction(363, 10, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
