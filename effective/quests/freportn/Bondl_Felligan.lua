-- IdleQuest movement-independent quest sequence; see GitHub issue #29.
-- Source: freportn/Bondl_Felligan.lua (ProjectEQ); original dialogue/rewards/timer intervals retained except travel directions.
-- items: 1665
function event_say(e)
	if(e.message:findi("hail")) then -- Part of Shaman Epic 1.0
		e.self:Emote("burps loudly in your face and says, 'Bah! Leave me be, fool! You have nothin' I want and I certainly have nothin' you want.");
	elseif(e.message:findi("you can buy booze")) then -- Part of Shaman Epic 1.0
		e.self:Emote("suddenly becomes completely sober and says, 'Very well, shaman, please come with me.'");
		-- IdleQuest: keep the guide destination, without a patrol prerequisite (issue #29).
		e.self:Say("Meet the greater spirits upstairs in the Jade Tiger Den. They are waiting in the rooms near location 66, 62.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 1665})) then -- Part of Shaman Epic 1.0
		e.self:Say("WOW, thanks! This must be worth a fortune! I could drink for a month after sellin' this to one of them fool merchants. I'm going to see how much I can get for it right now!");
		e.other:Faction(404,100,0); -- Faction: Truespirit
		e.other:AddEXP(1000);
		eq.spawn2(8117,0,0,62,66,32.1,508); -- NPC: a_greater_spirit
		eq.spawn2(8118,0,0,67,103,32.1,508); -- needs_heading_validation
		e.self:Say("What!? You don't approve of me buyin' some drinks with this gem? Who the heck are you to offer me a gift and order me what to do with it? Is this some kinda conditional kindness? Well? Are you gonna let me buy some booze with this or not?");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

-- EOF Bondl_Felligan
