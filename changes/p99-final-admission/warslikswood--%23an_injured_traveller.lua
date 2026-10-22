-- enabled: false
-- P99 source-only scope exclusion: later_beastlord_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: warslikswood/#an_injured_traveller.pl
-- items: 12463, 8175, 48051

function event_say(e)
	if e.message:findi("ixthal sent me") then
		e.self:Say("Oh, has he now? I can't return yet, I don't have the strength. If you were to [help] me I think I might be able to make it back though.")
	elseif e.message:findi("help") then
		e.self:Say("Good. I have not eaten in a while so I will ask you to get me some Legion Lager and Noodles for my journey back.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12463, item2 = 8175}) then
		e.self:Say("You have returned with what I asked for. Here, take this note back to Ixthal and let him know I am safe and will be making the return trip soon.")
		e.other:SummonItem(48051)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
