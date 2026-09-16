-- Modified from ProjectEQ Lua for P99 Lenka's Pouch separation.
-- Toala starts Lenka's Pouch and still handles her existing Steel Warriors
-- dark-elf courier branch, but the L.S. Pouch turn-in belongs to Lenka.
-- Source: freeporteast/Toala_Nehron.lua
-- P99: https://wiki.project1999.com/Lenka%27s_Pouch
-- items: 18814, 17971, 12246

function event_say(e)
	local fac = e.other:GetFaction(e.self)

	if e.message:findi("hail") then
		e.self:Say("I am Toala Nehron. You must be another young warrior aspiring to join the ranks of the Steel Warriors. We welcome all who would try. When you [have time] there is a friend of mine I would like you to check on.")
	elseif e.message:findi("opal") then
		e.self:Say("Opal Darkbriar is a little plague rat. She has used her knowledge of arcane arts to charm [Cain Darkmoore]. I know that is what happened. Why else would he be in love with her? He is a mighty warrior and she is nothing more than a sickly little librarian for the Academy of Arcane Science. He must truly yearn for a bold hearted female warrior such as myself. Not that I care, of course.")
	elseif e.message:findi("cain darkmoore") then
		e.self:Say("Cain Darkmoore is only the most handsome of warriors! He is also the strongest and most bold. He has slain the mightiest of fiends. He is truly the manliest man around. It is no wonder he is the guildmaster of the Steel Warriors.")
	elseif fac < 5 then
		if e.message:findi("have time") then
			e.self:Say("I have a friend by the name of [Lenka Stoutheart]. She reported to me that her ship was broken into and someone stole a pouch of hers. Could you go look into it for me? Just tell her Toala sent you. Oh, and pay no mind to the walking mountain by her. That will only be Bronto, her navigator. Thanks, friend.")
		elseif e.message:findi("lenka stoutheart") then
			e.self:Say("Lenka Stoutheart is an old friend of mine. I trained with her in my younger days when the Steel Warriors sent me to train in the ways of the Wolves of the North, the barbarian warriors of Halas. She is now an adventurer of great sorts. She travels from continent to continent aboard the Blue Beast, her ship.")
		end
	elseif fac == 5 then
		if e.message:findi("have time") or e.message:findi("lenka stoutheart") then
			e.self:Say("The Steel Warriors have no cause to dislike you, but you have yet to prove your worth to this guild.")
		end
	elseif fac > 5 then
		if e.message:findi("have time") or e.message:findi("lenka stoutheart") then
			e.self:Say("Your head shall look grand mounted on the wall of the Steel Warriors Arena!!")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	local fac = e.other:GetFaction(e.self)

	if fac < 5 then
		if item_lib.check_turn_in(e.trade, {item1 = 18814}) then -- A Sealed Letter
			e.self:Say("Why, that little trollop! What is she up to? Cain will never believe this! She must be in league with some faction of the dark elves, but why? Neither the Academy of Arcane Science nor Cain will believe this note. I will see what I can do. As for you, I command you to kill this Shintl and her dark elf courier Hollish!! Put their heads into this box and combine them. We shall cut the link. Bring me their heads.")
			e.other:SummonItem(17971) -- Toala's Box for heads
			e.other:Ding()
			e.other:AddEXP(500)
		elseif item_lib.check_turn_in(e.trade, {item1 = 12246}) then -- Box with Two Heads
			e.self:Say("Good work!! We will soon catch Opal. I have started to formulate a plan to stop her. When I complete it, I shall notify you. Here. Take this small reward. I am sure killing Shintl was no trouble. She was just a halfling.")
			e.other:Ding()
			e.other:Faction(311, 10, 0) -- Steel Warriors
			e.other:Faction(262, 2, 0) -- Guards of Qeynos
			e.other:Faction(281, 2, 0) -- Knights of Truth
			e.other:Faction(230, -1, 0) -- Corrupt Qeynos Guards
			e.other:Faction(330, -1, 0) -- Freeport Militia
			e.other:AddEXP(2000)
			e.other:GiveCash(0, 10, 2, 0)
		end
	elseif fac == 5 then
		if item_lib.check_turn_in(e.trade, {item1 = 18814}) then
			e.self:Say("The Steel Warriors have no cause to dislike you, but you have yet to truly prove your worth to this guild.")
		end
	elseif fac > 5 then
		if item_lib.check_turn_in(e.trade, {item1 = 18814}) then
			e.self:Say("Your head shall look grand mounted on the wall of the Steel Warriors Arena!!")
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
