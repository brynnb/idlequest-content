-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Urkath_Greyface.pl
-- items: 1155, 2045

local function faction_ok(e)
	return e.other:GetFaction(e.self) <= 7 -- dubious or better
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Errr?  What you say to Urrrkath?  Ah.  Hello to you as well. furrrless type person. Would you do Urrrkath a [favor]?")
	elseif e.message:findi("favor") then
		e.self:Say("Grrreatful I am that you would think to do this for me.  I am in need of a special leaf, called a [Sylvani Leaf], if you could brrrring this to me I would rrrrreward you verrrry well.")
	elseif e.message:findi("sylvani leaf") then
		e.self:Say("They say that the leaf only exists in a small forest farrrrr frrrrrom ourrrrrr island")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1155}) then
		if not faction_ok(e) then
			e.self:Say("Errr... Urrrkath does not know you well enough for such favors.")
			e.other:SummonItem(1155) -- Sylvani Leaf
		else
			e.self:Say("Excellent!! I can't believe you found it.  Herrre is the rrrreward I promised you.")
			e.other:SummonItem(2045)
			e.other:Faction(382, 5, 0) -- Kerra Isle
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
