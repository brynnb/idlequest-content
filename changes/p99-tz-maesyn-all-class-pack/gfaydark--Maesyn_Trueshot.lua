-- IdleQuest starting guild note turn-in plus P99 Trueshot Longbow.
-- Source: gfaydark/Maesyn_Trueshot.pl
-- P99 audit: Trueshot Longbow Quest
-- items: 17951, 12112, 8091, 18785, 13536

function event_spawn(e)
	local xloc = e.self:GetX()
	local yloc = e.self:GetY()
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50)
end

function event_enter(e)
	if e.other:HasItem(18785) then
		e.other:Message(MT.Yellow, "Maesyn Trueshot strings his bow as you orient yourself amongst the treetop city of Kelethin. 'Greetings, young recruit. Should you wish to learn the ways of the Ranger, read the note in your inventory and hand it to me when you are ready to begin your training.'")
	end
end

function event_say(e)
	local fac = e.other:GetFaction(e.self)

	if e.message:findi("hail") then
		e.self:Say("Welcome to Kelethin, " .. e.other:GetName() .. "! I am Maesyn Trueshot, commander of Faydark's Champions. We are the finest marksmen in all of Norrath. With our trusty [Trueshot longbows] we can miss no target regardless of the distance or the conditions.")
	elseif e.message:findi("trueshot longbows") then
		e.self:Say("The Trueshot Longbow was created by my famed father, Eldin Trueshot. It is quite accurate and takes a ranger's skill to wield. We use our new recruits to [gather materials] needed by my father. We shall soon begin to release the formula to good elves so all may fletch such a bow.")
	elseif e.message:findi("gather materials") then
		if fac < 4 then
			e.self:Say("Take this pack. Go to Kaladim, find Trantor Everhot and ask for dwarven wire. Then go to Freeport to meet Jyle Windshot. Search the inns for him and ask him for treant wood. Then, collect some spiderling silk from spiderlings and finally, in Steamfont, we have the permission of the gnomes to use any micro servos we find while destroying rogue spiders. Combine them all and return the pack to me.")
			e.other:SummonItem(17951) -- Material Pack
		else
			e.self:Say("Faydark's Champions cannot call you foe, but you have yet to earn our trust.")
		end
	elseif e.message:findi("correct components") then
		e.self:Say("Now that I have crafted the Treant Bow Staff, you shall need one Planing Tool, one Treant Bow Staff, one Micro Servo and one spool of Dwarven Wire. These items will be used with your Fletching Kit as all other bows. Be forewarned, only a Master Fletcher can create such a bow and even a master fails from time to time. Good Luck.")
	elseif e.message:findi("next incarnation") then
		e.self:Say("The Trueshot Longbow was once enchanted by the Koada'Dal enchanters. Once it was enchanted now it is no more. I am sure if you were to ask the Koada'Dal [where the enchanted bows] are you will get an answer.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12112}) then
		e.self:Say("I shall see that my father gets the materials. I hope this can be of use to you. It will serve as your starting point toward fletching a Trueshot longbow. It is unfortunate that we are unable to enchant the bow to its [next incarnation], but it is still a fine weapon. You do know the [correct components] needed for fletching such a bow, do you not?")
		e.other:GiveCash(0, 0, 6, 0)
		e.other:SummonItem(8091) -- Treant Bow Staff
		e.other:Faction(246, 10, 0) -- Faydark's Champions
		e.other:Faction(279, 10, 0) -- King Tearis Thex
		e.other:Faction(226, 10, 0) -- Clerics of Tunare
		e.other:Faction(310, 10, 0) -- Soldiers of Tunare
		e.other:Faction(234, -10, 0) -- Crushbone Orcs
		e.other:AddEXP(1000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 18785}) then
		e.self:Say("Hail, " .. e.other:GetName() .. ", and welcome. I am Maesyn Trueshot, leader of Faydark's Champions. I will teach and train you. Here, put this on; it'll help protect you from the elements.")
		e.other:SummonItem(13536)
		e.other:AddEXP(100)
		e.other:Faction(246, 100, 0)
		e.other:Faction(279, 25, 0)
		e.other:Faction(226, 25, 0)
		e.other:Faction(310, 25, 0)
		e.other:Faction(234, -25, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
