-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Xantis_Ixtax.pl
-- items: 13394

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, disciple " .. e.other:GetName() .. ". Feel free to inspect my wares. I am here to serve all necromancers of the Dead. I can also enchant a [Ring of the Dead] if you have one.")
	elseif e.message:findi("ring of the dead") then
		e.self:Say("The ring of the Dead is the mark of loyal members of the his house. One can use it to bind his soul to any point, but only once and then the enchantment is gone. It is my duty to enchant the ring of the Dead once it is drained of all power, but only for a loyal member. I believe you to be loyal. I require the drained ring and ten gold coins.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13394, gold = 10}) then
		e.self:Say("Here you are, disciple. I have enchanted your ring once more.")
		e.other:Ding()
		e.other:SummonItem(13394, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
