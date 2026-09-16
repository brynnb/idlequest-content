-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Expin.pl
-- P99 audit: Pixie Dust (Kelethin Rogue)
-- items: 2104, 17957, 12109, 16390, 24098

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("How are you, my friend?  You must be a [new scout of Kelethin].  I would hope so.  We dearly need more recruits.  Most of the Fier'Dal choose the path of the ranger.")
	elseif e.message:findi("new scout of kelethin") then
		e.self:Say("Good.  I have an easy, but very important, task for you.  We require all young members to cleanse these woods of the troublesome pixie tricksters.  Take this pouch, fill it, and when it is combined, return it to me.  I just may have some used armor lying around for you.")
		e.other:SummonItem(17957)
	elseif e.message:findi("dark assassin") then
		e.self:Emote("squints at you and says, 'So you have heard about him as well? I had heard of him through the rogue grapevine, so I was wary when the home guard spoke of the arrival of a dark stranger. I was approaching him from behind and some loud ranger clompipng about in the bushes must of spooked him, for off he ran. As he was running I took the liberty to swipe a piece of paper protruding from his pocket.'")
		e.self:Emote("mumbles to himself, 'Now where did I put that note?'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12109}) then
		e.self:Say("Good work. scout!!  You have earned this reward.  It is all we have at the time.  I am certain you are satisfied.  If not, then do not let me hear of it.")
		e.other:SummonItem(2104) -- Patchwork Tunic
		e.other:GiveCash(3, 6, 0, 0)
		e.other:Faction(316, 10, 0)
		e.other:AddEXP(800)
	elseif item_lib.check_turn_in(e.trade, {item1 = 16390}) then
		e.self:Say("Ahhh! You found it! Here let me make you a copy and put this in a secure spot so I don't lose it again.")
		e.other:SummonItem(24098)
		e.other:AddEXP(5061818)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
