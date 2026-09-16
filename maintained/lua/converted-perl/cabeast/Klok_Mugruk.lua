-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Klok_Mugruk.pl
-- P99 audit: Sparring Armor
-- items: 17992, 12655, 12685, 12687

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to my shop, sss. Only the finessst I have. I make for you jussst as I make for the emperor's harem. Many [bristle silk] garmentsss do they need. Ssss.. Lucky man, the emperor isss.")
	elseif e.message:findi("bristle silk") then
		e.self:Say("What is bristle silk?!! Huh? Where have you been living? Under the rocksss.. Nahh. I sssee. You are a broodling from the common ssstock. You could never afford bristle silk nor the affectionss of those who drape themselves with it. Still, commons have much ssservice to offer. Maybe you would like to earn some [curscale armor]. Hmm?")
	elseif e.message:findi("curscale armor") then
		e.self:Say("Curscale armor? I make thisss crude armor from the broodlings of the scaled wolves. I use the ssskins of the pupsss and cubs. Those ssskins are ssstill young and thin and are bessst for the young adventurers. I sssupply them to the Legion of Cabilisss, but for a [small service] I shall make them available to you.")
	elseif e.message:findi("^small service$") then
		e.self:Say("I am in need of pup and cub scaled wolf skins to create more [curscale armor]. Many Legionnaires have died in battle. The Baron demands more sssuits. I mussst have more ssskins or it is MY HIDE!! I shall reward pieces of the curscale armor to any who [perform a small service].")
	elseif e.message:findi("perform a small service") then
		e.self:Say("Good. You take thisss pack and fill it all with scaled curskins. Only the pupsss and cubs of the scaled wolves shall do. They are not much for one sssuch as you. Combine all those ssskins and return the full curskin pack and I shall reward you with any available piece of curskin armor and a sssmall amount of coin. Mossst important is that you shall be proving your allegiance to all of Cabilisss.")
		e.other:SummonItem(17992) -- Empty Curskin Bag
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12655}) then
		e.self:Say("You are a good servant and a fine citizen. I have this piece of curscale armor available, but if it is not enough then perhaps I shall have another piece available if you were to [perform the small service] again.")
		e.other:SummonItem(eq.ChooseRandom(4270, 4271, 4272, 4273, 4274, 4275, 4276, 4277, 4279, 4280, 4281))
		e.other:GiveCash(4, 3, 1, 0)
		e.other:Faction(440, 10, 0) -- Cabilis Residents
		e.other:Faction(441, 10, 0) -- Legion of Cabilis
		e.other:AddEXP(10000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12685}) then
		e.self:Say("Now you need to get three Piles of Granite Pebbles and then you can tailor a Monk Training Bag for your caste.")
		e.other:SummonItem(12687) -- Training Bag Husk
		e.other:Faction(440, 5, 0) -- Cabilis Residents
		e.other:Faction(441, 5, 0) -- Legion of Cabilis
		e.other:AddEXP(500)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
