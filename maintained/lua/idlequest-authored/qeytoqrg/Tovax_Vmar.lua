-- P99 audit: Plaguebringer Proof
-- Tovax's P99 route drops a Sealed Letter on the ground during his Qeynos Hills path.
-- IdleQuest makes the letter appear as a character-scoped ground object when Tovax is killed.
-- items: 18802

function event_death_complete(e)
	e.self:Say("A sealed letter slips from Tovax's robes and lands in the dirt.")
	eq.create_ground_object(18802, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading(), 3600000)
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18802}) then
		e.self:Say("Oh yeah that's mine. Thanks chump... I mean chum. Here's a little something for you.")
		e.other:Faction(221, 50, 0) -- Bloodsabers
		e.other:Faction(262, -10, 0) -- Guards of Qeynos
		e.other:Faction(296, 10, 0) -- Opal Dark Briar
		e.other:Faction(341, -10, 0) -- Priests of Life
		e.other:Faction(230, 10, 0) -- Corrupt Qeynos Guards
		e.other:AddEXP(500)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
