-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/Kurne_Rextula.pl
-- items: 17002, 10018, 12137, 12136

local function bloodsaber_faction(e, priests_delta, exp)
	e.other:Ding()
	e.other:Faction(221, 10, 0)
	e.other:Faction(262, -1, 0)
	e.other:Faction(296, 1, 0)
	e.other:Faction(341, priests_delta, 0)
	e.other:Faction(230, 1, 0)
	e.other:AddEXP(exp)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the new order of life, the life of service to our diseased Lord, Bertoxxulous. Did you encounter any of my [pets] on the way here? I hope not.")
	elseif e.message:findi("pets") then
		e.self:Say("My pets are the skeleton guardians of these catacombs. Some have been behaving erratically since the arrival of [Drosco].")
	elseif e.message:findi("drosco") then
		e.self:Say("Drosco used to be a loyal member of our shrine, until we learned the truth. The truth was that he was a mole from the Knights of Thunder. It appears they are assisting the Temple of Life in their pursuit of our eradication. Drosco was apprehended and boiled alive. I turned his boiled body into a zombie to march these halls. Now he must be stopped. He has begun to [compromise the shrine's location].")
	elseif e.message:findi("compromise") then
		e.self:Say("The problem is, he was strong in Karana's faith. And as sometimes is the case, there is a resonance from his deity. This causes him to wander in and out of our hidden shrine and I believe it also interferes with my control of the other pets. Please find him and destroy him. Bring me back the note I placed upon his body. Go!!")
	elseif e.message:findi("new task") then
		e.self:Say("I have been working with a man named Lord Grimrot. We are attempting to raise an army of undead in the Plains of Karana. When the time is right, we shall attack from within as well as from beyond the walls of Qeynos. This army needs one more commander. I must find a Bloodsaber to [retrieve the commander]")
	elseif e.message:findi("retrieve the commander") then
		e.self:Say("I have searched for the appropriate man... Sir Lucan of Freeport, Field Marshal Ralem, Marshal Anrey of Rivervale, even Commander Kane Bayle. Any of them would do, but they are either inaccessible or share a common goal with us. So I have decided Trumpy Irontoe is the one. Any former member of the [Irontoe Brigade] has a wealth of military strategies. Kill him and bring me his head. Kane will not be pleased, but, it must be done.")
	elseif e.message:findi("irontoe brigade") then
		e.self:Say("The Irontoe Brigade was a legendary military unit hailing from the dwarven city of Kaladim. After a dangerous assault, where more than three quarters of the unit met their bloody fate, the brigade disbanded and left for parts unknown. In Fish's Bar, in Qeynos, you can find one of them, Trumpy Irontoe.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18805}) then
		e.self:Say("Good work! You shall rise quickly in our ranks of evil. Let no man stand in your way and never betray the shrine or you to will join our collection of undead. You can also assist me with a [new task].")
		e.other:SummonItem(eq.ChooseRandom(17002, 10018))
		bloodsaber_faction(e, -1, 1000)
		e.other:GiveCash(0, 3, 0, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12136}) then
		e.self:Say("Incredible!! You have slain one of the greatest warriors in Qeynos!! He must have been full of grog. No doubt he drank most of his skill away. Now I shall cast a spell and strip the flesh from his skull and.. Presto!! Take this skull to Lord Grimrot somewhere in the Plains of Karana. He will be in the center of a field of skeletons. If he is not there, wait for his return. He must return eventually.")
		e.other:SummonItem(12137)
		bloodsaber_faction(e, -2, 125)
		e.other:GiveCash(eq.ChooseRandom(50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70), 0, 0, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
