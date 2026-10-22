-- P99 scope: keep legacy guild-note fallback and non-reward lore; remove later BoneMail training.
-- Canonical P99 guild-note giver is Nezzka Tolax. Existing fallback values retained, not newly certified.
-- items: 18757, 13586
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("So you are the next pathetic maggot I have the displeasure of training to be a useful Shadowknight of the Lodge of the Dead.")
    elseif e.message:findi("ultricle") then
        e.self:Say("In the Nektulos Forest near the pass to the Lavastorm Mountains is a gray region barren of life whose boundaries are marked by carved stones displaying runes the color of freshly spilt blood. The area the runed stones mark is called the Ultricle. It is where the weak. dead. and dying Teir'Dal that have not earned a noble burial are left to rot and one day if they are lucky join the ranks of the Undead.")
    end
end
function event_trade(e)
    local item_lib = require("items")
    if item_lib.check_turn_in(e.trade, {item1 = 18757}) then
        e.self:Say("Thanks.")
        e.other:SummonItem(13586)
        e.other:AddEXP(100)
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
