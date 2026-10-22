-- P99 scope: preserve merchant hail/animation; remove later BoneMail shield exchange.
function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Furrier Royale. Here you will find the finest skins from a variety of Norraths lesser creatures.")
		e.self:DoAnim(67)
	end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
