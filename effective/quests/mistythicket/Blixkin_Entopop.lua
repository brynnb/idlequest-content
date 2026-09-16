-- Converted from ProjectEQ Perl quest script.
-- Source: mistythicket/Blixkin_Entopop.pl
-- P99 audit: Terrorantula Quest / Bug Collection
-- items: 17922, 18011, 13268, 14010, 13281, 13280, 14015, 16875

function event_waypoint_arrive(e)
	if e.wp == 2 or e.wp == 9 or e.wp == 14 or e.wp == 21 or e.wp == 24 then
		e.self:Say("Ember?!  Ember?!  Where are you, girl?!")
		eq.signal(33065, 1)
	end
end

function event_signal(e)
	e.self:Say("There you are!  Stay close to me, girl.")
end

function event_combat(e)
	e.self:Say("What do you think you are doing?!?")
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetName() .. "! My name is Blixkin Entopop. Have you seen the wonderful assortment of [spiders] and [beetles] that inhabit the thicket? I have quite an extensive [bug collection]. Be careful, though. I have seen many brave halflings fall beneath a [swarm] of clicking and hissing bugs.")
	elseif e.message:findi("spiders") then
		e.self:Say("There are many species of bugs out here. The most common are the fire beetles. If you are hunting them, make sure their queen is not around or you will be in deep trouble. Their eyes are a popular item for adventurers because they give off light as if they were on fire. I even had one warrior try to kill [Ember] for her eyes!!")
	elseif e.message:findi("ember") then
		e.self:Say("I raised Ember from an egg. She is my faithful pet and quite smart for a beetle. There are plenty of other bugs to squish, out in the thicket, so you had best leave her alone or I will have to SQUISH you!")
	elseif e.message:findi("swarms") then
		e.self:Say("Bugs tend to swarm and defend others of their species when they are attacked. So keep your eyes peeled if you intend to squish any of them.. And you'd better not even THINK of squishing [Ember] or you will be sorry!")
	elseif e.message:findi("beetles") then
		e.self:Say("There are many species of bugs out here. The most common are the fire beetles. If you are hunting them, make sure their queen is not around or you will be in deep trouble. Their eyes are a popular item for adventurers because they give off light as if they were on fire. I even had one warrior try to kill [Ember] for her eyes!!")
	elseif e.message:findi("don't have a bug collection box") or e.message:findi("dont have a bug collection box") then
		e.self:Say("Here you go. Just follow the instructions on the [list] so you know what to collect and how to prepare the collection for me.")
		e.other:SummonItem(17922)
	elseif e.message:findi("collection") then
		e.self:Say("I collect all kinds of bugs but most of the ones I have are dead. Ember is the only exception. I just like them for their pretty colors and I kind of admire how loyal they are to each other. If you want to, you can help me fill out my collection and I will reward you for your time. Here is a list of the bug parts I need for my collection. If you [don't have a bug collection box] to collect the bug parts, just ask me for one. I think I have some extras.")
		e.other:SummonItem(18011)
	elseif e.message:findi("list") then
		e.self:Say("What did you do, lose the list? Here is another one. Hold onto it because I will want it back when you are done.")
		e.other:SummonItem(18011)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13268, item2 = 18011}) then
		e.self:Say("Excellent! Good work! I knew you were the one for this job! Thank you so much! My collection just gets better and better each day. Here is your reward as I promised.")
		e.other:SummonItem(eq.ChooseRandom(14010, 13281, 13280, 14015, 16875))
		e.other:Faction(292, 12, 0)
		e.other:Faction(241, 12, 0)
		e.other:Faction(263, 12, 0)
		e.other:Faction(286, 12, 0)
		e.other:Faction(5015, -15, 0)
		e.other:AddEXP(65)
		e.other:GiveCash(0, 8, 3, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
