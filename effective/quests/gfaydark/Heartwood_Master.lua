-- IdleQuest starting guild note turn-in plus P99 Classic/Kunark quest alignment.
-- Source: gfaydark/Heartwood_Master.pl
-- P99: https://wiki.project1999.com/Bladed_Weapons
-- items: 18786, 13537, 5013, 5016, 5019, 5022, 5047, 6012

function event_spawn(e)
	local xloc = e.self:GetX()
	local yloc = e.self:GetY()
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50)
end

function event_enter(e)
	if e.other:HasItem(18786) then
		e.other:Message(MT.Yellow, "As you orient yourself amongst the peacefulness of the treetop city of Kelethin, a melodic, peaceful voice breaks the silence. 'I am the Heartwood Master. Read the note in your inventory and when you wish to begin your training, hand it to me. We must pledge our lives to protect the great forest, Faydark against all those who would wish it harm!'")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome! We are the Soldiers of Tunare, the sworn protectors of Faydark. Through the magic of Tunare we care for the land and with blade, staff and spell we protect the Faydark against those who would destroy and despoil it. We are always grateful for any assistance to our cause. Perhaps you could help me with some simple [errands].")
	elseif e.message:findi("errands") or e.message:findi("short sword") or e.message:findi("long sword") or e.message:findi("broad sword") or e.message:findi("bastard sword") then
		e.self:Say("As druids of the Mother of All, we may only use the scimitar and blunt weapons, all other blades are forbidden. Prove your devotion by bringing me a rusty short sword, long sword, broad sword, and bastard sword. I will destroy them and reward you for your faith. They will be reforged into weapons blessed by Tunare to assist the Soldiers in their defense of the Heartwood.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18786}) then
		e.self:Say("Welcome! We are the Soldiers of Tunare, the sworn protectors of Faydark. I thank you for joining our cause, we can always use the help. Here, put on this tunic, and let's get started.. you have much to learn.")
		e.other:SummonItem(13537)
		e.other:AddEXP(100)
		e.other:Faction(310, 100, 0)
		e.other:Faction(279, 15, 0)
		e.other:Faction(246, 15, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 5013, item2 = 5016, item3 = 5019, item4 = 5022}) then
		e.self:Say("You have done well, child! Take these as a blessing from Tunare for doing her will.")
		e.other:SummonItem(eq.ChooseRandom(5047, 6012))
		e.other:AddEXP(250)
		e.other:Faction(310, 1, 0)
		e.other:Faction(279, 1, 0)
		e.other:Faction(246, 1, 0)
		e.other:GiveCash(0, 0, 6, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
