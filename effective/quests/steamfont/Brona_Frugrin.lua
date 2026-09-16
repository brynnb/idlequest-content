-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/Brona_Frugrin.pl
-- items: 10170, 10171

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Well met, " .. e.other:GetName() .. "!  What brings you out this way?  Are you interested in becoming an observer?  No, you look like the adventuring type.  The wilds of the Steamfont Mountains is as far as my body goes.  But through my [duties] as an observer, my mind travels the cosmos.")
	elseif e.message:findi("duties") then
		e.self:Say("Well, I am quite an accomplished enchanter but most of my time now is spent crafting the magical lenses that enable us to see beyond the ceiling of Norrath and into other realms and dimensions.  Say, in your travels have you encountered any [evil eyes]?")
	elseif e.message:findi("evil eyes") then
		e.self:Say("Evil eyes are dangerous creatures of great magical power.  You will know one if you see one.  I believe that with the lens from an evil eye and some expert tinkering, I could create a device that will enable me to observe the gods themselves in their native planes.  If you were to bring me one of these lenses, the Eldritch Collective would reward you greatly.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10170}) then
		e.self:Say("This lens is perfect, " .. e.other:GetName() .. "!  Please, take this staff in return for your services.")
		e.other:SummonItem(10171)
		e.other:AddEXP(100)
		e.other:Faction(333, 15, 0)
		e.other:Faction(245, 15, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
