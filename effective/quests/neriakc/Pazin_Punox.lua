-- Modified from ProjectEQ Lua during P99 quest audit.
-- P99: https://wiki.project1999.com/Honeybugger_Assassin
-- items: 12148

function event_say(e)
	if(e.message:findi("Hail")) then
		e.self:Say("Welcome to the Hall of the Ebon Mask. You had best be a rogue or you have no business here. We have nothing to say to outsiders.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local fac = e.other:GetFaction(e.self);

	if(fac < 5 and item_lib.check_turn_in(e.trade, {item1 = 12148})) then -- Halfling Head
		e.self:Say("Foolish young elf. This was no contract from King Naythox. I wanted Lil Honeybugger killed before she gave birth to my child. Only a naive dark elf would set foot in Halfling territory. Here is your great reward: garbage from other guild exploits.");
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:neriakc  ID:42075 -- Pazin_Punox
