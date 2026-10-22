-- enabled: false
-- P99 source-only scope exclusion: later_newcomer_armor_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Jarrex_N-Ryt.pl
-- items: 31753, 16173, 19565, 19564, 19606, 19562, 19609

local function is_dark_elf_warrior(e)
	return e.other:Class() == "Warrior" and e.other:Race() == "Dark Elf"
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What have we here? A new weakling that wishes to reap some sort of self-value and renown through service to the Indigo Brotherhood perhaps? Well speak up whelp!! Have you come to [destroy the enemies of Neriak] or are you a coward better suited to mop the filth from the back rooms of the Maidens Fancy.")
	elseif e.message:findi("destroy the enemies of Neriak") then
		if is_dark_elf_warrior(e) then
			e.self:Say("If you are going to be of any value to the Indigo Brotherhood you will need to outfit yourself in a suit of armor that will turn aside the blades of enemy forces. From the looks of you even the tiny fangs of a moss snake could bring you death. Take this request form to Issva H'Rugla to get yourself started on the assembly of your armor. When you have procured some protection for your weakling body return to me for [further instruction].")
			e.other:SummonItem(31753)
		else
			e.self:Say("Begone fool, you are no member of the Indigo Brotherhood!")
		end
	elseif e.message:findi("further instruction") then
		e.self:Say("Ah, you are eager to advance further within the Indigo Brotherhood. Although it is my duty to aid your training, do not allow your arrogance to blind you to your lowly position amongst the Kings most loyal subjects. Your next task is to assist the construction of a [weapon] and [shield] worthy of being wielded by a Warrior of the Indigo Brotherhood.")
	elseif e.message:findi("weapon") then
		e.self:Say("Beyond the mouth of Neriak lies the Nektulos Forest. There the Deathfist Clan of Orcs has set up camps in an attempt to invade and claim the Nektulos Forest. Slay these invaders and bring to me an Orc Templar Scalp, an Orc Fibula bone, and an Orc Clavicle bone.")
	elseif e.message:findi("shield") then
		e.self:Say("Young Kodiak Bears often wander into the Nektulos Forest from the Commonlands searching for food. You do not appear to have the strength to arm wrestle a pixie. If you prove me wrong by slaying Young Kodiaks and bringing me four Young Kodiak Femurs I will guide you in the construction of a shield worthy of a warrior of the Indigo Brotherhood.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if is_dark_elf_warrior(e) and item_lib.check_turn_in(e.trade, {item1 = 16173, item2 = 19565, item3 = 19564}) then
		e.self:Say("Excellent.  Here is your weapon, " .. e.other:GetName() .. ".  Use it to slay more!")
		e.other:SummonItem(19606)
	elseif is_dark_elf_warrior(e) and item_lib.check_turn_in(e.trade, {item1 = 19562, item2 = 19562, item3 = 19562, item4 = 19562}) then
		e.self:Say("So you have more strength than you seem to.  Hmm...here is your shield, " .. e.other:GetName() .. ".")
		e.other:SummonItem(19609)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
