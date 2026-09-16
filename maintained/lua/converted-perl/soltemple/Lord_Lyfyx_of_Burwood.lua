-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/Lord_Lyfyx_of_Burwood.pl
-- items: 10028, 12831, 12952

function event_say(e)
	if e.message:findi("hail") then
		e.self:DoAnim(24)
		e.self:Emote("bows as a courtesy. His face gleams as if tinged with red. 'Greetings, my friend. Welcome to the Temple of Ro, sanctuary to those who follow the words of the Burning Prince.'")
	elseif e.message:findi("scale") then
		e.self:Say("Tektite and peridot shall get you what you desire.")
	elseif e.message:findi("xyfyl") then
		e.self:Say("So you can pronounce my name backwards.. Is that your lot in life? Pronouncing names backwards? Be gone with your silliness! We need no court fool.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10028, item2 = 12831}) then
		e.self:Emote("places the gems inside an ornate metal box. He begins to tug at his skin. Your vision blurs as he performs his magic. 'This is what you seek. Now leave and bother me no further.'")
		e.other:Faction(415, 15, 0)
		e.other:Faction(416, -15, 0)
		e.other:SummonItem(12952)
		e.other:AddEXP(50000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
