-- P99-only replacement of cabwest/an_Iksar_hermit.pl.
-- P99: Necromancer_Skullcap_Quests and An_iksar_hermit (cached evidence).
-- Rank eight cannot be completed on P99. The documented repeatable faction
-- phrase works for other classes without a cap/level prerequisite.
-- P99 does not give an amount: +1 Brood of Kotiz is an explicit IdleQuest
-- approximation. Quest faction gating remains deliberately bypassed.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("I am looking for a [great sorcerer]. Are you such a person?")
    elseif e.message:findi("great sorcerer") then
        e.other:Faction(443, 1, 0)
    end
end

function event_trade(e)
    -- Never turn pre-existing/test-created later-era components into rank eight.
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
