-- Converted from ProjectEQ Perl quest script.
-- Source: kithicor/Kithicor.pl
-- items: 9464, 20877, 20878

local function has_blue_orb_access(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["Fatestealer_shak"] == "1" or qglobals["Fatestealer_shak"] == 1 or e.other:HasItem(52355) or e.other:HasItem(52356)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello Traveler, I do not see many this deep into the woods.")
	elseif e.message:findi("blue orb") and has_blue_orb_access(e) then
		e.self:Emote("fishes a hemisphere of cerulean colored metal from his pocket. You must be referring to this? I recovered it from a charred spot of earth shortly after that fateful battle between the armies led by the Child of Hate and Tunare's Chosen. This abhorrent thing radiates evil and is an affront to nature. I must be rid of it, now. Take it! Please find a way to properly dispose of the hemisphere, " .. e.other:GetName() .. ". While you do not necessarily strike me as the trustworthy type, you do appear capable. I can only pray you make the correct choice.")
		e.other:SummonItem(9464)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20877}) then
		e.self:Say("Wow, this is certainly something I have not seen in a long time. It was said that this species of snake had been wiped out due to the poachers and griffins. It was very noble of you to help in saving this species. I will see that these are raised properly. Please wear this icon with pride so other rangers will know of the good deed you have done.")
		e.other:Faction(269, 50, 0)
		e.other:Faction(302, 50, 0)
		e.other:Faction(272, 50, 0)
		e.other:Faction(324, 50, 0)
		e.other:AddEXP(1000)
		e.other:Ding()
		e.other:SummonItem(20878)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
