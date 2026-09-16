-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Royal_Guard_Lilkus.pl
-- items: 1761, ringmail reward pool

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You tread upon sacred ground. None may go further unless they [have business with the Overlord], or, if you're looking to gain favor with the heretics and need a little coin, I have a [job] for you.")
	elseif e.message:findi("business") then
		e.self:Say("The Overlord only sees those he calls forward. If you have a summons from him, I will escort you and announce your arrival. If not, then forget whatever business you may have had here. If you wish an audience, then go speak to Sheltian below. He may be able to help you.....if you help him.")
	elseif e.message:findi("job") then
		e.self:Say("There are many campaigns we administer from within our city, Paineel. Some of these campaigns are threatened or hindered by annoyances. One of these annoyances are the kobolds that live in the filth of a cave not far from here. Find that lair and kill as many of these beasts as you can. For every kobold molar you return, you shall be rewarded.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1761}) then
		e.self:Say("Not bad, " .. e.other:GetName() .. ". Here is your reward. If you slay enough of these dogs, Sheltuin may have a more important task for you to perform.")
		if eq.ChooseRandom(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) == 1 then
			e.other:SummonItem(eq.ChooseRandom(3120, 3123, 3115, 3117, 3122, 3113, 3116, 3118, 3121, 3124, 3119, 3108, 3107, 3111, 3103, 3105, 3110, 3101, 3104, 3106, 3109, 3112, 3132, 3135, 3127, 3129, 3134, 3125, 3128, 3130, 3133, 3136, 3131))
		end
		e.other:AddEXP(2000)
		e.other:GiveCash(8, 2, 0, 0)
		e.other:Faction(231, -1, 0)
		e.other:Faction(233, -1, 0)
		e.other:Faction(265, 1, 0)
		e.other:Faction(242, -1, 0)
		e.other:Faction(254, -1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
