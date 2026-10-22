-- Converted from ProjectEQ Perl quest script.
-- Source: everfrost/Granin_O'Gill.pl
-- name: Granin_O'Gill
-- items: 13005

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Brrr... Good to meet another upon this wasteland.  You would not by any chance have any iron rations on you, would you?  If so, I shall heal you in trade.  I am in need of provisions.")
	end
end

function event_aggro(e)
	e.self:Say("Great Tribunal, help me smite this foe!")
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
		e.self:Say("Great Tribunal... Give me strength to bind this good person's wounds.")
		e.self:CastSpell(200, e.other:GetID()) -- Minor Healing
	end
	-- IdleQuest safety: return unrelated items; preserve the ration/healing branch.
	item_lib.return_items(e.self, e.other, e.trade)
end

