-- P99 scope: keep legacy guild-note fallback; remove post-Luclin Truthbringer training.
-- Canonical P99 guild-note giver is Valeron Dushire. Existing fallback values retained, not newly certified.
-- items: 18737, 13554
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Greetings and well met " .. e.other:GetName() .. ". I am Edwardian Holyblade, noble paladin of Marr. I have devoted my life and my blade to the glory of Mithaniel Marr.");
    end
end
function event_trade(e)
    local item_lib = require("items");
    if item_lib.check_turn_in(e.trade, {item1 = 18737}) then
        e.self:Say("Thanks."); -- Real text still needed
        e.other:Ding();
        e.other:SummonItem(13554); -- Faded Purple Tunic
        e.other:AddEXP(100);
    end
    item_lib.return_items(e.self, e.other, e.trade);
end
