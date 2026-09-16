-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Abigail.pl
-- items: 12309, 12299

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings! I am the holder of the secret of the [Breastplate of Ro]. You may rest here. You are quite safe within this camp of paladins.")
	elseif e.other:GetModCharacterFactionLevel(226) < 25 then
		e.self:Say("You need to prove your loyalty to my temple. Go to Felwithe and seek out the Clerics of Tunare. Prove to them your faith. Then ask the leader of this church if you are a [honored member].")
	elseif e.message:findi("breastplate of ro") then
		e.self:Say("The Breastplate of Ro mold will be awarded to you. First, you will perform a test of strength. Go to Faydwer. There you shall seek out and destroy the Teir'Dal who carry the dark cauldrons!! They have been venturing into our lands and capturing many Koada'Dal and Fier'Dal for cooking purposes! Bring to me two of their dark cauldrons.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:GetModCharacterFactionLevel(226) > 24 and item_lib.check_turn_in(e.trade, {item1 = 12309, item2 = 12309}) then
		e.self:Say("You have earned the mold. You will now need go and speak with Thomas about [Lord Searfire].")
		e.other:SummonItem(12299)
		e.other:Faction(226, 20, 0)
		e.other:Faction(279, 20, 0)
	elseif e.other:GetModCharacterFactionLevel(226) > 24 and item_lib.check_turn_in(e.trade, {item1 = 12309}) then
		e.self:Say("I instructed you to return with no less than two dark pots.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
