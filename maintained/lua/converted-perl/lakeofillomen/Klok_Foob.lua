-- enabled: false
-- P99 exclusion: see content_exclusions.json quests["lakeofillomen/Klok_Foob"].
-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Klok_Foob.pl
-- items: 12451, 12448

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Buy, buy, buy. Go ahead, make a purchase. I am not here to talk. Go to Cabilis for talk. Come to Foob for armor. Now hurry and.. Ooh.. Foob is starvings. Foob wish he had his [munch break favorite].")
	elseif e.message:findi("munch break favorite") then
		e.self:Emote("rubs his tummy. 'Oh!! Catfish croak sandwich is my favorite, it is. Can only eats on my break. I haves one and one is what the Haggle Baron says to Foob. Only thing is Foob gets way tired from standing. Foob needs some broodling to [fetch the catfish croak sandwich] for him.'")
	elseif e.message:findi("fetch.*sandwich") then
		e.self:Say("What?!! You dus gets Foob his sandwich for his munch break!! You be a good tail. Gets me two sandwiches, one fer break and one fer work, then me pay you something for the troubles. But it be no trouble. Foob is sure you know [how to make sandwich].")
	elseif e.message:findi("how.*sandwich") then
		e.self:Emote("chortles loudly in disbelief. 'How you not know? It da best food. You gots to get a sewer catfish which swims in da Cabilis, and find lizard who have thin sliced froglok. Then all you need is shrub lettuce and honey mush bread. All dis in da oven makes a good sandwich.'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12451, item2 = 12451}) then
		e.self:Say("Me thanks you very much!! Now me stop da tummy grumbles. You have this. And you takes dis. Foob make special, not sold yet, you test it. It is not toughest, but it take a little bashing just like you. It is called Foobscale!!")
		e.other:SummonItem(12448)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
