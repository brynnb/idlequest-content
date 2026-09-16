-- Cleric Epic 1.0: Lake Rathe Natasha accepts Damaged Goblin Crown.
-- Merges the ProjectEQ numeric 51138.pl signal encounter behavior with the
-- IdleQuest-authored final hand-in for the named #Natasha_Whitewater script.
-- items: 28046, 28047

function event_spawn(e)
	eq.zone_emote(MT.Shout, "The Triumvirate of Water has decreed your fate, Shmendrik Lavawalker!! I am here to deliver said fate!!")
	eq.signal(51012, 99, 2000) -- Shmendrik_Lavawalker
	eq.set_timer("depop", 300000)
end

function event_timer(e)
	if e.timer == "depop" then
		eq.depop()
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The Riptide goblins must have their crown returned to them. If you would be so kind as to give me the crown I will make sure that it reaches them.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 28046}) then
		e.self:Say("I will have this crown returned to the Riptide Goblins immediately! Should you ever come across an Erudite named Omat Vastsea, give him this sea shell. The waters of Norrath shimmer with awareness of your deeds here today!")
		e.other:SummonItem(28047) -- Ornate Sea Shell
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	if e.signal == 199 then
		e.self:Say("Enough!! Your existence has come to an end!")
		eq.signal(51012, 299, 2000) -- Shmendrik_Lavawalker
	elseif e.signal == 399 then
		e.self:Say("This conflict has been destined by the waters of the Triumvirate!")
		eq.signal(51012, 499, 2000) -- Shmendrik_Lavawalker
	elseif e.signal == 599 then
		eq.spawn2(51145, 0, 0, 33, 3619, 51, 0) -- a_spirit_of_flame
	end
end
