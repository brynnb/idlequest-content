-- Converted from ProjectEQ Perl quest script.
-- Source: chardok/Queen_Velazul_Di-zok.pl
-- P99 audit: Spirit Wracked Cord Quest
-- items: 6477, 6478, 5727, 5723

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, minion! It is good to see a member of a lesser race striving to improve themself through service to the Dizok. We are feeling especially generous as of late, and if you would do us a [service], we shall reward you handsomely.")
	elseif e.message:findi("service") then
		if e.other:GetFaction(e.self) > 1 then
			e.self:Say("We are not sure you are worthy.")
		else
			e.self:Say("We are not sure you are worthy, but shall assign you this task in hopes you prove mighty enough to resolve it. Gather your broodlings about you, and journey to Charasis. There you shall find a Urn of spirits. We require this, as well as [additional components].")
		end
	elseif e.message:findi("additional components") then
		if e.other:GetFaction(e.self) > 1 then
			e.self:Say("We are not sure you are worthy.")
		else
			e.self:Say("Very well, if you feel you are up to it, lead your broodlings to fallen Sebilis and return to us with a portion of undead dragon sinew. Bring us the Sinew, the Urn, and your Regal Band of Bathezid as proof of service, and a worthy reward shall be yours.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 6477, item2 = 6478, item3 = 5727}) then
		if e.other:GetFaction(e.self) > 1 then
			e.self:Say("We are not sure you are worthy.")
			e.other:SummonItem(6477)
			e.other:SummonItem(6478)
			e.other:SummonItem(5727)
		else
			e.self:Say("Amazing! You have returned the trophies I asked for, against impossible odds. Here is your reward, worthy minion, may it serve you well.")
			e.other:SummonItem(5727)
			e.other:SummonItem(5723)
			e.other:AddEXP(100000)
			e.other:Faction(451, 3, 0)
			e.other:Faction(307, 3, 0)
			e.other:Faction(259, -1, 0)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
