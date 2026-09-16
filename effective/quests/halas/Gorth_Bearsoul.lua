-- Source: halas/Gorth_Bearsoul.lua
-- items: 7113

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail. yerself. I'm sure ye've better things to do than to bother a man makin' his potions. then. eh?");
	elseif(e.message:findi("potion of sorrow")) then
		e.self:Say("Ach! What'd ye be needin' that fer? Only those of dark magicks require such a thing and by me mother's eyes, never could I sell to such a soul. If yer soul be clean, then put yer [money] in this enchanted pouch and I will know yer intent. If yer soul be rotten, I'll be knowin', and ye'll be dead. Tis indifferent I'd better be to yer actions.");
	elseif(e.message:findi("money")) then
		e.self:Say("Sure'n ye dinnae think I'd give ye a potion fer free, then? I'll be needin' five hundred gold coins to make such an item. 'Tis hard t' make and few are the uses fer such a potion.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {gold = 500})) then
		e.self:Say("Aye. I guess ye truly are a good soul. Good luck on whatever ye needed such a dread item fer.");
		e.other:SummonItem(7113); -- Potion of Sorrow
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
