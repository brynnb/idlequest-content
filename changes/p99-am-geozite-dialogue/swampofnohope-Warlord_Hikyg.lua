-- Converted from ProjectEQ Perl quest script.
-- Source: swampofnohope/Warlord_Hikyg.pl
-- items: 17043, 18211, 17994, 12661, 12657, 12435, 12436, 12437, 5133, 12477, 12913, 18073

local function legion_faction(e)
	e.other:Faction(440, 2, 0)
	e.other:Faction(441, 2, 0)
	e.other:Faction(445, 2, 0)
	e.other:Faction(444, 2, 0)
	e.other:Faction(442, 2, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What business do you have speaking to an Iksar Warlord? Be gone before you find yourself served as my evening meal. Go to Captain Nedar if you wish to assist my garrison. Fool.")
	elseif e.message:findi("prepared to hunt escaped froglok slaves") then
		e.self:Say("Of course you are. They can be found running in packs along the edges of the city gates. Find the escaped frogloks and slay them. Take their slave shackles and throw them in the bag I have given you. When it is filled and combined, return it to me. My concern is only for those who have escaped into the swamp. This is my land and I have been ordered to keep its denizens under control.")
	elseif e.message:findi("trooper reporting for duty") then
		e.self:Say("It is about time they sent new troopers for my garrison!! This is the toughest garrison in Kunark!! And you're going to help prove it. The legion needs to get a hold of some new frog shields called Krup warrior guards. You're going to take this pack and fill it with not one, but four!! When you can return a full, combined pack to me, maybe you will show me that you're not as weak as you look!!")
		e.other:SummonItem(17043)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18211}) then
		e.self:Say("It is about time they sent some lackey to perform tasks too paltry for my troopers to deal with. We need to punish those who dare to run from their servitude. You will need this bag. Are you [prepared to hunt escaped froglok slaves] and serve your lord?")
		e.other:SummonItem(17994)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12661}) then
		e.self:Say("Good work, " .. e.other:GetName() .. ". You would make a fine trooper in my garrison. As instructed by the War Baron, I reward you with the geozite tool. May you find your place among the Legion of Cabilis and win many battles.")
		e.other:SummonItem(12657)
		e.other:GiveCash(0, 0, 1, 0)
		e.other:AddEXP(200)
		e.other:Ding()
		legion_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12435, item2 = 12436, item3 = 12437, item4 = 5133}) then
		e.self:Emote("hands you plans for a trooper's pike head.")
		e.self:Say("Congratulations. You are now a trooper of the Legion of Cabilis. Now you may fight with honor and a mighty weapon.")
		e.other:SummonItem(12477)
		legion_faction(e)
		e.other:AddEXP(1200)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12913}) then
		e.self:Say("What?!! You crushed all the shields!! You croak-faced skulking brute!! You don't deserve to be in my garrison!! I am going to recommend you for a promotion in hopes that you will be sent to hunt dragons and meet your end!")
		e.other:SummonItem(18073)
		e.other:AddEXP(2000)
		e.other:Ding()
		legion_faction(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
