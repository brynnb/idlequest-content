-- IdleQuest movement-independent quest sequence; see GitHub issue #29.
-- Source: erudsxing/Ooglyn.lua (ProjectEQ); original dialogue/rewards/timer intervals retained except travel directions.
-- items: 1666
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Ooooh, it you, " .. e.other:GetName() .. ". Me's been waitin for you cuz our frenz say you comin an need da test. So's I gib you da test. Hmm, now where me put it? Ooglyn been waiting for sign for so long dat me forget where me put test. Keep your eyes out for sign while me look for test. Oh, hey, " .. e.other:GetName() .. " , they gib you gem? I need dat gem, please, heheh.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 1666})) then -- Part of Shaman Epic 1.0
		e.self:Say("Ahhh, tank you, now me can...OH LOOK!! DA SIGN!!!! Oh, sorry you missed it. The sign show you where to wait for da test. Go to da bottom of da ocean at location -1600, 4200. Wait dere for da test; me friends will come to you, " .. e.other:GetName() .. "!");
		e.other:Ding();
		e.other:Faction(404,50,0); -- Faction: Truespirit
		e.other:AddEXP(1000);
		e.self:Say("Go to da waiting place, shaman. Stay dere even if others ask you to leave.");
		-- Start the existing delay at hand-in, independent of route arrival.
		eq.set_timer("depop",360000);
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

function event_timer(e)
	if e.timer ~= "depop" then return end
	eq.stop_timer("depop");
	eq.spawn2(98046,0,0,4209.4,-1575.5,-289.4,362); -- NPC: Srafen_the_Soaked
	eq.depop_with_timer();
end

-- Ooglyn
