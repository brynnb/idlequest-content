-- Modified from ProjectEQ Lua during P99 quest audit.
-- P99: https://wiki.project1999.com/Hukulk%27s_Love
-- P99: https://wiki.project1999.com/Lynuga%27s_Gem_Collection
-- items: 10035, 10080, 10081, 10082

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hrrump?! Who you? " .. e.other:GetName() .. "? What you want with Lynuga? Me am out [collecting]. Leave me be!");
	elseif(e.message:findi("collecting")) then
		e.self:Say("I collect all sort's of thing's. Gem's be my favorite. Me really like rubies. If you have ruby, give to me! Why you want to know? You want to steal my collection?!? I squish you if you do!!");
	elseif(e.message:findi("happy love bracers")) then
		e.self:Say("Happy love bracers! Dem ugly tings! Me gave dem to old flame in Neriak. Him old news now. Me let him keep dem ugly green tings.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 10035})) then -- Ruby
		e.self:Say("Mmm. Ruby!! Me thank's you! Here take this, me got it off dead someone who try take my collection. Me think's this valuable thing..");
		local item_random = math.random(100);
		if item_random == 1 then
			e.other:SummonItem(10082, 6); -- Ivandyr's Hoop
		elseif item_random <= 10 then
			e.other:SummonItem(10081, 5); -- Midnight Mallet
		else
			e.other:SummonItem(10080); -- Brutechopper
		end
		e.other:Ding();
		e.other:Faction(222,1,0); -- Broken Skull Clan
		e.other:Faction(308,-1,0); -- Shadowknights of Night Keep
		e.other:Faction(235,-1,0); -- DaBashers
		e.other:AddEXP(500);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
