-- Source: qeytoqrg/Marton_Sayer.lua
-- P99: https://wiki.project1999.com/The_Gnoll_Slayer
-- items: 12204, 5416

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Welcome. Please stock up on provisions, especially if you are headed toward the lair of the vile gnolls. If so, I wish you much luck and many gnoll pelts!! I also have knowledge of a [powerful dog]. I pray you do not encounter him.");
	elseif(e.message:findi("powerful dog")) then
		e.self:Say("I have encountered a gnoll who spoke the common tongue. He dared to call himself Lord Elgnub. He swore that some day we would cross paths and he would snatch my infant son Joseph from our home. He would stand no chance against me and the mighty [Gnoll Slayer].");
	elseif(e.message:findi("gnoll slayer")) then
		e.self:Say("Gnoll Slayer is the mighty longsword which was passed down unto me through generations of Sayers. My days of battle are over, but I can still wield her with ferocity. The only thing more precious would be my son, Joseph Sayer. I would trade Gnoll Slayer only for him to be safe and sound at home.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 12204})) then -- Baby Joseph Sayer
		e.self:Say("Baby Joseph!! Look, Momma!! Baby Joseph has been rescued by this good adventurer!! That evil Lord Elgnub made good on his word and snatched my son from under our noses. You saved the day!! For this you shall wield 'Gnoll Slayer'!!");
		e.other:SummonItem(5416); -- Gnoll Slayer
		e.other:Ding();
		e.other:Faction(291,20,0); -- Merchants of Qeynos
		e.other:Faction(223,-4,0); -- Circle of Unseen Hands
		e.other:Faction(219,3,0); -- Antonius Bayle
		e.other:Faction(229,2,0); -- Coalition of Tradefolk
		e.other:Faction(262,4,0); -- Guards of Qeynos
		e.other:AddEXP(500);
		e.other:GiveCash(0,0,0,1);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
