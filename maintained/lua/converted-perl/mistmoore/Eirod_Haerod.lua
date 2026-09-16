-- Converted from ProjectEQ Perl quest script.
-- Source: mistmoore/Eirod_Haerod.pl
-- items: 21972, 21973, 21974

local function has_brotherhood_symbol(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["EirodBrother"] == "1" or qglobals["EirodBrother"] == 1
end

local function reject_brotherhood_claim(e)
	e.self:Say("I am afraid I don't believe you, anyone sent by the brotherhood would most certainly bear the appropriate symbol. Leave my presence now before I get upset. I will not ask you again.")
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello " .. e.other:GetName() .. ", you are definitely a newcomer to my castle. What brings you before me today? I have some [urgent matters] to attend too.")
	elseif e.message:findi("urgent matters") then
		e.self:Say("Well you see, I am in charge of all [documents] here for Castle Mistmoore. I have a very important job and I would like to think that I do it well.")
	elseif e.message:findi("documents") then
		e.self:Say("Many documents of war and other not so pleasant matters. I was wondering if you have anything important to say or are you just going to stand here and ask me questions all day. I am waiting for a delivery [from the Indigo Brotherhood].")
	elseif e.message:findi("from the Indigo Brotherhood") then
		reject_brotherhood_claim(e)
	elseif e.message:findi("missing") then
		if has_brotherhood_symbol(e) then
			e.self:Say("That is terrible indeed, I cannot believe that he is missing. I saw him just a few days ago when he gave me these [war scripts] to review. I haven't got a chance but I do have them here somewhere.")
		else
			reject_brotherhood_claim(e)
		end
	elseif e.message:findi("war scripts") then
		if has_brotherhood_symbol(e) then
			e.self:Say("Secret war scripts of course but I would be willing to give them to you after all because Gerod seals them and I have not yet opened the last ones he brought me. I haven't even gotten a chance to open them up myself. If you will bring me 2 Brownie Torsos, I will be more than happy to present you with these documents in hopes that they will assist in the investigation.")
		else
			reject_brotherhood_claim(e)
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 21972}) then
		e.self:Say("I see you must be trusted by the brotherhood to get this far. Well I would imagine that you are here to deliver [Gerod's] documents are you not? I have heard rumors of him also being [missing], I certainly hope those rumors were unfounded.")
		eq.set_global("EirodBrother", "1", 0, "F")
	elseif item_lib.check_turn_in(e.trade, {item1 = 21973, item2 = 21973}) then
		if has_brotherhood_symbol(e) then
			e.self:Say("Well then it seems you are pretty driven on helping the brotherhood find out what has become of Gerod. I commend you on your persistence. Please take these sealed documents back to the brotherhood, I certainly hope that they can aid in the investigation.")
			e.other:SummonItem(21974)
			eq.delete_global("EirodBrother")
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
