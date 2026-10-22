-- enabled: false
-- P99 source-only scope exclusion: later_newcomer_armor_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Kanthu_M-Rekkor.pl
-- items: 17124, 19561, 19558, 19555, 19559, 19560, 19557, 19556, 2416

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". So you are one of Selzar's new recruits. You are to assist in the construction of the armor you will don as a new Rogue of the House of the Ebon Mask. I have assembled a kit that is used in the crafting of Ashen Bone Mail. You must travel beyond Neriak into the Nektulos Forest for the [materials] that compose the armor.")
	elseif e.message:findi("materials") then
		e.self:Say("Many species of dangerous creatures, the restless dead, and halfling invaders from Rivervale inhabit the Nektulos Forest. You must defeat these creatures and halflings in order to obtain the materials. The materials you seek depend on the piece of armor you desire. Do you desire to craft [gloves], [boots], a [bracer], a [coif], [leggings], [sleeves], or a [tunic]?")
		e.other:SummonItem(17124)
	elseif e.message:findi("boots") then
		e.self:Say("To craft Ashen Bone Mail Boots you require two [silk thread], two ruined ash drakeling scales, and two halfling foot bones. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Boot Pattern.")
		e.other:SummonItem(19561)
	elseif e.message:findi("bracer") then
		e.self:Say("To craft an Ashen Bone Mail Bracer you require a [silk thread], a ruined ash drakeling scales, and a halfling ulna bone. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Bracer Pattern.")
		e.other:SummonItem(19558)
	elseif e.message:findi("coif") then
		e.self:Say("To craft a Ashen Bone Mail Coif you require two [silk thread], a ruined ash drakeling scales, and a halfling skull. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Cap Pattern.")
		e.other:SummonItem(19555)
	elseif e.message:findi("gloves") then
		e.self:Say("To craft Ashen Bone Mail Gloves you require two [silk thread], a ruined ash drakeling scales, and two halfling finger bones. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Glove Pattern.")
		e.other:SummonItem(19559)
	elseif e.message:findi("leggings") then
		e.self:Say("To craft Ashen Bone Mail Leggings you require three [silk thread], ash drakeling scales, two halfling tibia, and a halfling pelvis bone. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Leggings Pattern.")
		e.other:SummonItem(19560)
	elseif e.message:findi("sleeves") then
		e.self:Say("To craft Ashen Bone Mail Sleeves you require two [silk thread], ash drakeling scales, and two halfling humerus bones. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Sleeves Pattern.")
		e.other:SummonItem(19557)
	elseif e.message:findi("tunic") then
		e.self:Say("To craft an Ashen Bone Mail Tunic you require four [silk thread], pristine ash drakeling scales, a halfling sternum, and a halfling ribcage. Once you have the necessary components combine them in your Mail Assembly Kit with this Tattered Tunic Pattern.")
		e.other:SummonItem(19556)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 2416}) then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". So you are one of Selzar's new recruits. You are to assist in the construction of the armor you will don as a new Rogue of the House of the Ebon Mask. I have assembled a kit that is used in the crafting of Ashen Bone Mail. You must travel beyond Neriak into the Nektulos Forest for the [materials] that compose the armor.")
		e.other:AddEXP(500)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
