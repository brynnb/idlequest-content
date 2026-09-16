-- P99 source: Divine Duty
-- name: Ulazia_W`Selo

local function priests_of_innoruuk_liked(e)
	return e.other:GetFaction(e.self) <= 4
end

local function cast_divine_duty_spell(e, spell_id)
	e.self:Say("May the breath of life pass through your failing body and cast its foes from you. Unnngh... Praise Innoruuk!")
	e.self:CastSpell(spell_id, e.other:GetID())
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Spires of Innoruuk. May your destiny be paved with the Words of Innoruuk. What is it you seek? [Healing]? [Curing of disease]? [Curing of poison]? That is my divine duty. So commands Master Zexus.")
	elseif e.message:findi("healing") then
		e.self:Say("So, it is the binding of wounds you desire. I could hardly tell with the smell of sacrifice drifting through the corridors of the Spires of Innoruuk. To be healed, I require a donation of 10 gold coins.")
	elseif e.message:findi("curing of disease") then
		e.self:Say("Whatever the malady, I can surely rid you of it. First, you must donate 6 gold coins. The power of life is not easily acquired when you follow the unholy might of Innoruuk.")
	elseif e.message:findi("curing of poison") then
		e.self:Say("So, a toxic substance races to your heart? It is best we stop that at once! Ah... But, before I go on, you must pay the required donation of 8 gold coins.")
	elseif e.message:findi("innoruuk") then
		e.self:Say("You speak the name of the Prince of Hate. He is the higher power who set the Teir'Dal upon this land. All Teir'Dal pay homage to him. If they do not, they are surely [heretics]. And, if they are heretics, they surely must die!")
	elseif e.message:findi("heretics") then
		e.self:Say("Speak not of Teir'Dal Heretics. Those Teir'Dal who do not follow Innoruuk shall be cut down! Master Kerton R`dev of the Spires of Innoruuk is seeing to that.")
	elseif e.message:findi("teir") then
		e.self:Say("I see the ancient language of the elf kind has been neglected. We dark elves are the Teir'Dal, superior to all elves. The high elves are known as the Koada'Dal and the wood elves are the Feir'Dal. There was once another, but that race is now extinct.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if priests_of_innoruuk_liked(e) and item_lib.check_turn_in(e.trade, {gold = 10}) then
		cast_divine_duty_spell(e, 17) -- Light Healing
	elseif priests_of_innoruuk_liked(e) and item_lib.check_turn_in(e.trade, {gold = 8}) then
		cast_divine_duty_spell(e, 203) -- Cure Poison
	elseif priests_of_innoruuk_liked(e) and item_lib.check_turn_in(e.trade, {gold = 6}) then
		cast_divine_duty_spell(e, 213) -- Cure Disease
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
