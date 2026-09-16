-- Source: dreadlands/Brother_Balatin.pl
-- Monk Epic 1.0: Brother Balatin gives Robe of the Whistling Fists.
-- Converted from ProjectEQ Perl quest script.
-- items: 12979, 12980, 12256, 12970, 12429

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("turns to you. A transparent human face materalizes upon the skull.")
		e.self:Say("What discipline do you follow?")
	elseif e.message:findi("lost circle") then
		e.self:Say("Then we are one. When you have earned your garb then you will be ready for the true drape.")
	elseif e.message:findi("true drape") then
		e.self:Say("Seek the broken flute of our master. To me they will come and to me your robe and you will come the dawning of the new brotherhood.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12979, item2 = 12980, item3 = 12256}) then
		e.self:Emote("holds his arms out and a fine robe materializes before your eyes.")
		e.other:SummonItem(12970) -- Robe of the Whistling Fists
		e.other:Faction(264, 10, 0) -- Whistling Fist Brotherhood
		e.other:Faction(268, 10, 0) -- Combine Empire
		e.other:Faction(444, -10, 0) -- Swift Tails
		e.other:AddEXP(1000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12429}) then
		e.self:Emote("quickly stashes the flute inside of his ribcage.")
		local x = e.self:GetX()
		local y = e.self:GetY()
		local z = e.self:GetZ()
		local h = e.self:GetHeading()
		eq.spawn2(86155, 0, 0, x, y, z, h)
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
