-- Converted from ProjectEQ Perl quest script.
-- Source: warslikswood/a_shady_goblin.pl
-- items: 6475, 6471, 6474

local function has_bathezid_global(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["RegalBandBathezid"] == "1" or qglobals["RegalBandBathezid"] == 1
end

function event_say(e)
	if not has_bathezid_global(e) then
		return
	end

	if e.message:findi("hail") then
		e.self:Say("If yer not my contact ya best be movin' on. Got no time to waste on ya.")
	elseif e.message:findi("I am your contact") then
		e.self:Say("Are ya? Hum, let me see yer insignia then, and the note Skargus gave ya.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if has_bathezid_global(e) and item_lib.check_turn_in(e.trade, {item1 = 6475, item2 = 6471}) then
		e.self:Emote("gapes at the note in puzzlement, obviously a bit concerned by it. The courier looks at the note for more than a minute, then looks at you, and back at the note.")
		e.self:Say("Errm.. welp, dunno what to make of the note. If I know the right of it, Skargus finally got him some girly to do his writin' for him. Ooooh I bet she's a tasty one, graarr. If I was warlord I know I'd have me a girly too. Gah, take this report and get outta my sight.")
		e.other:SummonItem(6474)
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
