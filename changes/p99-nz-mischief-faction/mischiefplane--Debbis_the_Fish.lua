function event_say(e)
    if e.message:findi("hail") then
        e.self:Emote("sighs. 'If only I could walk in somebody elses shoes just for a day. It's not easy being a skunk you know.'");
    end
end

--Debbis the Fish (NPCID# 126232)
--zone:  mischiefplane

--Quest script to handle turn-in of rabbit foot off Stomples to restore Denizens of Mischief Faction


function event_trade(e)
    local item_lib = require("items");

    if item_lib.check_turn_in(e.trade, {item1 = 6883}) then -- Item: Rabbit Foot
        e.self:QuestSay(e.other,"Oh wow! A rabbits foot!! Thank you so much. Here take this, I won't need this smelly thing any more.");  
		e.other:QuestReward(e.self,0,0,0,0,6876,100);  --  Item: Lucky Skunk Foot
		e.other:Faction(437,51);   -- +51 to Denizens of Mischief Faction
    end

    item_lib.return_items(e.self, e.other, e.trade)
end
