-- Source: qeynos/Mespha_Tevalian.lua
-- items: 18720, 13508
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18720) then
		e.other:Message(MT.Yellow,"As you glance about the room, Mespha Tevalian greets you. 'Why hello there. Are you perhaps a new recruits? If you wish to learn the ways of the Enchanter, read the note in your inventory and hand me your note to start your training.'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Greetings.. I am Mespha Tevalian, Master Enchantress of the Hall of Sorcery and the Order of Three. Here, we all study the three circles of magic, and lend our services to citizens of Qeynos. Rumors of an underground group calling themselves the Bloodsabers have recently been spreading throughout the city. It is our duty to help local guards protect Qeynos' citizens from this new evil.");
	end
end

function event_trade(e)
	local item_lib =require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18720})) then -- Tattered Note
		e.self:Say("Greetings, " .. e.other:GetName() .. ". Welcome to the Order of Three. You have much to learn. Wear this robe and represent us well.");
		e.other:SummonItem(13508); -- Blue Training Robe*
		e.other:Ding();
		e.other:Faction(342,100,0); -- Order of Three
		e.other:Faction(221,-25,0); -- Bloodsabers
		e.other:Faction(262,15,0); -- Guards of Qeynos
		e.other:Faction(296,-15,0); -- Opal Dark Briar
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
