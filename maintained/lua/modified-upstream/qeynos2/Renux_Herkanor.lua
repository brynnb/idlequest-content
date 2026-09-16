-- Source: qeynos2/Renux_Herkanor.lua
-- P99 audit: Package from Lomarc
-- items: 18793, 13716

function event_say(e)
	-- P99 Rogue Epic Quest side conversation; preserve her separate package quest.
	if e.message:findi("hail") then
		e.self:Say("You need something, or are you just browsing?")
	elseif e.message:findi("stanos") then
		e.self:Say("What? (she looks shaken) I see it is time to make my choices. Forget you mentioned that name, " .. e.other:GetName() .. ". Leave me.")
	elseif e.message:findi("lomarc") then
		e.self:Say("Lomarc? He's a small time smuggler who runs from here to Odus. He got sloppy this last run, and now the guards are onto him. We need to have someone [meet him behind the Mermaid's Lure] tonight to pick up a package.")
	elseif e.message:findi("meet him behind the mermaid") or e.message:findi("meet lomarc") then
		e.self:Say("Hmm, you think you can handle it? Eh, Lomarc is nothing but a two-bit smuggler anyways. Take this payment to him for the package, and don't let him give you any grief. Got it?")
		e.other:SummonItem(18793) -- Lomarc's Payment
	elseif e.message:findi("mermaid") then
		e.self:Say("The Mermaid's Lure is down by the Qeynos docks. Lomarc is laying low behind it tonight.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 13716}) then
		e.self:Say("Yes, I see you aim to please. I hope you gave Lomarc the payment that he deserved? Heh, that punk had no idea of the value of this shipment. The emerald inside this doll will fetch a pretty penny from those greedy merchants.")
		e.other:Ding()
		e.other:Faction(223, 10, 0) -- Circle of Unseen Hands
		e.other:Faction(291, -10, 0) -- Merchants of Qeynos
		e.other:Faction(230, 10, 0) -- Corrupt Qeynos Guards
		e.other:Faction(262, -10, 0) -- Guards of Qeynos
		e.other:Faction(273, 10, 0) -- Kane Bayle
		e.other:AddEXP(500)
	end

	item_lib.return_items(e.self, e.other, e.trade)
end

function event_waypoint_arrive(e)
	if e.wp == 3 then
		e.self:Say("When is Lomarc getting back from Odus? He was supposed to be back three nights ago. Have you heard anything?")
		eq.signal(2074, 3) -- Hanns Krieghor
	elseif e.wp == 4 then
		e.self:Say("Hanns, you are not going to want to hear this, but one of our boys in Donovan's gang swears he saw Stanos in the Karanas a week ago. And we still haven't cornered Malka Rale.")
		eq.signal(2074, 4) -- Hanns Krieghor
	end
end

function event_signal(e)
	if e.signal == 1 then
		e.self:Say("Ok, I'll send someone out to meet [Lomarc] behind the [Mermaid's Lure] tonight.")
	elseif e.signal == 2 then
		e.self:Say("Very well, Father is as good as dead. Did I ever mention that I really hate family reunions? <chuckle>. I am gone!")
	end
end
