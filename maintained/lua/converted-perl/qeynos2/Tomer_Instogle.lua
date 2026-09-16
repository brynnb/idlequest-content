-- Converted from ProjectEQ Perl quest script.
-- Source: qeynos2/Tomer_Instogle.pl
-- P99 audit: Tomer's Rescue
-- Note: IdleQuest currently persists the rescue state but does not physically escort Tomer; eq.follow is a runtime compatibility no-op.
-- items: 20459

local function qglobal(e, key)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals[key]
end

function event_say(e)
	local find_tomer = qglobal(e, "FindTomer")
	if find_tomer == "1" or find_tomer == 1 then
		if e.message:findi("hail") then
			e.self:Say("Ahhhgggg.. Those mangy [dogs] put up a tough fight.. If I don't make it back to the [Clan House] soon, it'll all be over for me.")
		elseif e.message:findi("dogs") or e.message:findi("mutts") then
			e.self:Say("It's those Darkpaws.. They've beat me pretty badly.. but they'll get theirs soon enough!")
		elseif e.message:findi("clan house") then
			e.self:Say("I am a new member of the Silent Fist Clan.. I need someone from my guild to help me find my way back.")
		elseif e.message:findi("Seta sent me to find you") then
			e.self:Say("Oh.. Thank goodness you found me.. I'm lost and weak, those [mutts] are a vicious lot.. an you carry my [backpack] for me?")
		elseif e.message:findi("backpack") then
			e.self:Say("Thank you, friend.. Now, can you [lead me back to Master Seta] of the Silent Fist Clan? ")
			e.other:SummonItem(20459)
		elseif e.message:findi("lead you back to master seta") then
			e.self:Say("Lead the way, and I shall follow. When we make it back, please inform Seta that you have rescued me.")
			eq.set_global("SetaTomer", "1", 1, "M30")
			eq.follow(e.other)
		end
	elseif find_tomer == "2" or find_tomer == 2 then
		if e.message:findi("hail") then
			e.self:Say("Yes, he saved my life.. I owe him much thanks. Please return my pack to me now, good friend.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if (qglobal(e, "FindTomer") == "2" or qglobal(e, "FindTomer") == 2) and item_lib.check_turn_in(e.trade, {item1 = 20459}) then
		e.other:Ding()
		e.self:Say("Oh, you have the makings of a true hero.. The Silent Fist Clan is proud to have you as ally. May your soul guide and protect you through these chaotic times.")
		e.other:AddEXP(100)
		e.other:Faction(309, 35, 0)
		e.other:Faction(262, 5, 0)
		e.other:Faction(361, 1, 0)
		eq.delete_global("FindTomer")
		eq.stop_follow()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
