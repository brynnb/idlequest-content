-- items: 10019, 10070, 10021
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Leave me alone.");
	elseif(e.message:findi("paw of opolla")) then
		e.self:Say("What was that? The Paw of Opolla? Hmm... I might have heard of it.. But my information is valuable. I am a seeker of gems. I might offer up what I know if you were to give me three fine [jewels].");
	elseif(e.message:findi("jewels")) then
		e.self:Say("I require three jewels; a Bloodstone , a Moonstone , and a Star Rose Quartz. Only then will I tell you what I know of the rare and powerful Paw of Opolla.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 10019,item2 = 10070,item3 = 10021})) then
		e.self:Say("Yes. Good. You have done well. Let's see, the Paw of Opolla was it? Yes..Opolla was once a great shaman to the Gnolls of Blackburrow. It is said she wore four enchanted rings of power. She offered her hand in peace to the first hordes of humans pouring down from the Everfrost Peaks, only to have it lopped off at the wrist by a warrior named Gynok Moltor. If you seek the Paw, seek out the [descendent of Gynok].");
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
