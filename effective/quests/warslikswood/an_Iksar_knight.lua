-- Converted from ProjectEQ Perl quest script.
-- Source: warslikswood/an_Iksar_knight.pl
-- items: 12492, 12493, 12494, 6026, 12496

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("wipes the sweat from his forehead and spits some flarefire seeds on the ground near your feet. 'Whew!! Good to be back and safe at the Cabilis Gate. The troopers will protect us.'")
	elseif e.message:findi("chalp diagram") then
		e.self:Emote("spits out some flarefire seeds. 'Great!! Sent to retrieve the Chalp diagram. I will give them to you, but I want you to do me a little favor first. I want you to [retrieve some spells] I lost. They are incorrectly scribed and useless, but I yearn for their return nonetheless.'")
	elseif e.message:findi("retrieve some spells") then
		e.self:Emote("spits flarefire seeds on you. 'Oops!! Sorry. Yeah!! You go to Chalp and get two incorrectly scribed spells which they grabbed from me. The third one, I threw in a river crossing by Chalp. It was in a bottle and probably drifted way down the river. Bring me all three and also a shovel and I will make it worth your while.'")
	elseif e.message:findi("flarefire seeds") then
		e.self:Emote("spits some flarefire seeds on your face. 'What? Interested in flarefire seeds? There you go. Ha!!'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12492, item2 = 12493, item3 = 12494, item4 = 6026}) then
		e.self:Emote("accidently swallows a mouthful of flarefire seeds. 'ACCCKK!!  I can't believe you did it!! Here is the Chalp diagram.'")
		e.other:SummonItem(12496)
		e.other:AddEXP(1000)
		e.other:Ding()
		e.other:Faction(442, 20, 0)
		e.other:Faction(441, 10, 0)
		eq.depop_with_timer()
	else
		e.self:Emote("spits flarefire seeds on your chest. 'Listen up!! I asked for the misscribed spells; Fear, Lifetap and Gate, and also, a shovel.'")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
