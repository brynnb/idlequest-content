-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/Vilissia.pl
-- items: 2366, 2364, 10118, 19048

local function temple_faction(e)
	e.other:Faction(415, 15, 0)
	e.other:Faction(416, -15, 0)
	e.other:AddEXP(1000)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am Vilissia, chosen of Solusek Ro. I am a practitioner in the Wizardly arts, and keeper of lore for the [Runescale Cloak], [Tishans Kilt] and the [Acumen Mask].")
	elseif e.message:findi("runescale cloak") then
		e.self:Say("The Runescale cloak is a wonderful item of defense for any Wizard. Are you [interested in the cloak]?")
	elseif e.message:findi("interested in the cloak") then
		e.self:Say("I can assemble for you a Runescale Cloak - but you will need to bring me the necessary components. I will need a Lizardscale Cloak from the Feerrott and the three Runes of Scale. All three can be found on Crocodiles - Saltwater Crocodiles in the Caverns of Guk, Deepwater Crocodiles in the Oasis of Marr and Firescale Crocodiles in the mountains of Lavastorm. Bring me these items, and I will make for you a Runescale Cloak.")
	elseif e.message:findi("tishans kilt") then
		e.self:Say("Tishan was once counted among the mightiest of wiards - and his items are items of power. If you are interested in acquiring Tishans Kilt, you must take a Shadowed Ball from our mortal enemies the Shadowed Men and bring it to Trankia in the Everfrost Mountains.")
	elseif e.message:findi("acumen mask") or e.message:findi("interested in the mask") then
		e.self:Say("I can make for you an Acumen Mask, but you will need to bring me the proper components. I will need a Glowing Mask from a Skeletal Monk in the Caverns of Guk, A Patch of Shadow from our mortal enemies the Shadowed Men, a Darkbone Skull from a Darkbone Skeleton in the Estate of Unrest and a Bonechipped Mask from a Goblin Headmaster in the Ocean of Tears. Bring me these four items, and I will make for you an Acumen Mask.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 2352, item2 = 2368, item3 = 10558, item4 = 2367}) then
		e.self:Say("Well done " .. e.other:GetName() .. ". You truly are a powerful wizard. I have crafted your mask. Take it.")
		e.other:SummonItem(2366)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 2332, item2 = 10553, item3 = 10554, item4 = 10555}) then
		e.self:Say("Well done " .. e.other:GetName() .. ". You truly are a powerful wizard. I have crafted your cloak. Take it.")
		e.other:SummonItem(2364)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10035, item2 = 10035, item3 = 10000}) then
		e.self:Say("Okay, here is your Lambent Ruby.")
		e.other:SummonItem(10118)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 16507}) then
		e.self:Say("I see that Gavel has sent you to me. Very well, I have vulcanized your platinum bar - take it.")
		e.other:SummonItem(19048)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
