-- IdleQuest-authored Lua from P99 quest documentation.
-- P99: https://wiki.project1999.com/Iksar_Prisoner_Quest
-- items: 14812, 14814

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Please, brother! Get me out of these chains so that I may escape back to Cabilis! They intend to coerce me like the others. A more tragic fate no Iksar should endure. I implore you to [help] me!");
	elseif(e.message:findi("help")) then
		e.self:Say("Well some of the brainwashed short ones seem to know much of mechanical devices and such. Perhaps they have a tool that can get me out of these chains. If they have anything that looks useful bring it to me. I'm sure your help will be rewarded once I reach Cabilis.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local fac = e.other:GetFaction(e.self);

	if(fac <= 5 and item_lib.check_turn_in(e.trade, {item1 = 14812})) then -- Serrated Wire
		e.self:Say("The Iksar prisoner takes the wire and quickly saws through the rusted shackles. He hands you an icon and says as he runs off, 'Show that to the Arch Duke in Cabilis! He will reward you. Now I'm off to escape!'");
		e.other:SummonItem(14814); -- Greenmist Icon
		e.other:Ding();
		e.other:AddEXP(1000);
		eq.depop_with_timer();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
