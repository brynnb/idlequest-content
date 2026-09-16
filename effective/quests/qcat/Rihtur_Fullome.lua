-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/Rihtur_Fullome.pl
-- P99: https://wiki.project1999.com/The_Clothspinner_Sisters_(evil)
-- items: 13302

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetName() .. "! I hope the trek into our shrine has not scarred you in any way. Our defenses have been increased lately. Many of the citizens have heard rumors about our shrine. I say it is all due to that [soldier].")
	elseif e.message:findi("soldier") then
		e.self:Say("The soldier I refer to is Commander Kane Bayle. The supreme officer himself. Don't get me wrong. I trust Kane. He has quite a black heart. I just don't trust that girl, [Nerissa].")
	elseif e.message:findi("nerissa") then
		e.self:Say("Nerissa Clothspinner. Her sister was a good friend of Kane's. When she left Qeynos to venture into the world, she asked Kane to watch over the girl. Now Kane tries to hide from this child the fact that he is allied with our church. I do not think he has hidden it well. I have told the others. but they do not believe me. I do not care. I have my own [plans].")
	elseif e.message:findi("plans") then
		e.self:Say("Nerissa is well protected by Kane. She will no doubt attempt to inform someone of her suspicions, most likely her sister, Milea. You must find Milea Clothspinner and kill her. No word of our operations must leak out. Return with proof of Milea's death and we shall see to a reward.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:GetFaction(e.self) <= 4 and item_lib.check_turn_in(e.trade, {item1 = 13302}) then -- Monogrammed Cloth
		e.self:Say("Hah! Well done indeed!")
		e.other:Faction(221, 10, 0) -- Bloodsabers
		e.other:Faction(262, -10, 0) -- Guards of Qeynos
		e.other:Faction(230, 10, 0) -- Corrupt Qeynos Guards
		e.other:Faction(296, 10, 0) -- Opal Dark Briar
		e.other:Faction(341, -10, 0) -- Priests of Life
		e.other:AddEXP(1000)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
