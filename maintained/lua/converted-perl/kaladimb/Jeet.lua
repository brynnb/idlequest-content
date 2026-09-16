-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Jeet.pl
-- P99: https://wiki.project1999.com/The_Gnome_Take
-- items: 12164, 13054, 2119, 2122, 2114, 2113, 2121, 13282, 12165, 12167, 10019, 10010, 10004, 10320, 10016, 10015, 10006, 10005, 12162

local function faction_reward(e)
	e.other:Faction(322, 10, 0)
	e.other:Faction(223, -10, 0)
	e.other:Faction(379, -10, 0)
	e.other:Faction(241, 10, 0)
	e.other:Faction(244, -10, 0)
	e.other:AddEXP(5000)
end

local function summon_gnome_take_reward(e)
	e.other:SummonItem(eq.ChooseRandom(10019, 10010, 10004, 10320, 10016, 10015, 10006, 10005))
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What business do you have here?!! This here is the mine and that means if you ain't a [member of Miner's Guild 628], you'd best be moving on!!")
	elseif e.message:findi("member of miner's guild 628") then
		e.self:Say("Well, then, get off yer rump and give us a hand! If you don't have a mining pick, then get down there and use your fingernails!! If you're new and you want to earn a pick, you can [volunteer to exterminate the rats] that have been infesting the mines!!")
	elseif e.message:findi("volunteer to exterminate the rats") then
		e.self:Say("Well, someone has to do the dirty work around here. Let it be you new miners. Go patrol the mines and if you see any rats, bash them good!! Return to me with four rat pelts and I will give you some armor as payment. If you want a 628 mining cap, yer gonna have to smash that infernal [cleaner]!!")
	elseif e.message:findi("run to the gnome city") then
		e.self:Say("Well, as you most likely know, we are a non-profit organization, at least here in Kaladim. We need to make our profit elsewhere and that means a little bit of thieving. Presently we need loyal members to [collect the gnome profit].")
	elseif e.message:findi("collect the gnome profit") then
		e.self:Say("Take this key. Don't lose it!! You will need to use it on a metal rat called a scrubber. They are all over Ak'Anon. You must find the one that responds to the number, '628'. If it responds, use the key on it. It will hand over a bag with the 'gnome take'. Return it to me. Get moving!!")
		e.other:SummonItem(12164)
	elseif e.message:findi("cleaner") then
		e.self:Say("Darn that blasted clockwork cleaner!! No one in Kaladim even knows what it is! They all think it's some kinda rat in armor!! Rat paladins?!! The name fits. We miners have seen many like it in the gnome city during heists, err.. visits. We have to get rid of this one in Kaladim!! If you smash it and get its scrap metal, I am authorized to give you a mining cap, if you are a member of Miner's Guild 628.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local pfaction = e.other:GetFaction(e.self)
	if pfaction > 5 then
		e.self:Say("This here is the mine and that means if you ain't a member of Miner's Guild 628, you'd best be moving on!!")
	elseif item_lib.check_turn_in(e.trade, {item1 = 13054, item2 = 13054, item3 = 13054, item4 = 13054}) then
		e.self:Say("It's about time you managed to smash these four!! Here. You do good work. We could use someone like you to [run to the gnome city].")
		faction_reward(e)
		e.other:SummonItem(eq.ChooseRandom(2119, 2122, 2114, 2113, 2121))
	elseif item_lib.check_turn_in(e.trade, {item1 = 13282}) then
		e.self:Say("Great work!! We need this junk for something and we sure didn't need this rat sucking up any of our gems. Here. This is a Mining Cap 628. It's not much, but it is the mark of our miners and provides light for mining purposes. Hold onto it. You never know when we may call upon you to produce it.")
		faction_reward(e)
		e.other:SummonItem(12165)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12167}) then
		e.self:Say("What is all this junk!! That blasted tin rat is supposed to be heisting expensive goods from rich gnomes - not all this garbage!! Here. This is your cut of this junk.")
		faction_reward(e)
		summon_gnome_take_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12162}) then
		e.self:Say("Good work miner. This is a fantastic haul!! Those wrinkly little gnomes don't know what is going on. Here is your cut. Now get back to work.")
		faction_reward(e)
		summon_gnome_take_reward(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	e.self:Say("I am working on it, Mater!!")
end
