-- P99 review: 2026-10-22; cached wiki evidence retained in review.json.
-- Quest faction requirements intentionally bypassed; no new level gate.
-- P99 NPC page corroborates hail; punctuation retained from ProjectEQ.
-- Tiny Savages kill target: no invented hand-in, reward, or scripted death loot.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hello there, as the official Royal Scribe of Dain Frostreaver IV, it is my duty to pen, NO . . . WAIT. . . write. NO . . . I mean scribe, yes that's the word I'm looking for. I scribe the thoughts of the Dain for posterity. I currently have record books with a combined 11,982 pages of notes detailing the life and business of our present Dain. You see, I have a rather bad memory, so I write everything down. My latest entry is that on this day " .. e.other:GetName() .. " came and talked to me. Anyhow, I'm sure you have much better things to do than talk to me, so good luck in your ventures, " .. e.other:GetName() .. ", and come visit me any time.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
