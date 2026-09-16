-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Keletha_Nightweaver.pl
-- items: 1774, 1775

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ". Interested in the art of research? I have several tomes which may aid you in such a pursuit.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1774}) then
		e.self:Emote("takes the note, dumps the dust into her hand and examines it for a moment. She looks up and chuckles")
		e.self:Say("It's amuzing how one of our Royal Guards cannot identify this substance. Do you feel how it's slightly cooler than other metals? It's called Permafrost Iron, also known as Cold Iron to laymen. Miragul wrote of it's properties in his memoirs. There are much better metals at our disposal now, so it's use is rare except in more primitive cultures. Here is my report.")
		e.other:AddEXP(137180)
		e.other:SummonItem(1775)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
