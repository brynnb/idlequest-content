-- Source: hole/Caradon.pl
-- Shadow Knight Epic 1.0: Caradon spawns Kyrenna.
-- Converted from ProjectEQ Perl quest script.
-- items: 14373

function event_say(e)
	local faction = e.other:GetCharacterFactionLevel(404) -- True Spirit
	if faction >= 44 then
		if e.message:findi("hail") then
			e.self:Say("Please help me get out of here! My companion, Kyrenna, and I are trapped in this hellish place!")
		elseif e.message:findi("Who is Kyrenna") then
			e.self:Say("I was with Kyrenna when she attempted to revive the corpse of Glohnor the Valiant.")
		elseif e.message:findi("Where is Kyrenna") then
			e.self:Say("She is close by. Bring me the key to my freedom and I will betray her.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	local faction = e.other:GetCharacterFactionLevel(404) -- True Spirit
	if faction >= 44 and item_lib.check_turn_in(e.trade, {item1 = 14373}) then
		e.self:Say("Kyrenna! We are free!")
		eq.spawn2(39155, 0, 0, -195.8, 426.6, -213.9, 230) -- Kyrenna
		e.other:Faction(404, 7)
		eq.attack(e.other:GetName())
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
