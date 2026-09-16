-- Converted from ProjectEQ Perl quest script.
-- Source: frontiermtns/an_enslaved_iksar.pl
-- items: 12708, 12712, 12713, 12714

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("looks up at you. You can tell his spirit is broken. His scars speak of a severe beating.")
	elseif e.message:findi("Vok Na Zov") then
		e.self:Say("Forget them. I believe all six scrolls lie in the [Kaesora Library] and that is no safe place for any explorer. The scrolls are not readable by any livng person, but I came here in search of a machine which may be able to decipher them, the [Stupendous Contraption]. Should you return to Cabilis, see that the Arch Duke hears of the scrolls.")
	elseif e.message:findi("kaesora library") then
		e.self:Say("Oh!! You heard of the ancient library I discovered in Kaesora? I think the six scrolls of [Vok Na Zov] may lie there. I have not yet actually found the location of the library and it's very dangerous to lurk within the ruins of Kaesora. I would not venture there if I were you.")
	elseif e.message:findi("stupendous contraption") then
		e.self:Say("I have learned it was a machine tinkered by a legendary gnome. It has many uses. It lies in the slave pens of Droga. Perhaps it may be used to decipher the [Scrolls of Vok Na Zov]. I have leearned that it will not work without a [contraption needle]. Luckily I have found one in my journies.")
	elseif e.message:findi("contraption needle") then
		e.self:Say("The contraption needle is a piece of the machine, the [Stupendous Contraption]. It won't operate without it and if you want it, you're going to have to bring me the [pen keys].")
	elseif e.message:findi("pen keys") then
		e.self:Say("Pen keys!! I need the pen keys to get out of here! Find the ones who hold these keys. Bring me the key to pen number 1 and both keys to the pen gates. Do so and I shall give you the [contraption needle].")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12708, item2 = 12712, item3 = 12713}) then
		e.self:Emote("escapes with a flash, but before he goes, he speaks, 'At last!! The keys which shall bring me freedom! I thank you and here is the contraption needle. Good luck.'")
		e.other:SummonItem(12714)
		e.other:AddEXP(2000)
		e.other:Ding()
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
