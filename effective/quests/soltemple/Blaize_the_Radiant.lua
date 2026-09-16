-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/Blaize_the_Radiant.pl
-- items: 4921, 4924, 4922, 4923

local function temple_faction(e)
	e.other:Faction(415, 15, 0)
	e.other:Faction(416, -15, 0)
	e.other:AddEXP(1000)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, faithful one. I am Blaize the Radiant. Brother Gavel and I are well known among clerics for our forging skills, but special payment is required for our services. Special [Ingots and Icons] given to our members have been lost, and we will reward whoever retrieves them for us.")
	elseif e.message:findi("ingots and icons") then
		e.self:Say("The Ingots and Icons are all named after the virtues of the cleric who held them. The virtues I require are those of the [Reliant], the [Ardent], the [Fervent] and the [Penitent].")
	elseif e.message:findi("reliant") then
		e.self:Say("Turgan the Reliant lived in a cabin in the Kithicor woods until there was a great fire. Searching the burned cabins there may turn something up. He always loved Lake Rathetear as well. Bring me the Ingot of the Reliant, the Icon of the Reliant, and one Enchanted Platinum Bar and I will forge them into a reward for you.")
	elseif e.message:findi("ardent") then
		e.self:Say("Theo the Ardent was in constant war with a gnome necromancer in Befallen named Babbinsbort, but he never could defeat him. Poor Theo drown on an expedition to Everfrost when the ice of the frozen river gave way underneath him. Bring me the Ingot of the Ardent, the Icon of the Ardent, and 1 Galvanized Platinum Bar and I will forge them into a reward for you.")
	elseif e.message:findi("fervent") then
		e.self:Say("Jovan the Fervent was always prone to vice. He lost his ingot in a game of Kings Court with an aviak named Gull in the Ocean of Tears. After that he became a drunkard and it has been said he lurks around the bars in Highpass Hold. Bring me the Ingot of the Fervent, the Icon of the Fervent, and 1 Vulcanized Platinum Bar and I will forge them into a reward for you.")
	elseif e.message:findi("penitent") then
		e.self:Say("Astrid the Penitent often visited the frogloks of Upper Guk. She once told me her ingot was hidden underwater there. I found that strange because she couldn't swim. She was also a good friend to the Kerrans of Kerra Ridge, where she lost her life fighting against the Erudite hereitic Maugarim. Bring me the Ingot of the Penitent, the Icon of the Penitent, and one Magnetized Platinum Bar and I will forge them into a reward for you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 19001, item2 = 19002, item3 = 16507}) then
		e.self:Say("Well done! Please take these boots as your reward.")
		e.other:SummonItem(4921)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 19007, item2 = 19008, item3 = 19049}) then
		e.self:Say("Well done! Please take these greaves as your reward.")
		e.other:SummonItem(4924)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 19003, item2 = 19004, item3 = 19047}) then
		e.self:Say("Well done! Please take these gauntlets as your reward.")
		e.other:SummonItem(4922)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 19005, item2 = 19006, item3 = 19048}) then
		e.self:Say("Well done! Please take these vambraces as your reward.")
		e.other:SummonItem(4923)
		temple_faction(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
