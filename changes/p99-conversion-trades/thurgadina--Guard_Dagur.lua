-- Converted from sources/projecteq/thurgadina/Guard_Dagur.pl
-- Original Perl SHA256: fa9b923c387a88c33ee212857ac2fe2b8e38d15cc0a4cd5dd1d3c71bbc450464
-- Review: changes/p99-conversion-trades/closure-review.json
-- Full source conversion with a boolean presence check, not Perl defined(false).
-- Guard Baldvin is exact NPC 115132 and remains the speaker of his own line.
-- Read-only lookup only; no spawn or actor identity changes.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Greetings and welcome to Thurgadin, " .. e.other:GetCleanName() .. ". Ye best watch yer step on the bridge there, it can be a bit slippery.")
        local entities = eq.get_entity_list()
        if entities:IsMobSpawnedByNpcTypeID(115132) then
            local baldvin = entities:GetMobByNpcTypeID(115132)
            if baldvin then
                baldvin:Say("Aye, we wouldn't want ye fallin into the pit now would we.")
            end
        end
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
