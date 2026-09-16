-- Source: firiona/Foloal_Stormforest.pl
-- Ranger Epic 1.0: Foloal combines the stones.
-- Converted from ProjectEQ Perl quest script.
-- items: 20462, 20461, 20468

function event_say(e)
	if e.message:findi("are you one such as myself") then
		e.self:Emote("stares at you and whispers.")
	elseif e.message:findi("venril sathir") then
		e.self:Say("Find him and remove him from the face of this earth. Bring me the half of the stone I know you have and whatever conduit of power you find on his rotting corpse.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20462, item2 = 20461}) then
		e.self:Emote("carefully takes the stones from you.")
		e.other:SummonItem(20468) -- Warmly Glowing Stone
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
