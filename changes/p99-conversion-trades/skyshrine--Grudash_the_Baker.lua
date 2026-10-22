-- Converted from sources/projecteq/skyshrine/Grudash_the_Baker.pl
-- Original Perl SHA256: 8a75fe99a53d8054f68a6bb2d93e891c7fa650b6c9fbe308bdcfbb93fee40b27
-- Review: changes/p99-conversion-trades/closure-review.json
-- Partial ambient/refund-only conversion, not an implemented Boysenberry Pie quest.
-- P99 cache says the quest was never implemented and pie references were removed.
-- Omit both pie say branches and signal 1/3 pie responses. Preserve only non-pie closing signal 2.
-- Perl signalwith wait_ms and Lua eq.signal delay are milliseconds: preserve the upstream 1 ms, not 1000 ms.

function event_signal(e)
    if e.signal == 2 then
        e.self:Say("Please ignore my friend Ruru here. He is a bit delusional.")
        eq.signal(114496, 3, 1)
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
