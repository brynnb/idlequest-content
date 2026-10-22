-- P99 review: 2026-10-22; cached wiki evidence retained in review.json.
-- Quest faction requirements intentionally bypassed; no new level gate.
-- P99 Souvenir Mugs: three gold buys Doogle's Signature Souvenir Mug (30147).
-- Ambient signals retain ProjectEQ provenance; not independent P99 evidence.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Welcome ta me bar, I suggest ye sit down and have a drink cause if'n ye ain't drinkin ye've no business bein 'ere.")
    elseif e.message:findi("mug") then
        e.self:Say("Mug, yeah we got a lot of mugs here but what has that got to do with anything.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    if item_lib.check_turn_in(e.trade, {gold = 3}) then
        e.other:SummonItem(30147)
    end
    item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
    if e.signal == 1 then
        e.self:Say("Hello there Horasug! What brings ya here?")
        eq.signal(115013,3,8000)
    elseif e.signal == 2 then
        e.self:Say("A vision you say? What exactly was this a vision of?")
        eq.signal(115013,4)
    elseif e.signal == 3 then
        eq.signal(115013,5,7000)
    elseif e.signal == 4 then
        e.self:Say("Well, you came to the right place, Horasug. A few of these ales will fill you with all the visions you can handle.")
    end
end
