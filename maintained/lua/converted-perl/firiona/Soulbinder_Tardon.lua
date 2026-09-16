-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Soulbinder_Tardon.pl

function event_say(e)
	plugin.soulbinder_say(e.message)
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
