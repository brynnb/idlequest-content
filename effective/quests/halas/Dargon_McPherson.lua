-- Modified from ProjectEQ Lua during P99 quest audit.
-- P99: https://wiki.project1999.com/Magic_Elixir_for_the_Warriors
-- items: 13241, 13245, 10004, 10016, 10017, 1038, 2012, 2135, 5014

local function faction_allows_quest(e)
	return e.other:GetFaction(e.self) <= 6 -- apprehensive or better
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail, mighty " .. e.other:GetName() .. "! I assume ye must be a [warrior o' the Wolves]. Why else would ye approach a trainer such as meself, then?")
	elseif(e.message:findi("the wolves")) then
		if faction_allows_quest(e) then
			e.self:Say("Aye, 'tis as I thought. I'm glad t' see we've warriors such as yerself amongst the Wolves o' the North. Lately, Kylan's been allowing too many scrawny warriors in, methinks. Nor have they fared well in Everfrrost. Many frreeze to death, ye know... Will ye assist me and [deliver an elixir to young warriors] in Everfrost?")
		else
			e.self:Say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!")
		end
	elseif(e.message:findi("young warrior")) then
		if faction_allows_quest(e) then
			e.self:Say("Ach, 'tis good o' ye! Take this bottle of elixir to Everfrost Peaks. Find Talin O'Donal. He'll take the first sip, and then instruct ye on who else ye need to find. Do that, and I'll give ye a fine reward when ye return the empty elixir bottle. Good luck, then. Don't die.")
			e.other:SummonItem(13241) -- Full Bottle of Elixir
		else
			e.self:Say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if(item_lib.check_turn_in(e.trade, {item1 = 13245})) then -- Empty Bottle of Elixir
		if faction_allows_quest(e) then
			e.self:Say("Ye've proven yerself to be a cut above the rest and aided yer fellow warriors, no matter how worthless they were. Ye may take this. It was found in the snow by one of our foraging parties. I hope it can be of use to a warrior like yerself.")
			e.other:Ding()
			e.other:AddEXP(125)
			e.other:GiveCash(math.random(1, 3), 0, 0, 0)
			e.other:SummonItem(eq.ChooseRandom(
				10004, -- Copper Band
				10016, -- Lapis Lazuli
				1038, -- Tattered Cloth Sandal
				10017, -- Turquoise
				2135, -- Large Patchwork Pants
				2012, -- Leather Boots
				5014 -- Rusty Axe
			))
			e.other:Faction(328, 10) -- Merchants of Halas
			e.other:Faction(327, 10) -- Shaman of Justice
			e.other:Faction(311, 10) -- Steel Warriors
			e.other:Faction(320, 10) -- Wolves of the North
		else
			e.self:Say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!")
			e.other:SummonItem(13245)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
