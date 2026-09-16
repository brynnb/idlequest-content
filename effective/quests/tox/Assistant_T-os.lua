-- Converted from ProjectEQ Perl quest script.
-- Source: tox/Assistant_T-os.pl

function event_say(e)
	if e.message:findi("hail") then
		if e.qglobals.tsoma == "2" then
			e.self:Say("You're late! Never mind. Prepare yourself. I do not trust these magics T`soma has constructed.")
		else
			e.self:Say("Hmm. You aren't familiar. . .no matter. All is ready. Prepare yourself. Who knows what may happen. . .")
		end
		eq.spawn2(38173, 0, 0, 1630, 2137, -54, 270) -- #Fleshless_Servant
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
