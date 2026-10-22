-- enabled: false
-- P99 source-only scope exclusion: later_beastlord_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Elder_Patriarch_Ixthal.pl
-- items: 48060, 12844, 12845, 12633, 48045, 48046, 48051, 48047, 48061, 48048, 48064, 48065, 48066, 48067, 48049

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("'Hello to you as well. I am Elder Patriarch Ixthal and I continue training when the Prime Patriarch becomes overwhelmed with duties. I will train you if you seek to one day [become a Patriarch of Cabilis].")
	elseif e.message:findi("become a patriarch of cabilis") then
		e.self:Say("I thought you might. I can sense your spirit is strong. For your first mission, you will need to use the spirits to guide you to collect some [rare items] we need on a daily basis in order to keep up with the demands of the city. This mission will also be great [training] for you.")
	elseif e.message:findi("rare items") then
		e.self:Say("We gather several items that we trade with the Hierophants. These items include a cracked femur, creeper cabbage, and lichenclover. Once you have all of these items, return them to me with your Claw of the Cub and you shall be rewarded.")
	elseif e.message:findi("continue training") then
		e.self:Say("That's the spirit. For your next task we will require you to show your skills at locating a [missing member] of the Patriarchs of Cabilis.")
	elseif e.message:findi("missing member") then
		e.self:Say("His name is Welgaz and he tends to roam the continent in search of a perfect training area. We have not heard back from him in a while now and we grow worried. You must now go forth and find him. Tell him I have sent you to find him.")
	elseif e.message:findi("aid our cause") then
		e.self:Say("I thought you may, " .. e.other:GetName() .. ". We have an issue at hand that you may be able to help with. It seems as though there are rumors of the sarnak factions gathering forces. We must find out all the information we can regarding this situation. Travel to the kly's and seek what they know. Place all of their letters in this tome, which shall combine their mystical energies. Bring back the completed message to me with your claw of the apprentice and you will be rewarded.")
		e.other:SummonItem(48060)
	elseif e.message:findi("attack") then
		e.self:Say("I have heard of no such attacks. We are safe within these walls. Zreezas is just paranoid.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12844, item2 = 12845, item3 = 12633, item4 = 48045}) then
		e.self:Say("You have returned unharmed with the items I asked for. Here is your reward now. If you wish to [continue training] please let me know.")
		e.other:SummonItem(48046)
		e.other:AddEXP(1000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 48051, item2 = 48046}) then
		e.self:Say("Because of you, we now know that Welgaz is safe and will be returning to us shortly. Take this to represent our appreciation for your deeds completed here today. Please return soon once you have decided to [aid the cause].")
		e.other:SummonItem(48047)
		e.other:AddEXP(2000)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 48061, item2 = 48047}) then
		e.self:Say("I see you have returned with the information asked. Hmm . . . this doesn't bode well. I will need some time to think about the situation now. Take this and wear it proudly. You are a Young Patriarch now.")
		e.other:AddEXP(4000)
		e.other:SummonItem(48048)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 48064}) then
		e.self:Say("I can't believe this! We have a traitor in our midst after all... Thanks to you, Young Patriarch, we seem to have a headstart. You should go find rankings from three close to the traitor so that they may reveal his location. Bring me the proof about the location of the trader and you shall be rewarded.")
		e.other:AddEXP(10000)
	elseif item_lib.check_turn_in(e.trade, {item1 = 48065, item2 = 48066, item3 = 48067, item4 = 48048}) then
		e.self:Say("Excellent work, " .. e.other:GetName() .. ". You have proven yourself well. I hope you did not show them any mercy... I think you have matured and you deserve to be recognized for your bravery.")
		e.other:SummonItem(48049)
		e.other:AddEXP(25000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
