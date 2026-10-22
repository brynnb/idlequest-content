-- P99 Crest page also verifies the fourth Lithiniath branch; dynamic player name replaces transcript Pharos.
-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/wakening/Lady_Gelistial.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Emote("Lady Gelistial nods towards " .. e.other:GetCleanName() .. " and a soft gentle voice whispers in your mind as if carried by the breeze passing through the gentle grove. You tread upon the sacred ground of Tunare. I am the Lady Gelistial, baroness of the Tunarean Unicorns. Are you a [friend] of the Tunarean Court?")
    end
    if e.message:findi("friend") then
        e.self:Say("Be wary of the black unicorns then my friend. All unicorns once inspired dreams and fascination in mortals but the lineage of Lithiniath has been twisted and now inspire delusions and madness. If my duties here were not so pressing I would seek the wisdom of [Prince Thirneg] in finding a cure for the cursed bloodline of Lithiniath.")
    end
    if e.message:findi("Prince Thirneg") then
        e.self:Say("Prince Thirneg is the ruler of the Tunarean Court. He resides in the Plane of Growth where he is constant contact with the all mother herself.")
    end
    if e.message:findi("lithiniath") then
        e.self:Say("Lithiniath was once a proud and noble Unicorn until he stumbled upon the realm of Fizzlethorpe Bristlebane. The lord of mischief twisted the magical nature of Lithiniath. The once noble unicorns fur grew blacker as delusions clouded his mind and madness follows where he treads.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
