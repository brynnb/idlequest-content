-- Converted from ProjectEQ Perl quest script.
-- Source: misty/Joogl_Honeybugger.pl
-- items: 13009

local function reward_bandage(e)
	e.self:Say("Oh thank you, " .. e.other:GetName() .. ".  If you are ever going to gather bixie honeycombs pray you do not run into the queen.  The only way I know of collecting the honey is by intercepting the drones and taking the honeycombs they sometimes carry.  Good luck !!")
	e.other:Faction(241, 1, 0)
	e.other:Faction(263, 1, 0)
	e.other:Faction(286, 1, 0)
	e.other:Faction(292, 1, 0)
	e.other:Faction(336, -1, 0) -- Coalition of Tradefolk Underground (P99).
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello. I would shake your hand, but it would [hurt]. Ooooh! Owwy!")
	elseif e.message:findi("hurt") then
		e.self:Say("I was attacked by the bixies. They swarmed on me!! I think I got too near their queen. I need that honey to make a living! Get me a bandage and I will tell you where all their worker bee's buzz around.")
	elseif e.message:findi("I need the honeycomb") then
		e.self:Say("If you're looking for the honeycombs, I don't have any right now. I have been unable to get any since I was attacked by the little [buggers]. I will tell you where to get some if you will only get me a bandage for my bites.")
	elseif e.message:findi("buggers") then
		e.self:Say("I was attacked by the bixies. They swarmed on me!! I think I got too near their queen. I need that honey to make a living! Get me a bandage and I will tell you where all their worker bees buzz around.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13009, item2 = 13009, item3 = 13009, item4 = 13009}) then
		for _ = 1, 4 do
			reward_bandage(e)
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 13009, item2 = 13009, item3 = 13009}) then
		for _ = 1, 3 do
			reward_bandage(e)
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 13009, item2 = 13009}) then
		for _ = 1, 2 do
			reward_bandage(e)
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 13009}) then
		reward_bandage(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
