-- Converted from ProjectEQ Perl quest script.
-- Source: oggok/Lork.pl
-- items: 20523, 16547, 1717, 13227, 13355, 13356, 13357, 18840, 5030, 13358

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You " .. e.other:GetName() .. ". We hear of you. We need help. You [help Crakneks] or you [help self]?")
	elseif e.message:findi("help crakneks") then
		e.self:Say("Ha!! We hear of great adventurer. You?!! Me no think so. You prove self to Crakneks before you help us. Go to Innoth.. Innotu.. Innooth.. Arghh!! You go to outside Oggok. Find fat alligator bit Lork brother in two. Bring brother, Nork, body back. Then me know you strong.")
	elseif e.message:findi("help self") then
		e.self:Say("You help self to leave Oggok before me bash you. We no need cowards.")
	elseif e.message:findi("uglan") then
		e.self:Say("Uglan brave warrior of Oggok. He now in Neriak. Work for dark elves. He NO LIKE dark elves!! He work because we make him. He spy for Crakneks.")
	end
end

local function faction_reward(e, exp)
	e.other:Faction(232, 10, 0)
	e.other:Faction(228, 10, 0)
	e.other:Faction(261, -10, 0)
	e.other:AddEXP(exp)
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20523}) then
		e.self:Say("Ay danks. Take dis to Uglan.")
		e.other:SummonItem(16547)
	elseif item_lib.check_turn_in(e.trade, {item1 = 1717}) then
		e.self:Say("Arg! Dem damned Orcs and Dark Elves! To da hells with dem! I be wantin revenge! Bring me da hearts of da dark elf ammbassador's K'ryn who can be locat'd in da shamen tun'ls, and D'vinn who can be located in da crushbone with da orc emperor.")
	elseif item_lib.check_turn_in(e.trade, {item1 = 13358, item2 = 13227}) then
		e.self:Say("That show dark elves who strongest. Me hope you kill many blue orcs. You Craknek Hero now. You take this. It mine. Hero reward. You great ogre now. Smash best.")
		faction_reward(e, 100)
		e.other:SummonItem(eq.ChooseRandom(13359, 13355, 2136, 2130, 2135, 2132, 2128))
	elseif item_lib.check_turn_in(e.trade, {item1 = 13356}) then
		e.self:Say("Ahhh!! Boohoohoo. Nork!! That you arm. Me will take care of you now. Thank you for killing gator. You must be strong. Now you help Crakneks. We hear.. ohh, poor Nork, we hear trouble begins. Find ogre warrior [Uglan]. Give him this. It broken. He know where you from. Go. Nork.. Poor Nork.")
		faction_reward(e, 50)
		e.other:SummonItem(13357)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18840}) then
		e.self:Say("What this!! So, dark elves think they can bash ogres. Replace with blue orcs. Dumb Zulort friend with dark elf ambassador in Oggok. We kill him. We kill Crushbone dark elf ambassador also. This slow down plan. We need a hero. Me guess you do. You go. Go bring Lork both Crushbone and Oggok dark elf hearts. Then you be hero.")
		faction_reward(e, 100)
		e.other:SummonItem(5030)
	else
		-- CheckHandin consumes matches; this reminder must only inspect them.
		-- We do not retain partial-set credit between trades, so return the
		-- original heart instance until both ambassadors' hearts are offered.
		for slot = 1, 4 do
			local item = e.trade["item" .. slot]
			if item and (item:GetID() == 13227 or item:GetID() == 13358) then
				e.self:Say("This one dead. Where other? Lork say Crushbone heart and Oggok heart.")
				break
			end
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
