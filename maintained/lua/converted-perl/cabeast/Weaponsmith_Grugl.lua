-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Weaponsmith_Grugl.pl
-- P99 audit: Warrior Pike Quests
-- Note: P99 marks the Champion Mancatcher and later pikes as post-Classic/Kunark.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Come to assist in the testing of the bashing equipment? Nah. Not you. You are too small. You must be here to practice your forging.")
	elseif e.message:findi("footmans pike") then
		e.self:Say("To forge a footman pike requires skill as well as an iron rod, forging hammer and a footman pike head. To forge the pike head you will need a geozite tool, raw pike head and petrified redwood if the footman pike head plans are yours.")
	elseif e.message:findi("soldier pike") then
		e.self:Say("To forge a soldier pike requires skill, not to mention an iron rod, a forging hammer plus a soldier pike head. To forge the pike head, you will need a geozite tool, raw pike head and frontier fools gold as well as the soldier pike head plans.")
	elseif e.message:findi("trooper pike") then
		e.self:Say("To forge a trooper pike requires much skill! You also need an iron rod, forging hammer plus a trooper pike head. To forge the pike head, you will need the trooper pike head plans, a geozite tool, raw pike head and a radiant meteorite.")
	elseif e.message:findi("legionnaire mancatcher") then
		e.self:Say("To forge a legionnaire mancatcher, a blacksmith of great skill would need the steel rod, forge hammer and the forged legionnaire mancatcher crown. That crown is forged with the geozite tool, legionnaire crown plans, a raw crown and a peridot.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
