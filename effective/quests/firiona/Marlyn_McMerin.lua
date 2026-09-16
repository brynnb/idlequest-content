-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Marlyn_McMerin.pl
-- items: 12942, 12945, 12944, 12943, 12941

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings hearty adventurer. Searching for the components necessary for fine shaman spells are we? I have come to Kunark in search of [rare alchemy components], but I have found the dangers of Kunark are far too great for me.")
	elseif e.message:findi("rare alchemy components") then
		e.self:Say("Grand!! I have heard word of [four rare components]. Collect them for me and I will share with you a rare scroll of [McMerin's Feast].")
	elseif e.message:findi("mcmerin") then
		e.self:Say("Clan McMerin are wise shamans from the North. The secret of McMerin's Feast won't be understandable unless you're a shaman, but you can always pass it on to one.")
	elseif e.message:findi("four rare components") then
		e.self:Say("From the lands of Kunark we require some clay of Ghiosk, crushed dread diamond and some powder of a Yun shaman. The rarest component is the bones of one who touched the Bath of Obulus. Find these things, return them to me and the secret of [McMerin's Feast] is yours.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12942, item2 = 12945, item3 = 12944, item4 = 12943}) then
		e.self:Say("Incredible!! You have done well. I reward you with a spell which has been kept in my clan. I offer its secrets to one I now consider family.")
		e.other:AddEXP(45000)
		e.other:Faction(1022, 10, 0) -- Firiona Vie
		e.other:Faction(326, 10, 0) -- Emerald Warriors
		e.other:Faction(312, 10, 0) -- Storm Guard
		e.other:Faction(441, -10, 0) -- Legion of Cabilis
		e.other:Faction(313, -10, 0) -- Pirates of Gunthak
		e.other:SummonItem(12941)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
