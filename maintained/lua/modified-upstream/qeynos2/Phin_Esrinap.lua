-- Source: qeynos2/Phin_Esrinap.lua
-- Monk Headband quests: P99 requires Silent Fist faction for the headband turn-ins.
-- items: 18921, 13789, 10110, 13722, 10111, 13027, 13028, 10112, 18922, 13006

local function has_headband_faction(e)
	return e.other:GetFaction(e.self) <= 3 -- kindly or better
end

local function say_low_faction(e)
	e.self:Say("I have been watching you, and appreciate the help you've given to the brothers and sisters of the Silent Fist. But, I feel that such a vital matter should be left to one of our more trusted members.")
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hello, my name is Phin. Practice, practice, practice.. That's my motto. It is my responsibility to train our members, and help them to advance their skills and abilities. I also reward our members with colored [headbands] for completing certain tasks.");
	elseif(e.message:findi("headbands")) then
		e.self:Say("Yes, I give the [White, Yellow, and Orange Headbands] to our newer members, and Togahn gives out [Red, Purple, and Blue Headbands] to our elder members.");
	elseif(e.message:findi("Tomer Instogle")) then
		e.self:Say("Tomer? I think Seta needs someone to go find him... Go ask her.");
	elseif(e.message:findi("Konem Matse")) then
		e.self:Say("Konem was sent to retrieve [supplies] and has not returned.");
	elseif(e.message:findi("supplies")) then
		e.self:Say("Take this message to Konem and find out where my supplies are.");
		e.other:SummonItem(18921); -- Message to Konem
	elseif(e.message:findi("gnoll")) then
		e.self:Say("Those vile creatures are constantly attacking our city.. and often killing innocent citizens. It is our duty to help defend Qeynos from their vicious raids.");
	elseif(has_headband_faction(e)) then
		if(e.message:findi("white headband")) then
			e.self:Say("That is our training headband.. Beginning students can earn this by slaying four [gnoll] pups, and bringing their scalps back to me.");
		elseif(e.message:findi("yellow headband")) then
			e.self:Say("This is awarded to our students for helping clear out the evil that inhabits the old ruins of the Qeynos Hills. Just bring me back three putrid rib bones as proof of your good deeds and turn in your [training headband], and then I will give you the yellow headband.");
		elseif(e.message:findi("orange headband")) then
			e.self:Say("This is a difficult award to obtain. The city of Qeynos is, as you know, under constant attack by the gnolls of Blackburrow. The Silent Fist Clan rewards its members who venture deep into this gnoll stronghold and bring swift justice to these vile creatures. Please return two Blackburrow gnoll pelts - make sure they aren't ruined - and a Blackburrow gnoll skin as proof of your noble actions. Also, turn in your [yellow headband], and then I shall give you the orange one. Good luck.");
		end
	else
		say_low_faction(e)
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18922})) then
		e.self:Say("Oh this is not good. Too many innocent traders have been getting robbed lately by those vile bandits out in the Karanas. Something must be done soon. Anyway, thank you for delivering the message... you did very well, young " .. e.other:GetName() .. ". Here's a little something to quench your thirst from all that running around.");
		e.other:SummonItem(13006); -- Water Flask
		e.other:Ding();
		e.other:Faction(309,5,0); -- Silent Fist Clan
		e.other:Faction(262,1,0); -- Guards of Qeynos
		e.other:Faction(361,1,0); -- Ashen Order
		e.other:AddEXP(1500);
	elseif not has_headband_faction(e) then
		say_low_faction(e)
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13789,item2 = 13789, item3 = 13789,item4 = 13789})) then
		e.self:Say("Good job, " .. e.other:GetName() .. ", keep up the good work! Here is your white training headband. Wear it with honor, and make Lu'Sun proud.");
		e.other:SummonItem(10110); -- White Headband
		e.other:Ding();
		e.other:Faction(309,25,0); -- Silent Fist Clan
		e.other:Faction(262,3,0); -- Guards of Qeynos
		e.other:Faction(361,1,0); -- Ashen Order
		e.other:AddEXP(100);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13722,item2 = 13722, item3 = 13722,item4 = 10110})) then
		e.self:Say("Good work.. and, as promised, here is your reward. It is an honor to present this yellow headband to " .. e.other:GetName() .. ", for recent acts of courage and heroism, on behalf of the Silent Fist Clan.");
		e.other:SummonItem(10111); -- Yellow Headband
		e.other:Ding();
		e.other:Faction(309,50,0); -- Silent Fist Clan
		e.other:Faction(262,7,0); -- Guards of Qeynos
		e.other:Faction(361,2,0); -- Ashen Order
		e.other:AddEXP(200);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13027,item2 = 13027, item3 = 13028,item4 = 10111})) then
		e.self:Say("It is an honor to present the orange headband of the Silent Fist Clan to one of our finest members, " .. e.other:GetName() .. " the mighty!");
		e.other:SummonItem(10112); -- Orange Headband
		e.other:Ding();
		e.other:Faction(309,50,0); -- Silent Fist Clan
		e.other:Faction(262,7,0); -- Guards of Qeynos
		e.other:Faction(361,2,0); -- Ashen Order
		e.other:AddEXP(300);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

