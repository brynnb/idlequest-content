-- Converted from ProjectEQ Perl quest script.
-- Source: fieldofbone/Trooper_Gummin.pl
-- items: 18242, 12463, 18243

local function legion_faction(e)
	e.other:Faction(441, 5, 0)
	e.other:Faction(440, 5, 0)
	e.other:Faction(445, 5, 0)
	e.other:Faction(442, 5, 0)
	e.other:Faction(444, 5, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Beware the bone field beyond the path. It is said that the bones of a thousand fallen warriors walk its grounds at night.")
	elseif e.message:findi("sign the restraining order") then
		e.self:Say("Blast! The masters have condemned me to a life of sobriety and bloodshed! At least I still have bloodshed. But I would like one last drink. I would like a bottle of Legion Lager from Cabilis. Bring me the lager and the legion order and then I shall sign it.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18242, item2 = 12463}) then
		e.self:Emote("slowly signs the order. '...Love, Innoruuk. There you go. Now run along. Let me enjoy my last brew alone.'")
		e.other:SummonItem(18243)
		legion_faction(e)
		e.other:AddEXP(500)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18242}) then
		e.self:Say("What?! I need the Legion Lager and the legion order.")
		e.other:SummonItem(18242)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12463}) then
		e.self:Say("What?! I need the Legion Lager and the legion order.")
		e.other:SummonItem(12463)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
