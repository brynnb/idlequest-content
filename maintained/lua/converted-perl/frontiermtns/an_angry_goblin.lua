-- Converted from ProjectEQ Perl quest script.
-- Source: frontiermtns/an_angry_goblin.pl
-- items: 6474

local function has_bathezid_global(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["RegalBandBathezid"] == "1" or qglobals["RegalBandBathezid"] == 1
end

function event_say(e)
	if has_bathezid_global(e) and e.message:findi("hail") then
		e.self:Say("'Go away, my life is miserable enough!' The angry goblin looks at you more closely, his rage fading for a moment. 'Are you here with the evidence I was promised? Give it to me if you have it.'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if has_bathezid_global(e) and item_lib.check_turn_in(e.trade, {item1 = 6474}) then
		e.self:Emote("howls in triumph! 'This is just what I needed! Skargus is mine now, wait until he finds out, just wait! His death is close at hand. Follow me and I'll take you to Skargus's chamber, you can wait there while I take this report to the chief!'")
		e.self:Shout("I have you now Skargus, you traitor! Even now I'm taking this report of slave-trading to the chief! Your days here are at an end!")
		eq.depop_with_timer()
		eq.unique_spawn(92185, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
