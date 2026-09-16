-- Converted from ProjectEQ Perl quest script.
-- Source: cabwest/an_Iksar_hermit.pl
-- items: 17195, 12886, 4266, 4267

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am looking for a [great sorcerer]. Are you such a person?")
	elseif e.message:findi("great sorcerer") and e.other:HasItem(4266) and e.other:GetLevel() >= 35 then
		e.self:Say("Are we now? Well then take this. See if you can finish this project that I started so many years ago. It still requires a [whip], a [tassel], and a [lock]. Go and find these items and return to me with what you have already learned and I shall reward you.")
		e.other:SummonItem(17195)
	elseif e.message:findi("whip") then
		e.self:Say("Many years ago in Dreadlans a drovarg came and ravaged my camp and stole a whip that was given to me by my master. With the loss of the whip I became an outcast to the dark arts.")
	elseif e.message:findi("tassel") then
		e.self:Say("You should find a large ghostly tassel, I was on my way to Kaesora to learn about this tassel but my age has hindered this adventure. You should go there and see what you can find.")
	elseif e.message:findi("lock") then
		e.self:Say("Only a goblins hair is strong enough to hold this together. Go and slay them till you find a lock of hair strong enough for this.")
	else
		e.self:Say("You have many more deeds yet to accomplish.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12886, item2 = 4266}) then
		e.self:Emote("takes the flail and vanishes with a brilliant flash!! Within your hands appears a skullcap. You hear a voice echo through the cave. Well done. You are a formidable necromancer. We thank you.")
		eq.depop_with_timer()
		e.other:SummonItem(4267)
		e.other:Faction(441, 20, 0)
		e.other:Faction(443, 20, 0)
		e.other:AddEXP(10000)
	else
		e.self:Say("All is not complete. A cap and the rest, which was asked for, is required.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
