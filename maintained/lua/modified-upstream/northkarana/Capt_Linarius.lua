-- Source: northkarana/Capt_Linarius.lua
-- P99 audit: Corrupt Guards
-- items: 13303, 5369, 9002, 9003, 6350, 7350, 5027, 4209, 2248, 5310, 13304

function event_combat(e)
	if e.joined then
		e.self:Say(string.format("Time to die, %s.", e.other:GetCleanName()))
		e.self:Say("I shall rid the land of another infamous villain!")
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail, traveler! You are free to rest within this keep or within any of my towers along the roads to Qeynos. My guards shall keep watch over you. While you tread upon the roads, be warned that there are [local dangers] as well as rumors of [corrupt guards].")
	elseif(e.message:findi("corrupt guards")) then
		e.self:Say("I have heard rumors of dissension among my guards. I will reward any fine resident for the death of these traitorous guards. If you find you must kill one, bring his guard bracelet back to me. I cannot allow such men among my guards. Be sure they are corrupt, or I shall have your head as well.")
	elseif(e.message:findi("local dangers")) then
		e.self:Say("My guards report daily to me of dangers in the plains. Lately, they've been telling me of rumors of [Lord Grimrot].")
	elseif(e.message:findi("lord grimrot")) then
		e.self:Say("My guards have heard rumors of this Lord Grimrot. It is said that he is a powerful shadowknight who is raising an army of undead. Such things should be reported to the Temple of Life. Journey to Qeynos and speak with Camlend Serbold. Tell him of Lord Grimrot.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if(e.other:GetFaction(e.self) <= 6 and item_lib.check_turn_in(e.trade, {item1 = 13303})) then -- Corrupt Guard Bracelet
		e.self:Say("What a pity. Such a promising soldier. I thank you for ridding us of this corruption and offer you this as a reward. It is nothing more than junk which littered the roadways of the Plains of Karana. I hope you can find a use for it.")
		e.other:SummonItem(eq.ChooseRandom(5369, 9002, 9003, 6350, 7350, 5027, 4209, 2248, 5310)) -- Bunker Battle Blade, Round Shield, Targ Shield, Fine Steel Warhammer, Fine Steel Dagger, Bronze Long Sword, Bronze Bracers, Reinforced Boots, Tentacle Whip
		e.other:Ding()
		e.other:Faction(262,10,0) -- Guards of Qeynos
		e.other:Faction(219,10,0) -- Antonius Bayle
		e.other:Faction(230,-10,0) -- Corrupt Qeynos Guards
		e.other:Faction(223,-10,0) -- Circle Of Unseen Hands
		e.other:Faction(291,10,0) -- Merchants of Qeynos
		e.other:AddEXP(48000)
		e.other:GiveCash(0,0,8,0)
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13304})) then -- Loyal Guard Bracelet
		e.self:Say("You fool!!! You have slain a loyal defender of the guard!  Prepare to DIE!!!")
		eq.attack(e.other:GetName())
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
