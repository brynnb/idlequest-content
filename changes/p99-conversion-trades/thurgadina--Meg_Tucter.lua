-- Converted from sources/projecteq/thurgadina/Meg_Tucter.pl
-- Original Perl SHA256: 0e11fa8e629a53cedcdd13802f65107dece1782986f083b0f7912e63236c9ff4
-- Review: changes/p99-conversion-trades/closure-review.json
-- Partial: geonid lore and return-only trade.
-- Etching Tools 8893 and their eighth-Shawl offer are positively outside the P99 seven-Shawl cutoff.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("The gems I carry were actually collected by geonids, a race of rock and gem people that communicate with their minds alone. If'n ye haven't had the chance to see one yet I suggest ye journey to the Wakenin' Lands; they've reportedly got a colony somewhere in that area.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
