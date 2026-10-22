-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Lokar_To-Biath.pl
-- items: 18200

local function lokar_faction(e, exp)
	e.other:Ding()
	e.other:Faction(236, 10, 0)
	e.other:Faction(334, 1, 0)
	e.other:Faction(370, 1, 0)
	e.other:AddEXP(exp)
end

function event_combat(e)
	if e.joined then
		e.self:Say("Come and feel the blade of the Dark Bargainers.")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am the Scribe of Innoruuk. If you do not have business with me, begone!")
	elseif e.message:findi("innoruuk") then
		e.self:Say("I am his scribe, and He is our god. There is nothing else to be said.")
	elseif e.message:findi("scribe of dal") then
		e.self:Say("The Scribes of Dal? All of them are long since [dead].. or at least most would say that.")
	elseif e.message:findi("dead") then
		e.self:Say("Perhaps, perhaps not. I cannot remember, but perhaps Innoruuk would help me remember should you tithe him a bottle of red wine from the Blind Fish.")
	elseif e.message:findi("vow") then
		e.self:Say("Break the vow? She might. Were you to tithe 70 gold to your god, Innoruuk, he might aid you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {gold = 70}) then
		e.self:Say("Take this note to the Scribe of Dal, and perhaps she will break her vow.")
		e.other:SummonItem(18200)
		lokar_faction(e, 100)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13030}) then
		for exchange = 1, 4 do
			if exchange > 1 and not item_lib.check_turn_in(e.trade, {item1 = 13030}) then break end
			e.self:Say("Ah, yes, let me pray to our god.. Yes, Innoruuk has given me wisdom. A Scribe of Dal still exists, disguised as a barkeep in the Blind Fish. This information will not help you though, for she has sworn a [vow] of silence and will not speak of the Dal.")
			lokar_faction(e, 150)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_death_complete(e)
	e.self:Say("The death of a Dark Bargainer never goes unnoticed!")
end
