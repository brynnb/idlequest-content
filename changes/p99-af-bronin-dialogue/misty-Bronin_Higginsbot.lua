-- Converted from ProjectEQ Perl quest script.
-- Source: misty/Bronin_Higginsbot.pl
-- items: 13110, 12192, 12193

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello. It is dangerous out in the woods. You should go to Rivervale. It's at the end of the path. You will find good times there. Travel safely, my friend!")
	elseif e.message:findi("shard") then
		e.self:Say("Searching for that blasted emerald shard, are you? That thing has done nothing but bring me bad luck!! I would gladly give it to you if you would do a [small favor] for me.")
	elseif e.message:findi("small favor") then
		e.self:Say("I have been tracked here by a bounty hunter named Slaythe. I have heard reports of his presence beyond the Great Wall. Please seek him out and bring me some body part of his as proof of his passing. Do this and the emerald shard is yours.")
		eq.spawn2(33146, 0, 0, 893.00, 664.00, -34.73, 0)
	elseif e.message:findi("second piece of the gem") then
		e.self:Say("The second emerald shard was hidden in the forest near Kelethin. I heard one of the local guilds found it and now call it the Gem of Tunare. You will have to ask around in Kelethin about it. Good luck.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13110}) then
		e.self:Say("AHH!! You have been sent by the Highkeep Guards!! You will never take Bronin Higginsbot alive!!")
		e.other:Faction(241, -25, 0)
		e.other:Faction(223, -25, 0)
		e.other:Faction(292, 25, 0)
		e.other:Faction(336, -25, 0)
		e.other:Faction(329, -25, 0)
		eq.attack(e.other:GetName())
	elseif item_lib.check_turn_in(e.trade, {item1 = 12192}) then
		e.self:Say("So I see you have defeated Slaythe. I shall sleep much better now that he is gone. I placed the emerald shard in one of the Highkeep strongboxes in Highpass. Give the Bank Clerk this key. There is a [second piece of the gem] which I hid near Kelethin. You will need it to complete the gem. I hope it brings you better luck than I.")
		e.other:Faction(241, 10, 0)
		e.other:Faction(223, 10, 0)
		e.other:Faction(292, -10, 0)
		e.other:Faction(336, 10, 0)
		e.other:Faction(329, 10, 0)
		e.other:AddEXP(500)
		e.other:SummonItem(12193)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
