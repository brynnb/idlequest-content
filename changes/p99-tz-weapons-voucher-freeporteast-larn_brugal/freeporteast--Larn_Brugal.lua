-- Source: freeporteast/Larn_Brugal.lua
-- P99 audit: Weapons Delivery
-- items: 18820, 12241, 12242, 12243, 12244, 13919

function event_say(e)
	local fac = e.other:GetFaction(e.self)

	if(e.message:findi("hail")) then
		e.self:Say("Good day to you, " .. e.other:GetName() .. "! I hope you yearn to become a Steel Warrior as we all are, here in the Bunker. We are in need of more recruits to continue the [war].")
	elseif(e.message:findi("war")) then
		e.self:Say("The war I speak of is the one we Steel Warriors have sworn to wage against [Clan Deathfist] in the Commonlands. We are doing a fine job, but we require more weapons. We are expecting a shipment of blades from Groflah's Forge. We require an ally of the bunker to [get our shipment]. Maybe you.")
	elseif(e.message:findi("clan deathfist")) then
		e.self:Say("If you do not know of Clan Deathfist, go ask Cain who they are. He will not only tell you, he will sign you up to help fight our war!")
	elseif(e.message:findi("shipment")) then
		if fac < 5 then
			e.self:Say("We would be most thankful for your service. Please take this voucher over to Groflah at Groflah's Forge. He will give you the shipment of weapons.")
			e.other:SummonItem(18820) -- Sealed Letter
		else
			e.self:Say("The Steel Warriors do not trust you with our shipment.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	local fac = e.other:GetFaction(e.self)

	if item_lib.check_turn_in(e.trade, {item1 = 12241, item2 = 12242, item3 = 12243, item4 = 12244}) then
		if fac < 5 then
			e.self:Say("Good work, " .. e.other:GetName() .. ". The bunker shall be well stocked. Here you are, my friend. Take this raw blade. You can take it to Groflah - he will sharpen and polish it for you. It should be a formidable weapon.")
			e.other:SummonItem(13919) -- Reward Raw Short Sword
			e.other:GiveCash(0, 0, 4, 0)
			e.other:Faction(311, 10, 0) -- Steel Warriors
			e.other:Faction(262, 10, 0) -- Guards of Qeynos
			e.other:Faction(230, -10, 0) -- Corrupt Qeynos Guards
			e.other:Faction(330, -10, 0) -- The Freeport Militia
			e.other:Faction(281, 10, 0) -- Knights of Truth
			e.other:AddEXP(500)
			e.other:Ding()
		else
			e.self:Say("The Steel Warriors do not trust you with our shipment.")
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
