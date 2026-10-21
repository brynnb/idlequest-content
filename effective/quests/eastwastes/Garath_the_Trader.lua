-- Source: eastwastes/Garath_the_Trader.pl (ProjectEQ)
-- P99: https://wiki.project1999.com/Garath%27s_Weapons_to_Trade
-- The walkthrough confirms the four exchanges, including both hammers together.
-- P99 gives no XP amount; preserve ProjectEQ's 1000 XP per accepted exchange.
local item_lib = require("items")

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hail to ya, Traveller, and well met! My Name's Garath, a warrior by trade, though I do dabble in some merchanting on the side. My exploring brought me here, and I saw some wonderous things. I ventured inside this ancient tomb with some friends, and oh! The horrors we encountered! I barely made it out alive, but I did manage to pick up some [weapons to trade].")
    end
    if e.message:findi("weapons") then
        e.self:Say("Interested in a trade, are ya? Well, let me tell ya.. I headed into this tomb in hopes of getting a sword I could use, maybe a warhammer.. Humm, yeah a hammer woulda been good also.. Anyhow, I was unlucky in finding those, but I did manage to get a couple weapons... Sadly, they're really more suited to a [Monk] or a [Knight], not really much use to a warrior like myself at all.")
    end
    if e.message:findi("monk") then
        e.self:Say("Ah, my eyes fail me lately.. Maybe the cold weather is getting to me? Well, in any case, I picked up some velium hand wraps inside the Tomb here, quite nice.. Yes indeed. I guess I would trade them to ya if you were to give me a warhammer for em. I gotta say, I'm not picky. I'd accept either a primal or a priceless warhammer, and give you these wraps in a straight trade. Heck, I'd take one of each and give you both these hand wraps.")
    end
    if e.message:findi("knight") then
        e.self:Say("Knight? Yeah, I don't make much distinction, paladin or shadow knight, they're all knights to me. Well, look here, I got two swords from inside the tomb, but I'll be damned if either of em was suited for a warrior. Clearly a knight's blade, what bad luck for me. I was hopin for a good warsword. That's why I'm standin out here ya know? I was hopin I could find someone who might swap me either a primal or priceless warsword, and take one of these knightly swords in trade.")
    end
end

local trades = {
    { 27301, 5833 },
    { 27321, 27320 },
    { 27300, 5834 },
    { 27328, 5835 },
}

function event_trade(e)
    local accepted = false
    for _, trade in ipairs(trades) do
        -- Each check consumes one matching item. Process independent exchanges,
        -- rather than the Perl elsif chain which only rewards the first weapon.
        for slot = 1, 4 do
            if not item_lib.check_turn_in(e.trade, { item1 = trade[1] }) then break end
            e.other:SummonItem(trade[2])
            e.other:AddEXP(1000)
            accepted = true
        end
    end
    if accepted then
        e.self:Say("Ah, excellent! Guess standin out here in the cold proved worthwhile for me after all. You take that weapon and enjoy it, I know I'll be getting some use of this one. Safe travel to ya, friend!")
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
