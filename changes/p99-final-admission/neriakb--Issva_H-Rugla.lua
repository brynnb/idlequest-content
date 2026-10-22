-- enabled: false
-- P99 source-only scope exclusion: later_newcomer_armor_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Issva_H-Rugla.pl
-- items: 19559, 19561, 19558, 19555, 19560, 19557, 19556, 31753, 17124

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("If you're looking for chit chat you can bugger off. I'm here to sell supplies not company.")
	elseif e.message:findi("materials") then
		e.self:Say("Many species of dangerous creatures, the walking dead, and invading Deathfist Orcs inhabit the Nektulos Forest. You must defeat these creatures and undead in order to obtain the materials. The materials you seek depend on the piece of armor you desire. Do you desire to craft [gauntlets], [boots], a [bracer], a [helm], [greaves], [vambraces], or a [breastplate]?")
	elseif e.message:findi("gauntlets") then
		e.self:Say("To craft Orc Slayer Gauntlets you require two [silk thread], a cracked pyre beetle carapace, and two orc finger bones. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Glove Pattern.")
		e.other:SummonItem(19559)
	elseif e.message:findi("boots") then
		e.self:Say("To craft Orc Slayer Boots you require two [silk thread], two cracked pyre beetle carapaces, and two orc foot bones. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Boot Pattern.")
		e.other:SummonItem(19561)
	elseif e.message:findi("bracer") then
		e.self:Say("To craft an Orc Slayer Bracer you require a [silk thread], a cracked pyre beetle carapace, and an orc ulna bone. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Bracer Pattern.")
		e.other:SummonItem(19558)
	elseif e.message:findi("helm") then
		e.self:Say("To craft an Orc Slayer Helm you require two [silk thread], a cracked pyre beetle carapace, and an orc skull. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Cap Pattern.")
		e.other:SummonItem(19555)
	elseif e.message:findi("greaves") then
		e.self:Say("To craft Orc Slayer Greaves you require three [silk thread], a pyre beetle carapace, two orc tibia, and an orc pelvis bone. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Leggings Pattern.")
		e.other:SummonItem(19560)
	elseif e.message:findi("vambraces") then
		e.self:Say("To craft Ord Slayer Vambraces you require two [silk thread], a pyre beetle carapace, and two orc humerus bones. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Sleeves Pattern.")
		e.other:SummonItem(19557)
	elseif e.message:findi("breastplate") then
		e.self:Say("To craft an Orc Slayer Breastplate you require four [silk thread], a pristine pyre beetle carapace, an orc sternum, and an orc ribcage. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Tunic Pattern.")
		e.other:SummonItem(19556)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 31753}) then
		e.self:Say("So you are one of Jarrex's new recruits. You are to assist in the construction of the armor you will don as a new Warrior of the Indigo Brotherhood. I have assembled a kit that is used in the crafting of Orc Slayer Mail. You must travel beyond Neriak into the Nektulos Forest for the [materials] that compose the armor.")
		e.other:SummonItem(17124)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
