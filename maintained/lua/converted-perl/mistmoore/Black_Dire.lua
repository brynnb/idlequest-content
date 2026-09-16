-- Converted from ProjectEQ Perl quest script.
-- Source: mistmoore/Black_Dire.pl

function event_say(e)
	if e.message:findi("hail") then
		if e.other:Class() == "Shaman" then
			e.self:Say("So, you've come. I suppose my brothers have sent you to lead me back to their flock. Those fools are so blinded by their devotion they know nothing of life. If they only knew the power I've become, the luxuries I've amassed, the pleasures I've known, they too would leave that sour and unrewarding existence in seconds. You know, you could come to know what I have, shaman. You found me, which speaks of your intelligence; we could use you. What do you say, " .. e.other:GetCleanName() .. "? [Will you join] my master Mayong Mistmoore?")
		else
			e.self:Say("Hello, " .. e.other:GetCleanName() .. ".")
		end
	elseif e.message:findi("will not join") and e.other:Class() == "Shaman" then
		e.self:Say("Good shaman, now bare your neck that I may show our master your devotion in death. The more blood you spill upon the grass, the more impressed our Lord Mistmoore will be. Then maybe, just maybe, you will be allowed to scour our kitchen floors in the eternity of unlife. TEAR him to pieces, my wolves!")
		eq.attack(e.other:GetName())
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
