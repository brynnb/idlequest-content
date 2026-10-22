-- enabled: false
function event_signal(e)
	e.self:Say("Ooh yeah! So would I, honey.");
	eq.signal(1066,1); -- NPC: Danaria_Hollin
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say(string.format("Hello %s! Welcome to our humble little bakery. We just got a fresh shipment of supplies in, have a look around!",e.other:GetName()));
	end
end

function event_trade(e)
	local item_lib =require("items");
	-- P99 end-timeline final hand-in survives removed start dialogue.
	if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
		e.self:Say("Hey, thanks kid! You are one top notch baker! Here's some coin for your trouble.")
		e.other:GiveCash(0, 0, 7, 0)
		e.other:Faction(291, 2, 0) -- Merchants of Qeynos
		e.other:Faction(223, -1, 0) -- Circle of Unseen Hands
		e.other:Faction(219, 1, 0) -- Antonius Bayle
		e.other:Faction(229, 1, 0) -- Coalition of Tradefolk
		e.other:Faction(262, 1, 0) -- Guards of Qeynos
		-- Partial restoration: XP magnitude absent from retained source/P99 evidence.
		-- No guessed XP reward; this is not a fully matched completion branch.
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
