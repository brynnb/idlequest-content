-- Source: freeporteast/Jheron_Felkis.lua
-- P99 audit: Gem Inlaid Gauntlets Quest
-- items: 18508, 18510

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetRaceName() .. ". My name is Jheron Felkis, artificer and friend to all those who seek knowledge of the arcane!")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 18508}) then -- Tesch Val Compilation
		e.self:Say("Ah, yes - the splitpawbook. Umvera sent word that you should be arriving, you certainly made your way here quickly! Very well, then, one moment as I work my magic...")
		e.self:Emote("takes the book from your hand and fiddles about with the spine, whispering odd runes as he does.")
		e.self:Say("Good, good - here you are! Take this back to Umvera, I'm sure he'll be happy to lay eyes on such an item of lore!")
		e.other:SummonItem(18510) -- Pawbook
		e.other:Ding()
		e.other:AddEXP(8000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
