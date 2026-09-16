-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Coriante_Verisue.pl
-- items: 18018, 13551, 13068, 13067, 15338, 15342

function event_spawn(e)
	local xloc = e.self:GetX()
	local yloc = e.self:GetY()
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50)
end

function event_enter(e)
	if e.other:HasItem(18018) then
		e.other:Message(MT.Yellow, "The cold voice of a female echoes in your mind, 'Come to me, young Necromancer. I am Coriante Verisue. Read the note in your inventory and hand it to me so that you may begin on the path of the Necromancer. True power can be yours should you have the will to train in the necromantic arts.'")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, young one! There are many tasks to be performed aside from your studies to truly harness the powers passed down to us by our ancestor [Miragul]. The most basic of these tasks is the gathering of bat wings and snake fangs from the yard outside our city. I will reward you for every two bat wings and two snake fangs you bring to me.")
	elseif e.message:findi("miragul") then
		e.self:Say("You do not know of Miragul?!! You have more to learn of the heritage of the Dark Truth than at first I thought. Miragul was the first High Man to unlock the secrets of necromancy and is the founder of our city as well as the creator of the treacherous Hole.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18018}) then -- Dark Truth Guild Note
		e.self:Say("You are welcomed into the fold. Now go out, and prove yourself, young one. You have much to learn about the Dark Truth.")
		e.other:SummonItem(13551) -- Dirt Soiled Robe*
		e.other:Ding()
		e.other:Faction(265, 100, 0) -- Heretics
		e.other:Faction(242, -100, 0) -- Deepwater Knights
		e.other:Faction(254, -100, 0) -- Gate Callers
		e.other:Faction(231, -100, 0) -- Craftkeepers
		e.other:Faction(233, -100, 0) -- Crimson Hands
		e.other:AddEXP(100)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13068, item2 = 13068, item3 = 13067, item4 = 13067}) then -- Bat Wing x 2, Snake Fang x 2
		e.self:Say("Very good, young acolyte. Maintain your diligence in your duties and you will quickly learn the secrets of the Dark Truth.")
		e.other:SummonItem(eq.ChooseRandom(15338, 15342)) -- P99: Spell: Cavorting Bones or Spell: Locate Corpse
		e.other:Faction(265, 1, 0) -- Heretics
		e.other:Faction(231, -1, 0) -- Craftkeepers
		e.other:Faction(233, -1, 0) -- Crimson Hands
		e.other:Faction(242, -1, 0) -- Deepwater Knights
		e.other:Faction(254, -1, 0) -- Gate Callers
		e.other:AddEXP(100)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
