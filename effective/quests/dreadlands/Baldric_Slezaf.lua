-- Source: dreadlands/Baldric_Slezaf.pl
-- Bard Epic 1.0: Baldric Slezaf grants Singing Short Sword.
-- Converted from ProjectEQ Perl quest script.
-- items: 20376, 20383, 20377, 20538, 20542

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ". Don't you think this would be a wonderful place to perform a symphony?")
	elseif e.message:findi("symphony") then
		e.self:Say("It has been my dream for years to perform a symphony that would be remembered for ages to come. I have run into a few minor snags, however.")
	elseif e.message:findi("minor snags") then
		e.self:Say("Several years ago I bought sheets of the most beautiful sounding music from a traveling merchant. However, as I reached the middle of the music, I discovered it was missing two pages!")
	elseif e.message:findi("missing two pages") then
		e.self:Say("The pages that were missing were pages 24 and 25. Without the music and a new lute crafted by Forpar Fizfla, I do not think I can pull it off.")
	elseif e.message:findi("lute") then
		e.self:Say("Forpar Fizfla is an eccentric instrument maker from Ak'Anon. He makes enchanted instruments that enhance the sound of the music.")
	elseif e.message:findi("music") then
		e.self:Say("It makes me sad to know that the pages of this music may be spread across the world or destroyed. If you find and bring me the two missing sheets as well as a new lute, I would be happy to repay you in some way.")
	elseif e.message:findi("repay") then
		e.self:Emote("pulls a fantastic looking sword from its scabbard.")
		e.self:Say("I might be willing to part with this wonderful sword if I were able to perform this symphony.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20376, item2 = 20383, item3 = 20377, item4 = 20538}) then
		e.self:Emote("looks shocked as you hand him the pages and the mystical lute.")
		e.other:SummonItem(20542) -- Singing Short Sword
		e.other:AddEXP(350000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
