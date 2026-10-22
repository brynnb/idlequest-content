-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Seloxia_Punox.pl
-- P99 audit: Teir`Dal Courier
-- items: 18842, 18751, 13580, 18843, 5026

function event_spawn(e)
	local xloc = e.self:GetX()
	local yloc = e.self:GetY()
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50)
end

function event_enter(e)
	if e.other:HasItem(18751) then
		e.other:Message(MT.Yellow, "The cold voice of a female fills your mind with dread, 'I am Seloxia Punox. Seek me out in the Cauldron of Hate and hand me our note so that you may begin on the path of the Warrior. True power can be yours should you have the will to train hard enough!'")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("eyes flare with fury as her beautiful features twist into a snarl of hatred that echoes her hissing voice, 'How dare you address me in such a fashion?! I am the leader of the Indigo Brotherhood! You are lucky I do not strike you down where you stand! You shall address me as 'Mistress.' Many warriors have died so that I might gain this title.'")
	elseif e.message:findi("mistress") then
		e.self:Emote("maintains her imposing posture as she indifferently eyes " .. e.other:GetName() .. ", 'You stand now in the Cauldron of Hate -- the Indigo Brotherhood. We are an organization of Neriak's finest warriors whom remain dedicated to Neriak, the Dark Father, and our founder -- his majesty, King Naythox Thex. I am Seloxia Punox, second to only his majesty in command of the Brotherhood. From the Cauldron of Hate, we maintain the protection of the city both within our city walls and beyond in the forest of Nektulos. Perhaps you would wish to prove yourself worthy of our ranks and perform a [little test] of your skills and dedication?'")
	elseif e.message:findi("little test") then
		e.self:Say("My little test is this - I desire a report from Ambassador K'rynn in the ogre city of Oggok. You shall run to him. I will not wait until you raise your fighting skills. Combat is not your test. Overcoming the odds is. Fast, agile warriors are we. We desire nothing less. Will you [venture to Oggok]?")
	elseif e.message:findi("venture to oggok") then
		e.self:Say("Then you must go at once. Find your own way. Deliver this note to Ambassador K'rynn and he shall give you another note to return to me. Do not stop to practice your skills. I offer this test only to young warriors. If you die, then so be it. We need no inferior warriors. Now go!")
		e.other:SummonItem(18842) -- Sealed Letter, Letter To Krynn
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18751}) then
		e.self:Say("Welcome to the Indigo Brotherhood. Hmmm, you're a bit scrawny, but we'll work with it. Here's your guild tunic. Defend Neriak and all her allies.")
		e.other:SummonItem(13580)
		e.other:AddEXP(100)
		e.other:Faction(270, 100, 0)
		e.other:Faction(326, -15, 0)
		e.other:Faction(311, -5, 0)
		e.other:Faction(1522, -200, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 18843}) then
		e.self:Say("Very fine work, my young warrior. You may soon be ready to become a Teir'Dal courier. For now, we shall reward you. This will assist you in further service to the Indigo Brotherhood and King Naythox Thex.")
		e.other:SummonItem(5026) -- Bronze Short Sword
		e.other:AddEXP(250)
		e.other:Faction(270, 10, 0) -- Indigo Brotherhood
		e.other:Faction(326, -1, 0) -- Emerald Warriors
		e.other:Faction(311, -1, 0) -- Steel Warriors
		e.other:Faction(1522, -20, 0) -- Primordial Malice
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
