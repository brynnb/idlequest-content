-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/#Lady_Deira.pl
-- items: 8918, 8917, 8919, 8952, 8954

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("closes her eyes and gives a formal, polite bow to " .. e.other:GetName() .. ".")
		e.self:Say("I am Lady Deira, Veteran of Thunder. I have [duties] to uphold and must give the fullest of my attentions to the fort.")
	elseif e.message:findi("duties") then
		e.self:Say("I was sent to aid in fortifying the military front and train those who are [lost] in the ways of modern warfare.")
	elseif e.message:findi("lost") then
		e.self:Say("They are capable scouts and artisans, but they are [undisciplined].")
	elseif e.message:findi("undisciplined") then
		e.self:Say("My duties are to aid in protection and training. In return, the citizens have shared [secrets] of our mutual faith.")
	elseif e.message:findi("secrets") then
		e.self:Say("I recently have been taught the ancient secrets of their blacksmiths -- secrets that until recently held [no place] in the culture of the Jaggedpine.")
	elseif e.message:findi("no place") then
		e.self:Say("With the reunion of the Jaggedpine, the old ways are [alive once again].")
	elseif e.message:findi("alive once again") then
		e.self:Say("I have been given the honor of learning the [ways of my ancestors].")
	elseif e.message:findi("ways of your ancestors") then
		e.self:Say("I was invited to learn the rites of the [Tempest Guard] and wield our ancient symbol.")
	elseif e.message:findi("Tempest Guard") then
		e.self:Say("If a veteran of the storm views themselves as [worthy to bear the Tempest Guard symbol], I shall test them.")
	elseif e.message:findi("worthy to bear the Tempest Guard symbol") then
		e.self:Say("The first steps require you to obtain the [items] that will be constructed into your symbol.")
	elseif e.message:findi("items") then
		e.self:Say("Retrieve the Earthen Crown of the Underfoot and [Nyrein's Tome].")
	elseif e.message:findi("Nyrein's Tome") then
		e.self:Say("Nyrein Shadowstorm was the first to bear the title of Tempest Guard. Her story also leads to the [Tempest Rune].")
	elseif e.message:findi("Tempest Rune") then
		e.self:Say("The rune was once [entrusted with the stone] to a young warrior.")
	elseif e.message:findi("entrusted with the stone") then
		e.self:Say("Eventually this rune would become a sacred symbol, but [history] would weave a new turn.")
	elseif e.message:findi("history") then
		e.self:Say("Anumnan then faced the gravest [decision] that any father and devoted priest fears.")
	elseif e.message:findi("decision") then
		e.self:Say("Anumnan was confronted with a [truth] that changed him forever.")
	elseif e.message:findi("truth") then
		e.self:Say("That truth left him alone in consuming [doubt].")
	elseif e.message:findi("doubt") then
		e.self:Say("His allies [would not have his tale].")
	elseif e.message:findi("would not have his tale") then
		e.self:Say("Seek Anumnan in the southern desert of Ro and recover the rune he still wears.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8918, item2 = 8917}) then
		e.self:Say("You have done well thus far. Take this, Nyrein's Prayer, to Lord Mrallon in Qeynos. With the prayer, he will expect the Tempest Rune.")
		e.other:SummonItem(8919)
		e.other:Faction(1597, 10, 0)
		e.other:Faction(272, 5, 0)
		e.other:Faction(302, 5, 0)
		e.other:Faction(262, 1, 0)
		e.other:AddEXP(1000)
	elseif item_lib.check_turn_in(e.trade, {item1 = 8952}) then
		e.self:Emote("gives a warm, gentle smile and a deep bow of respect to " .. e.other:GetName() .. " as she extends a white steel crown ornamented with a single blue gem.")
		e.self:Say("Welcome to the Veterans of the Storm, and we honor you as Tempest Guard " .. e.other:GetName() .. ".")
		e.other:SummonItem(8954)
		e.other:Faction(1597, 15, 0)
		e.other:Faction(272, 7, 0)
		e.other:Faction(302, 7, 0)
		e.other:Faction(262, 1, 0)
		e.other:AddEXP(2000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
