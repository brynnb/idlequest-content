-- Source: sro/Dahdd_Jonne.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 55272, 55265, 55266, 55267, 40900, 40901

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 55272}) then
		e.self:Say("Ahoy there! Dahdd Jonne, tailor extraordinaire at your service! What's this? A note from, Jilsua? Always a pleasure!")
		e.self:Emote("stuffs a whole bixie berry bun into his mouth. 'Mrpmpphh. Says you are on a quest to upgrade your Satchel of Abu-Kar. Very interesting!'")
		e.self:Emote("wipes his hands on his clothes. 'Let's see here. I think I can do this. Hand me your Rujarkian Orc Hide, Stone Frog Skin, and your Bloodguard Crypt Mummy Wrappings, oh and of course your Satchel of Abu-Kar. Don't worry, I won't ruin it. At least I don't think I will.'")
	elseif item_lib.check_turn_in(e.trade, {item1 = 55265, item2 = 55266, item3 = 55267, item4 = 40900}) then
		e.self:Emote("takes the items and puts them into his tailoring kit. He begins to furiously sew them together. 'Ah bugger. Seems this one is a failure. Ha! Got ya! Just kidding there, friend. Here you go! One Reinforced Satchel of Abu-Kar! Kizpi's directions were pretty good, even if he did forget to include a few items! My best work yet If I don't say so myself!'")
		e.other:SummonItem(40901) -- Reinforced Satchel of Abu-Kar
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
