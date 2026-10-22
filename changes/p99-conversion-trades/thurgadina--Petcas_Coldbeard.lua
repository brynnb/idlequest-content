-- Converted from sources/projecteq/thurgadina/Petcas_Coldbeard.pl
-- Original Perl SHA256: 24b7007971fb26ec3faf5d1e0e3fe3c812571e26c50957f9ed7ce1e90a1e7ab8
-- Review: changes/p99-conversion-trades/closure-review.json
-- Partial: bounded Icy Mug greeting and Ronodun signal responses; refunds all trades.
-- Special Beans 60290 belongs to Warrior epic 1.5 prequest and is excluded.
-- P99 Souvenir Mugs names Adia, not Petcas, for the 5-gold stein 30145; no duplicate source is invented.
-- Ronodun 115019 supplies external initiation; this script does not spawn or drive that actor.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hail to ye as well offlander. I bid you welcome to the Icy Mug, one o' the finest establishments for a drink in Thurgadin.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:Say("What's the rush there, youngster?")
        eq.signal(115019, 1)
    elseif e.signal == 2 then
        e.self:Say("That's not good, the Grand Historian's mighty protective of his daughter. What he do after he caught ya?")
        eq.signal(115019, 2)
    elseif e.signal == 3 then
        eq.signal(115019, 3)
    elseif e.signal == 4 then
        e.self:Say("Well, coulda been worse. A month's worth of sermons is a far sight better than a trip to the bottom of the Dain's well.")
        eq.signal(115019, 4)
    elseif e.signal == 5 then
        e.self:Say("Here ya go, Ronodun, on the house this time. Drink fast, don't need the Grand Historian to come lookin' fer ya...")
        eq.signal(115019, 5)
    elseif e.signal == 6 then
        e.self:Say("My pleasure, son. You just remember to keep me in all those prayers you'll be sayin this month. Hahhahah!")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
