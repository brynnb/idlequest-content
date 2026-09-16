-- Source: qeynos/Gahlith_Wrannstad.lua
-- items: 18718, 13508
function event_spawn(e)

	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
	
end

function event_enter(e)

	if e.other:HasItem(18718) then
		e.other:Message(MT.Yellow,"As you glance about the crowded room, Gahlith Wrannstad greets you. 'Why hello there. Are you perhaps a new recruits? If you wish to learn the ways of the Wizard, read the note in your inventory and hand me your note to start your training.'");
	end
	
end

function event_say(e)

	
end

function event_trade(e)

	local item_lib =require("items");
	
	if(item_lib.check_turn_in(e.trade, {item1 = 18718})) then -- Tattered Note
		e.self:Say("Greetings, I am Gahlith, Master of the Wizard's Order of the Hall of Sorcery. Here, we have devoted our lives and souls to the study of the arcane. My apprentice Kazlo Naedra shall tutor you and teach you the foundations and fundamentals of sorcery. You should visit Unsar also, I believe he's having difficulty with a new spell he's been tinkering with.");
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
