-- Converted from ProjectEQ Perl quest script.
-- Source: cabwest/Jondin.pl
-- items: 17025, 12442, 12443

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings. friend.  I have many fine herbs for sale.  My prices are reasonable for I am not governed by the [Haggle Baron].  If you fancy yourself an adventurer. I would like to hire you for a [simple mission].")
	elseif e.message:findi("haggle baron") then
		e.self:Say("Haggle Baron Klok Dun Ree is the current Haggle Baron. It is written in the law that all services shall be governed by the Haggle Baron. To do business outside of the law is forbidden, but the merchants of the Tower of Death are exempt from this rule. Klok will not test the temper of the Harbinger and Baron Eator will not upset his most powerful ally.")
	elseif e.message:findi("simple mission") then
		e.self:Say("I actually have a few items I am presently low on.  I would appreciate some assistance to [collect fern flowers] or maybe you are an alchemist who can [gather bone chips].")
	elseif e.message:findi("fern flowers") then
		e.self:Say("I have run low on fern flowers and must have more of them.  Take this [flower pouch].  Outside the city can be found carnivorous plants and a strain of them buds the flower in question.  Collect enough of these flowers to fill and combine the pouch and I shall reward you.")
		e.other:SummonItem(17025)
	elseif e.message:findi("bone chips") then
		e.self:Say("I should tell you. I do not need the bone chips. I need bone granite powder. In order to get it, you must find some bone granite pebbles and two piles of bone chips from decaying skeletons. After you gather the items you will have to combine the items and create bone granite powder. The powder is what I need.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12442}) then
		e.self:Say("Excellent!!! You are a fine alchemist. Please accept this as a token of my appreciation.")
		e.other:SummonItem(12443)
		e.other:Faction(443, 5, 0) -- Brood of Kotiz
		e.other:Faction(441, 5, 0) -- Legion of Cabilis
		e.other:AddEXP(500)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
