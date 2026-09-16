-- Converted from ProjectEQ Perl quest script.
-- Source: fieldofbone/Warlord_Zyzz.pl
-- items: 12650, 18213, 17996, 12668, 12657

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("There is little time for talk. There are plenty of [tiny invaders]. Do your part and exterminate as many as you can. All of Cabilis shall look favorably upon you in the long run.")
	elseif e.message:findi("tiny invaders") then
		e.self:Say("The small scorpions have been turning up everywhere!! One can hardly sleep when thinking of the little monsters. Please crush as many as you can for the greater good. I will even pay a bounty for every four Scorpion Pincers you return.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12650, item2 = 12650, item3 = 12650, item4 = 12650}) then
		e.self:Say("Magnificent!! The more pincers I get the fewer scorpions there are. Here. Take the bounty.")
		e.other:Faction(441, 3, 0)
		e.other:Faction(440, 1, 0)
		e.other:Faction(445, 1, 0)
		e.other:Faction(442, 1, 0)
		e.other:Faction(444, 1, 0)
		e.other:GiveCash(0, 2, 0, 0)
		e.other:AddEXP(2500)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18213}) then
		e.self:Say("Ah!! Good to have you on board. We lack strong young recruits such as yourself. Take this box. Your task is to seek milita skeletons near this gate. Apparently, someone or something has been raising militia corpses and they now walk the land not knowing the difference between friend or foe. They even continue using their old call, 'Halt Who goes there?'. Fill and combine within the box their charred bone shards and return the filled box to me for your geozite tool.")
		e.other:SummonItem(17996)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12668}) then
		e.self:Say("Great work!! You have helped keep the gate safe. I reward you with the geozite tool. You may find its purpose within Cabils' warriors guild. A true Iksar warrior should always have one.")
		e.other:SummonItem(12657)
		e.other:Faction(441, 2, 0)
		e.other:Faction(440, 2, 0)
		e.other:Faction(445, 2, 0)
		e.other:Faction(442, 2, 0)
		e.other:Faction(444, 2, 0)
		e.other:GiveCash(0, 0, 1, 0)
		e.other:AddEXP(200)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
