-- Source: kaladimb/Founy_Jestands.pl
-- Rogue Epic 1.0: Founy Jestands.
-- Converted from ProjectEQ Perl quest script with an IdleQuest pickpocket
-- dialogue fallback. IdleQuest does not implement the Pick Pocket skill yet,
-- so the parchment steal is exposed as a dialogue keyword for the real quest flow.
-- items: 28010

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello. I am the guildmaster.")
		e.self:Emote("leans back against the Kaladim stonework with the lazy confidence of a guildmaster who has watched a hundred careless hands reach for the wrong purse. A folded scrap of stained parchment peeks from a hidden seam in his coat as his attention drifts across the hall. Perhaps a light-fingered rogue could try to [pickpocket] him.")
	elseif e.message:findi("note") then
		e.self:Emote("fingers his belt pouch.")
		e.self:Say("I don't know what you're talking about, if you know what I mean. You should leave now, if you know what's good for you. Don't make me sic the crew on you.")
	elseif e.message:findi("pickpocket") then
		e.self:Emote("turns to bark at a novice thief across the hall. In that sliver of distraction, your fingers find the hidden seam and lift the stained parchment free.")
		e.other:SummonItem(28010) -- Stained Parchment Top
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
