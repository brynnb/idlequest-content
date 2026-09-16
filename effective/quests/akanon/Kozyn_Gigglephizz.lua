-- P99 audit: Tinmizer's Fabulous Compactor (Quest)
-- Local item 17033 is named Tinmizer's Stupendous Contraption; P99 documents the
-- old Scrap Metal reward as Tinmizer's Fabulous Compactor and says it no longer
-- drops on Blue/Green. The source item remains unavailable from Scrap Metal, but
-- this keeps the hand-in behavior available if the item already exists.
-- items: 17033, 10016

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings my friend. Have you come to turn in one of those malfunctioned containers called [Tinmizer]'s [Fabulous Compactor]? I shall gladly exchange it for a few nice gems.")
	elseif e.message:findi("where is tinmizer") then
		e.self:Say("Alas, for tinkering defective merchandise, he was exiled from Ak'Anon. First, the [clockwork dragon] and now the [Fabulous Compactor]. What could be next? No one has seen nor heard of him since. Probably ended up as a feast for the ogres.")
	elseif e.message:findi("tinmizer") then
		e.self:Say("Ho, ho, ho!! Oh, my! Tinmizer was a bit of a goof when it came to tinkering. I am from the [T.B.I.] and I was sent to clean up the mess he made. He was tinkering defective containers and selling them. We exiled him and destroyed all his containers. Now we hear the scrapman found some and was using them as a reward for deeds. We have warned him.")
	elseif e.message:findi("t.b.i") or e.message:findi("tbi") then
		e.self:Say("Ssshhh. This is against regulations, but you look like you could keep a secret. T.B.I. stands for the Tinkerers Bureau of Investigation. We are a clandestine organization reporting directly to King Ak'Anon. We handle all tinkering glitches, if you know what I mean.")
	elseif e.message:findi("fabulous compactor") then
		e.self:Say("The compactor is a defective piece of junk. Crafted by the clumsy hands of [Tinmizer]. My work shall be done as soon as I exchange all the compactors for precious gems. We take a loss here, you know!!?")
	elseif e.message:findi("clockwork dragon") or e.message:findi("big bynn") then
		e.self:Say("Oh!! I have seen it. A thousand feet tall and smells of burning oil. It was tinkered by [Tinmizer]. Yep, that's it all righty. Tinkered by the loon. He started out just making a clock, a giant one!! It was in the form of a wurm. He called it [Big Bynn], you know, after his familiar named Bynn. And then... then it escaped. Yeah.. That's it.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 17033}) then
		e.self:Say("Excellent! Another unstable embarrassment locked away from innocent pockets. Here, take these gems before anyone asks what the T.B.I. spends on cleanup.")
		e.other:SummonItem(10016) -- Lapis Lazuli
		e.other:Ding()
		e.other:AddEXP(500)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
