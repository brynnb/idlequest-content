-- Converted from ProjectEQ Perl quest script and aligned with P99.
-- Source: cabeast/Drill_Master_Vygan.pl
-- P99 audits: Geozite Tool Quest, Guild Summons - Legion of Cabilis
-- items: 17993, 18203, 5130, 12658, 18213, 18211, 18210

local function legion_faction(e, amount)
	e.other:Faction(440, amount, 0) -- Cabilis Residents
	e.other:Faction(441, amount, 0) -- Legion of Cabilis
	e.other:Faction(445, amount, 0) -- Scaled Mystics
	e.other:Faction(444, amount, 0) -- Swift Tails
	e.other:Faction(442, amount, 0) -- Crusaders of Greenmist
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am a Drill Master of the Legion of Cabilis. I have no time for idle chitchat. Be off if you were not summoned to this fortress! Find that guild which was chosen for you as an egg.")
	elseif e.message:findi("militia pike") then
		e.self:Say("The pike is the prime weapon of Cabilis warriors. It can be upgraded, too, such as from the partisan pike to the militia pike and beyond. All these pikes may be slung on one's back when your hands are needed for other pursuits. To upgrade a pike is something that is learned, but it can never be performed without a [geozite tool]. Do you [desire to upgrade the partisan pike]?")
	elseif e.message:findi("desire to upgrade the partisan pike") then
		e.self:Say("It seems as though a traitor is among our people. Someone has smuggled shackle keys to the slaves. The froglok slaves have been escaping into the swamplands and there we can hear the whistle of their contact who escorts them to freedom. We must put a stop to this! I desire three things. Your partisan pike, the head of the Iksar traitor and the whistle of the escort. Bring these to me and I shall give you the militia pike.")
	elseif e.message:findi("geozite tool") then
		e.self:Say("The Geozite Tool is used to sharpen the pikes of the Legion of Cabilis. Only it can produce the serrated edges necessary for these deadly weapons. They are not handed out to just any broodling. The tool is only given to warriors who serve the legion. Do you [want a geozite tool]?")
	elseif e.message:findi("want a geozite tool") then
		e.self:Say("Then take this satchel and go to the outer walls of Cabilis and seek out large scorpions. When you can fill and combine the satchel with scorpion pincers, then you shall prove to me that you are truly a warrior and I shall send you off on your true test.")
		e.other:SummonItem(17993) -- Item: Pincer Satchel
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18203}) then
		e.self:Say("I see they have begun to draft younger broodlings? Hmmph!! No matter. We Drill Masters shall make a warrior of you. Here is your partisan's pike and some coin as your wages. Be sure that you begin your training in blacksmithing and report to the other Drill Masters for any tasks they may have for you. Let them know you are [a partisan of Cabilis]. Perhaps soon you shall be rewarded the [militia pike].")
		e.other:SummonItem(5130) -- Item: Partisan's Pike
		e.other:AddEXP(100)
		e.other:Faction(441, 100, 0)
		e.other:Faction(440, 25, 0)
		e.other:Faction(445, 25, 0)
		e.other:Faction(442, 25, 0)
		e.other:Faction(444, 25, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12658}) then -- Full Pincer Satchel
		e.self:Say("You are a true warrior of Cabilis. You obviously are aware that in order to upgrade your pike you shall need a [geozite tool]. Take this note to the Lord of the outer gates. He desires a young warrior for a small task. Do this and he is instructed to reward you with the tool.")
		legion_faction(e, 2)
		e.other:AddEXP(200)
		e.other:GiveCash(0, 0, 1, 0)
		e.other:SummonItem(eq.ChooseRandom(18213, 18211, 18210)) -- Note to Iksar Lord
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
