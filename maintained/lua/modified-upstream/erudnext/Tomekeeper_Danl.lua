-- Source: erudnext/Tomekeeper_Danl.lua
-- P99 epic 1.0 only. Imported Vortix/48132 branches belong to epic 1.5;
-- overrides are executable source, not automatically filtered by the importer.
-- Eligibility must precede consuming the hand-in.
-- items: 18195, 1682
function event_say(e)
	if(e.other:GetLevel() >= 46 and e.other:Class() == "Monk") then
		-- monk epic 1.0
		if(e.message:findi("hail")) then
			e.self:Say("Good day, citizen. Please remember to keep your voice down in our library. Feel free to browse the extensive collection of books we have on display. Learning is all about you. Our library is the greatest collection of educational literature in the world, as you can no doubt see. If you come across any [" .. eq.say_link("rare finds") .. "] we may be interested in purchasing them.");
		elseif(e.message:findi("rare find")) then
			e.self:Say("Yes, any rare books, tomes, essays, or other literature you find may be of interest to me. Although the finds I am interested in are quite high profile and would most likely only be found in the possession of very powerful or influential beings. Give me what you find and I will pay you what it is worth to us.");
		elseif(e.message:findi("lheao")) then
			e.self:Say("Lheao was my predecessor here at the library of Erudin. He has since retired, just a few years ago. Im sure he would be most impressed with your find and other insightful conversation on the subject. Although Im not sure one of your profession would be interested in such a scholarly endeavor, no offense. If you are interested, find him and tell him you found the book Immortals. Im not sure where he has retired to, but I hear it is near an ocean somewhere.");
		end
	else
		if(e.message:findi("hail")) then
			e.self:Say("Good day, citizen. Please remember to keep your voice down in our library. Feel free to browse the extensive collection of books we have on display. Learning is all about you. Our library is the greatest collection of educational literature in the world, as you can no doubt see. Return to me again when you are an experienced monk.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(e.other:GetLevel() >= 46 and e.other:Class() == "Monk" and item_lib.check_turn_in(e.trade, {item1 = 18195})) then
		e.self:Emote("gasps at the sight of the rare book. 'This is a great find indeed! I can only imagine who you had to.. persuade to give you the book. Our library would be very interested in acquiring this and I am prepared to give you this referral that marks you as a friend of the library. If only [" .. eq.say_link("Lheao") .. "] could see this.'");
		e.other:SummonItem(1682); -- Danl's Reference
		e.other:Ding();
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

-- End of File
