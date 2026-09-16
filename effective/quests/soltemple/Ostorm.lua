-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/Ostorm.pl
-- items: 10128, 19049

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am Ostorm of the Temple of Solusek Ro, guardian of the sacred crystal of Kintaz. Be wary and keep your distance, lest the proximity of the crystal [steal] your [memories].")
	elseif e.message:findi("steal my memories") then
		e.self:Say("It is the nature of the crystal of Kintaz to steal the memories of those around it. Only I am safe, and then only because of the strong wardings placed on me by Solusek Ro himself. Are you interested in [losing] any [memories]?")
	elseif e.message:findi("losing my memories") then
		e.self:Say("Recently, I have been experimenting with the crystal, and have found that those exposed to ruby light filtered through it tend to lose the memories of their most specialized arcane skills. Are you sure you want to [lose advanced memory] of specialization?")
	elseif e.message:findi("lose advanced memory") then
		e.self:Say("Be warned that once exposed to the crystal, I can not reverse the effects. If you desire exposure, fetch me a ruby.")
	elseif e.message:findi("fifty gold") then
		e.self:Say("You do not remember?  You promised me fifty gold coins for allowing you to be exposed to the sacred crystal of Kintaz.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10035}) then
		e.self:Say("..hear me? Ah, you seem to be coming out of your stupor. I think you have been exposed to the crystal long enough. By the time you leave the temple, your memories should have faded. Do you have the [fifty gold] coins that you owe me?")
		e.other:SetSkill(43, 49) -- Specialize Abjuration
		e.other:SetSkill(44, 49) -- Specialize Alteration
		e.other:SetSkill(45, 49) -- Specialize Conjuration
		e.other:SetSkill(46, 49) -- Specialize Divination
		e.other:SetSkill(47, 49) -- Specialize Evocation
		e.other:Faction(415, 1, 0)
		e.other:Faction(416, -1, 0)
		eq.zone_emote(MT.Emote, "Your specialize skills have all been set to 49.")
		e.other:AddEXP(1000)
	elseif item_lib.check_turn_in(e.trade, {gold = 50}) then
		e.self:Say("Thank you.")
		e.other:Faction(415, 1, 0)
		e.other:Faction(416, -1, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10031, item2 = 10031, item3 = 10000}) then
		e.self:Say("Ahh, Genni must have sent you to me. Very well, here is your Lambent Fire Opal.")
		e.other:SummonItem(10128)
		e.other:Faction(415, 1, 0)
		e.other:Faction(416, -1, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 16507}) then
		e.self:Say("I see that Gavel has sent you to me. Very well, I have magnetized your platinum bar - take it.")
		e.other:SummonItem(19049)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
