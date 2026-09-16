-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Medron_Y-Lask.pl
-- items: 19571, 16170, 19610

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Furrier Royale. Here you will find the finest skins from a variety of Norraths lesser creatures.")
		e.self:DoAnim(67)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 19571, item2 = 16170, item3 = 16170}) then
		e.self:Emote("Medron Y`Lask stretches and fastened the basilisk skins across the shield frame and attaches a leather strap and grip to the back of the shield. Here is your new shield young Shadowknight. I have been paid in advance by the Lodge of the Dead for the shields assembly. May Innoruuk strengthen you in your service to Her Majesty Queen Cristanos.")
		e.other:SummonItem(19610)
		e.other:AddEXP(1000)
		e.other:Ding()
		e.other:Faction(236, 5, 0)
		e.other:Faction(370, 1, 0)
		e.other:Faction(334, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
