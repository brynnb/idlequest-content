-- Source: overthere/Astral_Projection.pl
-- Monk Epic 1.0: Astral Projection gives Eye of Kaiaren.
-- Converted from ProjectEQ Perl quest script.
-- P99 explicitly makes visiting Deep optional. The head is the prerequisite;
-- do not require ProjectEQ's Trunt global to redeem it.
-- items: 1686, 1687

function event_say(e)
	if e.other:HasItem(1687) then
		if e.message:findi("yes") then
			e.self:Say("I assume you have read about us and spoken with the old man, Kaiaren. Since that time, I have grown in power and influence to a point unseen by any mortal. Unfortunately, I will have to demonstrate a small amount of my skill when I destroy you. This is bad. I must decide whether you are worthy to see the techniques I wield, even though you will die shortly thereafter. Tell me, who are you?")
		elseif e.message:findi("i am the one") then
			e.self:Emote("chuckles.")
			e.self:Say("That's quite a boast. All beings strive for nothingness at the most basic level of sentience. However, almost none ever achieve this. Not even I have discarded my ego yet and you stand here and tell me you have? Perhaps you will be a worthy opponent. I shall be waiting in the great lake near here. Take that token as proof of things to come for you. If you still wish to throw your life away so needlessly, return it to my image there. I await your decision.")
			eq.depop()
		end
	else
		e.self:Emote("ignores you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1686}) then
		e.self:Emote("looks up and down.")
		e.self:Say("Hmmm, I was hoping for something more impressive. This is just a small token of the last person who tried to interfere with my plans. He failed as you shall. But tell me truly, are you the one who has so rudely removed my students?")
		e.other:SummonItem(1687) -- Eye of Kaiaren
		eq.delete_global("Trunt") -- Clear legacy state if Deep was visited.
	else
		e.self:Say("I have no use of this, " .. e.other:GetName() .. ".")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
