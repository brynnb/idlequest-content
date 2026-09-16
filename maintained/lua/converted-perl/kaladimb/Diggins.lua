-- Converted from ProjectEQ Perl quest script, with later-era branches omitted
-- for Classic/Kunark IdleQuest scope.
-- Source: kaladimb/Diggins.pl
-- items: 13931, 7007, 7008, 7009, 7010, 12170, 12172, 12174, 12178, 12166

local function trusted_miner(e)
	return e.other:GetFaction(e.self) <= 4
end

local function allowed_in_mines(e)
	return e.other:GetFaction(e.self) <= 7
end

local function not_trusted(e)
	if e.other:GetFaction(e.self) <= 5 then
		e.self:Say("Don't take this personally, but I can't quite trust you with such matters. Maybe a few less Butcherblock bandits would prove your worth.")
	else
		e.self:Say("The word around the mines is that you are not to be trusted. You'd best leave before my dagger finds a new home in your back.")
	end
end

local function faction_reward(e)
	e.other:Faction(322, 10, 0)
	e.other:Faction(223, -10, 0)
	e.other:Faction(379, -10, 0)
	e.other:Faction(241, 10, 0)
	e.other:Faction(244, -10, 0)
	e.other:AddEXP(5000)
end

function event_say(e)
	if e.message:findi("hail") then
		if allowed_in_mines(e) then
			e.self:Say("How is life treating you, bud? What are you doing around the mines? Either you are a [member of 628] or you are lost. If you are lost, I can't help you. I ain't no guide.")
		else
			not_trusted(e)
		end
	elseif e.message:findi("member of 628") then
		if trusted_miner(e) then
			e.self:Say("It's my duty to assign [guild tasks] to all new members of Mining Guild 628.")
		else
			not_trusted(e)
		end
	elseif e.message:findi("guild tasks") then
		if trusted_miner(e) then
			e.self:Say("I see you are interested in helping out. Good! For starters, go into the surrounding territory of Kaladim and destroy all the goblins. We hear they sometimes carry necklaces of ornate design. 628 wants these Runnyeye warbeads. You bring me no fewer than four and I will pay you and maybe, just maybe, I may have an extra piercing weapon lying around which has your name on it.")
		else
			not_trusted(e)
		end
	elseif e.message:findi("earn a parrying pick") then
		if trusted_miner(e) then
			e.self:Say("So you want to earn a parrying pick? Consider it an honor that I am even speaking of this with you. The guild had these picks made just for us. It is a magic item used to fend off attacks. Before you can have one, you will have to do me a [great favor].")
		else
			not_trusted(e)
		end
	elseif e.message:findi("great favor") then
		if trusted_miner(e) then
			e.self:Say("Mater has asked me to exterminate the dwarven family of Dunfire. They were once members of our guild. They left and now use their talents to aid the Butcherblock bandits. We will not allow them to speak of the skills we taught them. Go and rip out their tongues. Return the tongues of Crytil, Rondo, Keldyn, and Barma Dunfire and the parrying pick is yours.")
		else
			not_trusted(e)
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13931, item2 = 13931, item3 = 13931, item4 = 13931}) then
		e.self:Say("Good work. We shall add these to the stash. Here is your reward, as promised. Be happy with it and continue your work. Maybe soon you shall be able to [earn a parrying pick].")
		faction_reward(e)
		e.other:GiveCash(0, 2, 0, 0)
		e.other:SummonItem(eq.ChooseRandom(7007, 7008, 7009, 7010))
	elseif item_lib.check_turn_in(e.trade, {item1 = 12170, item2 = 12172, item3 = 12174, item4 = 12178}) then
		if trusted_miner(e) then
			e.self:Say("Excellent work!! You are quite an asset to this mining guild. Please accept this Parrying Pick 628 for your great service. If you truly wish to serve our guild. Go and speak with Mater. Tell him you are [ready to earn Mining Pick 628].")
			faction_reward(e)
			e.other:SummonItem(12166)
		else
			not_trusted(e)
			e.other:SummonItem(12170)
			e.other:SummonItem(12172)
			e.other:SummonItem(12174)
			e.other:SummonItem(12178)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
