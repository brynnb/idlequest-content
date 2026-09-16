-- Converted from ProjectEQ Perl quest script.
-- Source: qeynos2/Nax_Ghruna.pl

function event_aggro(e)
	e.self:Say("That's it swine! You're outta here!")
end

function event_say(e)
	if e.message:findi("stanos") then
		e.self:Say("Come over here, bub. Listen to me, and don't say a word. That name is one that can get you killed. Hanns wants Stanos dead, Renux wants to please Hanns, and everyone else wants to keep their spinal column intact, you know? So, " .. e.other:GetCleanName() .. ", now you can speak. Where did you hear that name, or did you actually see Stanos somewhere?")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_death_complete(e)
	e.self:Say("My comrades will avenge my death.")
end
