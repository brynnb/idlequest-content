-- Source: cabwest/Master_Kyvix.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 17024, 12848, 12420, 4262, 4263, 55978, 4264, 12853, 12852, 4265

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Quite busy!! Quite busy!! Things must be done. New components to be collected!!")
		if e.other:HasItem(4246) then
			e.self:Say("So you are expecting to earn your way to rank of revenant, eh? You shall when I have the base and stem of the candle your occultist skullcap.")
		end
	elseif e.message:findi("new components") then
		e.self:Say("Yes, yes!! I will need components from beyond the gates. I must find an apprentice of the third rank.")
	elseif e.message:findi("apprentice of the third rank") then
		e.self:Say("If you truly be an apprentice of the third circle, then there is a Dark Binder skullcap to be earned. Take this sack and fill it with a creeper cabbage, a heartsting telson with venom, brutling choppers and a scalebone femur. When they are combined within the sack, you may return it to me with your third rank skullcap and and we shall bid farewell to the title, apprentice.")
		e.other:SummonItem(17024) -- Brood Sack
	elseif e.message:findi("true mission") then
		e.self:Say("I have been waiting for a Nihilist to return. His name was Ryx and I fear his love of ale and the high seas has kept him from his mission. All I want you to do is find him. He should be disguised as a worker and he will give you a tome to bring to me. Return it with your Dark Binder Cap. I am sure that is simple enough for one as simple as you. Be sure to give him this.")
		e.other:SummonItem(12848) -- Spectacle
	elseif e.message:findi("kor sha candlestick") then
		e.self:Say("I need the foot and stem of my candlestick. The Stem comes from Sarnaks. The foot has been stolen by Gripe, in East Cabilis.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12420, item2 = 4262}) then
		e.self:Say("Well done, here's your fourth rank skull cap. You can now start your true mission.")
		e.other:AddEXP(200)
		e.other:SummonItem(4263) -- Dark Binder Skullcap
		e.other:Faction(441, 20)
		e.other:Faction(443, 20)
	elseif item_lib.check_turn_in(e.trade, {item1 = 55978, item2 = 4263}) then
		e.self:Say("Well done, here's your fifth rank skull cap. You can now track down the Kor Sha Candlestick.")
		e.other:AddEXP(200)
		e.other:SummonItem(4264) -- Occultist Skullcap
		e.other:Faction(441, 20)
		e.other:Faction(443, 20)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12853, item2 = 12852, item3 = 4264}) then
		e.self:Emote("grabs the candle parts and puts them in an odd pouch, then takes your cap which disintegrates in his palm. He hands you another cap.")
		e.self:Say("Welcome, Revenant " .. e.other:GetName() .. ". You have done well. The Harbinger awaits you. He seeks a new revenant.")
		e.other:AddEXP(200)
		e.other:SummonItem(4265) -- Revenant Skullcap
		e.other:Faction(441, 20)
		e.other:Faction(443, 20)
		e.other:GiveCash(0, 0, 6, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
