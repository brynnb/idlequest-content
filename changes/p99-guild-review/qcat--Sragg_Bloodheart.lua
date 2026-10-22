-- IdleQuest starting guild note turn-in.
-- Source: qcat/Sragg_Bloodheart.pl
-- P99 audit: Plaguebringer Proof
-- items: 18706, 13598, 18802

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18802}) then
		e.self:Say("What have you brought me, worm? Hmm.. This is disappointing. That Tovax has failed us for the last time. Your loyalty to Bertoxxulous and the Bloodsabers has been noted.")
		e.other:Faction(221, 50, 0) -- Bloodsabers
		e.other:Faction(262, -10, 0) -- Guards of Qeynos
		e.other:Faction(296, 10, 0) -- Opal Dark Briar
		e.other:Faction(341, -10, 0) -- Priests of Life
		e.other:Faction(230, 10, 0) -- Corrupt Qeynos Guards
		e.other:GiveCash(11, 11, 0, 0)
		e.other:AddEXP(500)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 18706}) then
		e.self:Say("Ah, another would-be soldier for the army of the Plaguebringer. Begone!")
		e.other:SummonItem(13598)
		e.other:AddEXP(100)
		e.other:Faction(221, 100, 0)
		e.other:Faction(262, -15, 0)
		e.other:Faction(296, 10, 0)
		e.other:Faction(341, -25, 0)
		e.other:Faction(230, 5, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
