-- Second part of the chardok quest, initiated by Herald Telcha
-- Regal Band of Bathezid
-- global RegalBandBathezid, needed to be sure players won't jump to the last part of the quest
--   at 1 : you gave the Signet of Service to the goblin traitor
function event_spawn(e)
	e.self:Say("I've gotta stop Gragbar before he turns in that report!");
	eq.set_timer("depop",600000);
end

function event_timer(e)
	if e.timer == "depop" then
		eq.stop_timer("depop");
		eq.depop();
	end
end

function event_trade(e)
	local item_lib = require("items");
	item_lib.return_items(e.self, e.other, e.trade)
end
