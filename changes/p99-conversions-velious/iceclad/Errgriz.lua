-- P99 review: 2026-10-22; cached wiki evidence retained in review.json.
-- Quest faction requirements intentionally bypassed; no new level gate.
-- P99 Learn the Ways of Skinning and Tailoring.
-- 30023 High Quality Dire Wolf Fur -> 30037 Wolf Fur Earcovers.
-- The wiki lists no XP, cash, or faction reward; none is invented here.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Errrr. You come for master, [learning] like me?")
    elseif e.message:findi("learning") then
        e.self:Say("I am learning ways of skinning and tailoring. None left but the master so I must learn to help. For now I only [clean the furs].")
    elseif e.message:findi("clean") then
        e.self:Say("Yes. I clean the furs and then the master [makes things] from them.")
    elseif e.message:findi("things") then
        e.self:Say("I wish I could make things. Headcoverings, to keep cold from head is what I want to make. I think I ready but not able to make until I get furs. Master says to find skin of high quality, thick and strong, but I have no training in hunting.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    if item_lib.check_turn_in(e.trade, {item1 = 30023}) then
        e.self:Emote("starts to cut and scrape the furs. He growls softly as he works and his master watches his progress.")
        e.self:Say("Grrr. Much too small. I fail. I not ready to work on my own. Sorry to waste your time. Here, take what I made. Maybe you can find use for it.")
        e.other:SummonItem(30037)
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
