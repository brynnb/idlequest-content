-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Thalith_Mamluk.pl
-- items: 6347, 1061

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Wha?  Rarrrr!  Thalith try to fish but with [rrrats] and you botherring him. he cannot concentrate on water!  Go away. let Thalith fish!")
	elseif e.message:findi("rats") then
		e.self:Say("Rats. Yes. Small, furry, brown, with teeth. They come, bite my paws, steal my bait, chew on lines and rods. They nasty little beasts and easy to kill but me not able to leave this position or fish get away. Errr. Maybe you keep the rats away? You kill baddest rat, Sharptooth. You bring me his tooth. I be very happy.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 6347}) then
		e.self:Say("You.. You kill the rats? Errr. Thalith thanks you. Here. Take this. It's good luck charm I've had for years.")
		e.other:SummonItem(1061)
		e.other:Faction(382, 2, 0)
		e.other:AddEXP(18000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
