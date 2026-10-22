-- Modified from ProjectEQ Lua during P99 quest audit.
-- P99: https://wiki.project1999.com/Ice_Goblin_Necklaces
-- items: 17944, 12223, 7322, 13898, 13002, 13003, 13004, 13005, 13006, 13007, 13915

function event_say(e)
	local fac = e.other:GetFaction(e.self);

	if(e.message:findi("Hail")) then
		e.self:Say("Hail! Ye've come to [serve Halas], have ye not? We're the Wolves o' the North and it is our task to defend our city from harm.");
	elseif(e.message:findi("serve halas")) then
		e.self:Say("Halas is surrounded by barren arctic tundra. We've many foes. Among them are the [orc troopers], [ice goblins] and the ever-present polar bears.");
	elseif(e.message:findi("orc troopers")) then
		e.self:Say("So. Ye think yerself strong enough to battle the snow orc troopers?  I pray to the Tribunal that ye are.  If ye can return to me four wrath orc wristbands  from the troopers' bodies. I'll reward ye with the [Seax].");
	elseif(e.message:findi("ice goblins")) then
		e.self:Say("The ice goblins have plagued our community fer some time now.  At times, they even manage to get inside our walls. Fer the most part, they prey on travelers who pass through Everfrost Peaks. Since they're a weak race, we employ our youngest warriors to [protect the pass].");
	elseif(e.message:findi("what seax") or string.lower(e.message) == "seax") then
		e.self:Say("The Seax is a Northman warrior's piercing weapon.  Dinnae confuse this with another [weapon] related to the Seax called the Langseax.  The local rogues have also learned to master the Seax.  I'll only offer it to those who battle the [orc troopers].");
	elseif(e.message:findi("gnoll bounty")) then
		e.self:Say("I've placed a bounty on the gnolls o'Blackburrow.  Their whelps have invaded our land and we must carry the fight into their dens.  Join the fight and return three gnoll fangs as proof of yer victory in Blackburrow.  Do so, and earn the respect o' the Wolves o' the North.");
	elseif(fac <= 5 and e.message:findi("protect the pass")) then
		e.self:Say("Then travel to the Everfrost Peaks and take this pack with ye. I want ye to return this pack to me when it is filled with the beaded ice necklaces o' the ice goblins. When it is filled, combine the items and return it to me and I'll decide whether ye deserve a reward fer yer deed.");
		e.other:SummonItem(17944); -- Empty Bag
	end
end

function event_trade(e)
	local item_lib = require("items");
	local fac = e.other:GetFaction(e.self);

	if(item_lib.check_turn_in(e.trade, {item1 = 12223, item2 = 12223, item3 = 12223, item4 = 12223})) then
		e.self:Say("Well done! You've proved yerself worthy o' this!");
		e.other:SummonItem(7322); -- Seax
		e.other:AddEXP(3000);
		e.other:Ding();
		e.other:Faction(320,5,0); -- Wolves of the North
		e.other:Faction(327,5,0); -- Shamen of Justice
		e.other:Faction(328,5,0); -- Merchants of Halas
		e.other:Faction(311,5,0); -- Steel Warriors
	elseif(fac <= 5 and item_lib.check_turn_in(e.trade, {item1 = 13898})) then -- Bag of Ice Necklaces
		e.self:Say("Ye've done well, me young warrior. We've gathered these to add to yer provisions. While in the Everfrost Peaks, be on the watch fer any gnolls ye may find. I declare there to be a [gnoll bounty].");
		e.other:AddEXP(3800);
		e.other:GiveCash(0,0,3,0);
		e.other:Ding();
		e.other:SummonItem(eq.ChooseRandom(13005, 13004, 13007, 13003, 13002, 13006)); -- Provisions
		e.other:Faction(320,5,0); -- Wolves of the North
		e.other:Faction(327,5,0); -- Shamen of Justice
		e.other:Faction(328,5,0); -- Merchants of Halas
		e.other:Faction(311,5,0); -- Steel Warriors
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13915, item2 = 13915, item3 = 13915})) then -- Gnoll Fangs
		e.self:Say("Fine work, fine work!  The gnoll threat must be extinguished before it can ever fully grow.  Ye've done yer part to aid our cause.  Please allow me to repay ye with a few provisions and a wee bit o' coin.  Then, continue with yer good deeds.");
		e.other:AddEXP(8000);
		e.other:GiveCash(0,0,5,0);
		e.other:Ding();
		e.other:SummonItem(13005,1); -- Iron Ration
		e.other:Faction(320,15,0); -- Wolves of the North
		e.other:Faction(327,3,0); -- Shamen of Justice
		e.other:Faction(328,3,0); -- Merchants of Halas
		e.other:Faction(311,1,0); -- Steel Warriors
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
