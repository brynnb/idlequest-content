-- Converted from ProjectEQ Perl quest script.
-- Source: kaladima/Beno_Targnarle.pl
-- items: 18935, 13054, 1051, 13003, 13002, 10015, 13282, 13995, 13321, 5415

local function stormguard_reward(e, storm_guard, kazon, miners, merchants, craknek)
	e.other:Faction(312, storm_guard, 0)
	e.other:Faction(274, kazon, 0)
	e.other:Faction(293, miners, 0)
	e.other:Faction(290, merchants, 0)
	e.other:Faction(232, craknek, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Step forth, young " .. e.other:GetName() .. "! I heard that you have come of age! The spirit of adventure has entered your body. That is good. Go and speak with the others. They shall help you. I am afraid I have no time to spend conversing. There is much I have to [ponder].")
	elseif e.message:findi("ponder") then
		e.self:Say("Must you know everyone's business? Hmm.. Maybe you can be of assistance. You see, I have been instructed by Furtog to tend to a matter of extreme urgency, which is keeping me from clearing the mines of rats. Will you assist and [exterminate the rats]?")
	elseif e.message:findi("exterminate the rats") then
		e.self:Say("Very good! I shall reward you for every four giant rat pelts returned to me. And be on the lookout for a [metal rat]!")
	elseif e.message:findi("metal rat") then
		e.self:Say("I cannot tell you how many reports I have heard of metal rats in Kaladim. I first thought it was a vision obtained from having too many Tumpy Tonics, but Furtog himself is said to have seen them. If you ever catch sight of the little metal beast, give chase!! Return its metal carcass to me and I shall reward you.")
	elseif e.message:findi("important stormguard matter") then
		e.self:Say("I am apprehensive about sending one who is so young out into the world, but I have a good feeling about you, " .. e.other:GetName() .. ". Someone has stolen the [Eye of Stormhammer]. You must journey to Antonica and go to a place called Highpass Hold. The rogue who has it is locked up in the prison. We have arranged for his extradition to Kaladim. Please give the jail clerk this note of release.")
		e.other:SummonItem(18935)
	elseif e.message:findi("eye of stormhammer") then
		e.self:Say("The great statue of Kazon Stormhammer was once encrusted with two great gems from the mines of Butcherblock. So big were they that it took the magic of the high elves to assist us in lifting them to the statue's face. In the year 2995, somehow, someone stole one of the eyes. We decided to keep the remaining eye in the vault. Now, even that has been stolen from us! Only the most trusted warriors may be involved in this [important Stormguard matter].")
	elseif e.message:findi("doran vargnus") then
		e.self:Say("Doran resides on an island in the Ocean of Tears. The island is filled with beautiful maidens. I could think of worse places to live.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local pfaction = e.other:GetFaction(e.self)
	if pfaction > 4 then
		e.self:Say("You need to prove your dedication to our cause before I can discuss such matters with you.")
	elseif item_lib.check_turn_in(e.trade, {item1 = 13054, item2 = 13054, item3 = 13054, item4 = 13054}) then
		e.self:Say("Well done indeed! You are well on your way to becoming a fine warrior. Take this for your travels.")
		e.other:Ding()
		stormguard_reward(e, 5, 1, 1, 1, -1)
		e.other:AddEXP(500)
		e.other:SummonItem(eq.ChooseRandom(1051, 13003, 13002, 10015))
	elseif item_lib.check_turn_in(e.trade, {item1 = 13282}) then
		e.self:Say("I thank you, my friend. I was to destroy this metal monster months ago. I could never find him. Please accept this reward for such good service. Oh yes.. And take this card to a man named [Doran Vargnus]. He is a fine blacksmith. I am sure he will reward you with one of his finest suits of armor. Perhaps you may now assist in an [important Stormguard matter].")
		e.other:Ding()
		stormguard_reward(e, 20, 5, 3, 5, -5)
		e.other:AddEXP(500)
		e.other:GiveCash(4, 0, 0, 0)
		e.other:SummonItem(13995)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13321}) then
		e.self:Say("You've found it! I'm glad you managed to hunt down and return the stolen eye for us, " .. e.other:GetName() .. ". Such effort requires a similar reward so take this and use it well.")
		stormguard_reward(e, 20, 5, 3, 5, -5)
		e.other:AddEXP(5000)
		e.other:GiveCash(4, 0, 0, 0)
		e.other:SummonItem(5415)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
