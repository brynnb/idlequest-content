-- Modified from ProjectEQ Lua.
-- Source: rivervale/Shakey_Scarecrow.lua
-- P99 audit: Shakey the Scarecrow's Head, Shakey's Stuffing
-- Classic/Kunark-only override: preserve classic Shakey dialogue/stuffing,
-- omit the later rogue head branch.
-- items: 14321, 13980, 14031

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Emote("rustles and looks up at you in acknowledgment.");
		eq.signal(19052, 0); -- Reebo_Leafsway
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 14321})) then -- Sack of Writhing Hay
		e.other:SummonItem(eq.ChooseRandom(13980, 13980, 14031)); -- Wee Harvester / Belt of the River
		e.other:Ding();
		e.other:AddEXP(500);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
