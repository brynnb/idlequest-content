-- Converted from ProjectEQ Perl quest script.
-- Source: cabwest/Marthor.pl
-- items: 8348, 4199

local function has_brew(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["marthor_brew"] == "1"
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("hiccups and breathes drunken breath in your face saying, Leave me be, can't you see that I am meditating or something?")
	elseif e.message:findi("master tynn") and has_brew(e) then
		e.self:Say("Supreme Master Tynn was the only one that has even seen the weapon. I do not know its origin. I tell you though, you would need to be as powerful as he was to be able to wield the weapon. Only an Iksar of the last rung would be able to use it, come back and show me you have earned your Tynnonium Shackle and I will discuss with you what I know.")
	elseif e.message:findi("tynnonium shackle") and has_brew(e) then
		e.self:Say("Veltar was one with the ways of Tynn. He did return to Cabilis, I know you have rescued him from his cell. He has traveled afar to clear his mind of his torture in the mines. He did not say where his travels would take him. You will have to find him once more and ask him about the Tynnonium Shackle he still wears.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8348, item2 = 8348, item3 = 8348, item4 = 8348}) then
		e.self:Say("Ha! How did you know my favorite drink? Master Rinmark told you? That crazy old monk spends his days sitting on that mountain in Timorous Deep doesn't he? And they call me a drunkard! Anyhow, I bet he told you about the Whistling Fists. I have never seen them myself, and have only heard legend passed down by [Master Tynn].")
		e.other:Ding()
		eq.set_timer("Brew", 300000)
		eq.set_global("marthor_brew", "1", 0, "M5")
	elseif item_lib.check_turn_in(e.trade, {item1 = 4199}) then
		e.self:Say("Ah, a monk of the final rung. You should seek Gandan Tailfist in Charasis. He, too, was seeking for a way to advance even further.")
		e.other:SummonItem(4199)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "Brew" then
		eq.stop_timer("Brew")
		eq.delete_global("marthor_brew")
	end
end
