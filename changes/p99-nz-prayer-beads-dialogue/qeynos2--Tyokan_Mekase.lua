-- Modified from ProjectEQ Lua.
-- Source: qeynos2/Tyokan_Mekase.lua
-- P99 audit: Recharge Prayer Beads
-- items: 13306, 15126, 15248, 13296

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Please look around. We have many items exclusively for the members of the Temple of Life. We also have [scroll strongboxes]. If you are unsure of what an item is, feel free to ask me.")
	elseif(e.message:findi("scroll strongbox")) then
		e.self:Say("The scroll strongboxes are merely personal safes. Most of the members use them. I am afraid all are taken, but if you are here to remove a scroll, merely hand me your key and I shall get it for you. I handle all 20 numbered keys and [Whysia] handles all 30 and 40 numbered keys.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 13296, gold = 100}) then
		if e.other:GetFaction(e.self) > 4 then
			e.self:Say("The Temple of Life does not yet trust you with such a service.")
			e.other:SummonItem(13296)
			e.other:GiveCash(0, 0, 100, 0)
		else
			e.self:Say("I see your beads need to be charged. Very well, here you are. Use them and good health to you!!!")
			e.other:SummonItem(13296) -- Prayer Beads
		end
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13306})) then
		e.self:Say("Oh, turning in your key, are you? Very well, defender of life. Here you are.")
		e.other:SummonItem(eq.ChooseRandom(15126,15126,15248)) -- Spell: Inspire Fear / Ward Summoned
		e.other:Ding()
	else
		-- Inspect, but do not consume or replace partially offered beads.
		-- Returning the original offer preserves its charges until payment is complete.
		for key, item in pairs(e.trade) do
			if type(key) == "string" and key:match("^item%d+$") and item:GetID() == 13296 then
				e.self:Say("As instructed by High Priestess Jahnda I must ask for the beads and a donation of 100 gold coins.")
				break
			end
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
