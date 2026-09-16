-- Modified from ProjectEQ Lua during P99 quest audit.
-- P99: https://wiki.project1999.com/Mammoth_Calf_Hides
-- items: 5243, 5238, 5239, 5242, 5236, 5233, 5231, 5240, 5241, 5234, 5232, 5235, 5237

local function faction_allows_quest(e)
	return e.other:GetFaction(e.self) < 5 -- amiable or better
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail there " .. e.other:GetName() .. " ! If you are not a [member of the White Rose], then it be best that you stay on the lower level. This here floor is for honest ...ermm respectable rogues only.")
	elseif(e.message:findi("member of the white rose")) then
		if faction_allows_quest(e) then
			e.self:Say("I hope that you are indeed respectable, and loyal to Halas and the Rogues of the White Rose. To do otherwise would bring the wrath of the Six Hammers down on you. But enough with talk! Our caravan to the frigid north leaves in less than two days, and we are short on mammoth calf hides. Return four of them and you will be given items that show your loyalty to our Clan.")
			eq.signal(29070, 1) -- Ysanna MacGibbon
		else
			e.self:Say("The Order of the White Rose does not trust you with such a task.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if(item_lib.check_turn_in(e.trade, {item1 = 5243, item2 = 5243, item3 = 5243, item4 = 5243})) then -- Mammoth Calf Hide x4
		if faction_allows_quest(e) then
			e.self:Say("You returned? We believed the gnoll pups got you. The caravan has already left, and these do me little good now. But, as I said before, one must remain respectable. Here is what I promised.")
			e.other:SummonItem(eq.ChooseRandom(
				5238, -- Black Wolf Armplates
				5239, -- Black Wolf Bracers
				5242, -- Black Wolf Boots
				5236, -- Black Wolf Cape
				5233, -- Black Wolf Collar
				5231, -- Black Wolf Crown
				5240, -- Black Wolf Gloves
				5241, -- Black Wolf Legplates
				5234, -- Black Wolf Mail
				5232, -- Black Wolf Mask
				5235, -- Black Wolf Pauldrons
				5237 -- Black Wolf Waistband
			))
			e.other:Faction(305, 10, 0) -- Rogues of the White Rose
			e.other:AddEXP(2500)
			e.other:Ding()
		else
			e.self:Say("The Order of the White Rose does not trust you with such a task.")
			e.other:SummonItem(5243)
			e.other:SummonItem(5243)
			e.other:SummonItem(5243)
			e.other:SummonItem(5243)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
