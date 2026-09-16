-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Elisabeth.pl
-- items: 12313, 12303

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Very good to meet you, " .. e.other:GetName() .. ". I am the keeper of the [Greaves of Ro]. Please feel free to rest and recuperate here. We shall see that you are safe from the evils of the Rathe Mountains.")
	elseif e.other:GetModCharacterFactionLevel(281) < 25 then
		e.self:Say("In the name of the Knights of Truth, I must ask you to venture to Freeport and enter the Hall of Thruth. There you are to find Theron Rolius, and ask of him, am [I an honored member]?")
	elseif e.message:findi("greaves of ro") then
		e.self:Say("Go to the countryside of Freeport. There, you shall seek out any nightfall giants. They have terrorized the countryside for too long. They have protection from common weapons. Rely on magic. I failed in tracking them down. You shall succeed and when return any single head to me. you shall be awarded the mold for the greaves.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:GetModCharacterFactionLevel(281) > 24 and item_lib.check_turn_in(e.trade, {item1 = 12313}) then
		e.self:Say("You have done well. These giants shall soon be purged from the Commonlands and the inns will be filled once again. Here is the mold for the Ro Greaves. For the final component, go and ask Thomas of [Lord Searfire].")
		e.other:SummonItem(12303)
		e.other:Faction(281, 20, 0)
		e.other:Faction(362, 4, 0)
		e.other:Faction(311, 2, 0)
		e.other:Faction(271, -3, 0)
		e.other:Faction(330, -3, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
