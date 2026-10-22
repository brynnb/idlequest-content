-- IdleQuest starting guild note turn-in.
-- Source: kaladimb/Datur_Nightseer.pl
-- items: 18768, 13514, 12279, 12281

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to our temple. We are the paladins of the Church of Underfoot. I am lord of our holy order. I call upon you to assist us in the defense of Kaladim. Speak with the master paladins or priests and find ways to prove your allegiance to Brell.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18768}) then
		e.self:Say("Welcome. We are the Paladins of the Underfoot. I am Datur, and I will help teach you the word and will of the Duke of Below, Brell Serilis. Here is our guild tunic.")
		e.other:SummonItem(13514)
		e.other:Faction(227, 100, 0)
		e.other:Faction(274, 100, 0)
		e.other:Faction(293, 75, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12279}) then -- Chalice Case
		e.self:Say("The chalice is returned!! Praise be to Brell!! You have proven yourself to our church and have earned our respect. Let me welcome you into our brotherhood with the Cape of Underfoot. Wear it with pride as all of our finest paladins do.")
		e.other:SummonItem(12281) -- Cape of Underfoot
		e.other:Faction(227, 15, 0) -- Clerics of Underfoot
		e.other:Faction(274, 15, 0) -- Kazon Stormhammer
		e.other:Faction(293, 11, 0) -- Miners Guild 249
		e.other:AddEXP(250)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
