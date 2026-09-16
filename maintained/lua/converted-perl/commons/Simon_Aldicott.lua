-- Converted from ProjectEQ Perl quest script.
-- Source: commons/Simon_Aldicott.pl
-- items: 6708, 6709, 15693

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail and well met. I am Simon Aldicott, a cleric in the service of Mithaniel Marr. I've been sent here to prepare a funeral service for one of our lost to join Marr in his kingdom.")
	elseif e.message:findi("funeral service") then
		e.self:Say("Are you the brave knight whom Valeron sent to meet me here? If so please place the remains in the coffin and seal it. Then hand me the coffin so that we may bless it in the waters of this lake.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 6708}) then
		e.self:Emote("places the coffin in the water and begins to pray. 'Lord of Valor high above, take this knight, your loyal child, into thy kingdom and all that is holy! What is that thing!'")
		eq.spawn2(21031, 0, 0, 2901, 259.7, -51, 50)
	elseif item_lib.check_turn_in(e.trade, {item1 = 6709}) then
		e.self:Say("Thank you, Knight. With this task accomplished, I shall reward you with this scroll. It is an ancient spell that only the holiest of knights may cast. Remember your duty!")
		e.other:SummonItem(15693)
		e.other:Faction(362, 100, 0)
		e.other:Faction(330, -50, 0)
		e.other:Faction(281, 100, 0)
		e.other:AddEXP(200000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	if e.signal == 66 then
		e.self:Say("Tis a sad thing. His soul was twisted to its current state somehow and he thought YOU were the foul Teir'Dal who destroyed him in the first place. But that is no matter..you have freed him to stand by Marrs side once more! Now, give me the ash so that I may finally put him to rest. In return for your valor I shall provide you with an ancient spell unknown to most Holy Knights of Marr.")
	end
end
