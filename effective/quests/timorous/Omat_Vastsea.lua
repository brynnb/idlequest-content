-- Source: timorous/Omat_Vastsea.pl
-- Cleric Epic 1.0: Omat Vastsea handles the three water orb branches.
-- Converted from ProjectEQ Perl quest script.
-- items: 28047, 28051, 1299, 28049, 18170, 28017, 28048, 28019, 28050

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("bows deeply. 'I have been expecting you, " .. e.other:GetName() .. ". The waters have foretold your arrival. I am High Priest Omat Vastsea of the Triumvirate missionaries. Please feel free to enjoy the quiet solitude of this inn.'")
	elseif e.message:findi("Triumvirate") then
		e.self:Say("The Triumvirate of Water are E'ci, Tarew Marr, and Povar.")
	elseif e.message:findi("Fennin Ro") then
		e.self:Say("The Tyrant of Fire, Fennin Ro, is the merciless lord of fire in all its forms.")
	elseif e.message:findi("plasmatic priesthood") then
		e.self:Say("The Plasmatic Priesthood are worshipers of the Tyrant of Fire.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 28047}) then
		e.self:Say("So, you are a friend of Natasha's? Locate the Plasmatic Priest, hand him this statue to hinder his powers, then eliminate him and bring me his robe.")
		e.other:SummonItem(28051) -- Coral Statue of Tarew
	elseif item_lib.check_turn_in(e.trade, {item1 = 1299}) then
		e.self:Say("You have proven yourself to be one who is willing to take responsibility for his own actions. Priestess Natasha awaits inside the inn for Lord Gimblox's ring.")
		e.other:SummonItem(28049) -- Orb of Frozen Water
		e.other:AddEXP(100000)
		eq.unique_spawn(96080, 0, 0, -2198, -11601, 76, 0) -- Natasha_Whitewater
	elseif item_lib.check_turn_in(e.trade, {item1 = 18170, item2 = 28017}) then
		e.self:Say("I commend you on your success over the fire elemental lord, Ixiblat Fer. Seek Zordak Ragefire and bring me his heart.")
		e.other:SummonItem(28048) -- Orb of Clear Water
		e.other:AddEXP(100000)
		eq.unique_spawn(96080, 0, 0, -2198, -11601, 76, 0) -- Natasha_Whitewater
	elseif item_lib.check_turn_in(e.trade, {item1 = 28019}) then
		e.self:Say("Jhassad Oceanson awaits on the shore below to perform the ritual that will merge the orbs into a single Orb of the Triumvirate and summon an avatar from the Plane of Water.")
		e.other:SummonItem(28050) -- Orb of Vapor
		e.other:AddEXP(100000)
		eq.unique_spawn(96074, 0, 0, -1781, -11959, 14.3, 2) -- Jhassad_Oceanson
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
