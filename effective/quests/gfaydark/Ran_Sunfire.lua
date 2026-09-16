-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Ran_Sunfire.pl
-- P99 audit: Pixie Dust (Kelethin Ranger)
-- items: 2104, 2106, 2108, 2111, 2112, 12109, 17957

local function do_random_patchwork(e)
	if eq.ChooseRandom(1, 2, 3, 4, 5) == 1 then
		e.other:SummonItem(eq.ChooseRandom(2104, 2106, 2108, 2111, 2112))
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail. " .. e.other:GetName() .. "! I trust you are not afraid of heights. Kelethin is a grand city. but it is also a safe haven from predators and evil beings. About the only thing to fear are the [pixie tricksters].")
	elseif e.message:findi("pixie tricksters") then
		e.self:Say("An irritating lot of fairy folk. They have been starting fires in our great forest. They may just burn our grand community down. We will have to [exterminate the pixies]. It is unfortunate. but it is for the good of the entire forest.")
	elseif e.message:findi("exterminate the pixies") then
		e.self:Say("Then I give you this pouch. Should you fill and combine it with Pixie Dust, I shall pay you greatly for your deeds. We may even find a use for the dust itself. Careful, small though they may be, many are quite strong. Search for the weak ones for now.")
		e.other:SummonItem(17957) -- Empty Pouch
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12109}) then
		e.self:Say("We thank you for your deed. Here, then, is a small reward. Nothing more than long forgotten equipment, but it may be useful to a young adventurer.")
		do_random_patchwork(e)
		e.other:GiveCash(6, 0, 0, 0)
		e.other:Faction(246, 10, 0)
		e.other:Faction(279, 2, 0)
		e.other:Faction(226, 2, 0)
		e.other:Faction(310, 2, 0)
		e.other:Faction(234, -5, 0)
		e.other:AddEXP(800)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
