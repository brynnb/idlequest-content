-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Drill_Master_Kyg.pl
-- items: 17027, 18234, 12430, 5131, 12475

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome, welcome!! Time to train. Time to fight. Time to serve the Iksar Empire. You will need weapons. I have the [footman pike] for all new recruits to earn.")
	elseif e.message:findi("footman pike") then
		e.self:Say("A footman pike is what you need. A footman pike is what you get, but earn it you will. You must [slay many beasts] to prove to us that you are a true warrior. Fail and you will be exiled to live with the Forsaken.")
	elseif e.message:findi("slay many beasts") then
		e.self:Say("Yes. You will slay or you will be slain. Take this footman's pack and fill it you will. Fill it with [weapons of our foes]. When all are combined, the full footman's pack shall be returned to me along with your militia pike. Do this and earn your footman pike and then we may have a true mission for you.")
		e.other:SummonItem(17027) -- Footmans Pack
	elseif e.message:findi("weapons of our foes") then
		e.self:Say("Yes. You need to know the weapons required. Fill the pack with javelins. Froglok bounder and goblin hunter javelins. Two of each.")
	elseif e.message:findi("footman moglok") then
		e.self:Say("My dear friend, Warlord Hikyg of the Swamp Gate has encountered some difficulty with a Trooper Moglok. He requested that I find a brave soldier to take charge of the situation. Are you willing to [assist Warlord Hikyg]?")
	elseif e.message:findi("assist warlord hikyg") then
		e.self:Say("Good. Take this note to Footman Moglok of the swamp garrison. He shall instruct you on your mission.")
		e.other:SummonItem(18234) -- Sealed Note
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12430, item2 = 5131}) then
		e.self:Say("Kyg knew you could do it. You will make a fine legionnaire some day but, for now, you shall be a footman. Take the footman pike head plans. Forge the footman's pike. Do so, and then you may have an audience with the War Baron on the subject of his [Memory of Sebilis].")
		e.other:SummonItem(12475) -- Footman Head Plans
		e.other:AddEXP(500)
		e.other:Faction(440, 2, 0) -- Cabilis Residents
		e.other:Faction(441, 2, 0) -- Legion of Cabilis
		e.other:Faction(445, 2, 0) -- Scaled Mystics
		e.other:Faction(444, 2, 0) -- Swift Tails
		e.other:Faction(442, 2, 0) -- Crusaders of Greenmist
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
