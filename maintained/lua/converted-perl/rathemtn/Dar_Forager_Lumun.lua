-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Dar_Forager_Lumun.pl
-- items: 12084, 12085, 12086, 13753, 13754, 13755, 13750, 13751, 13752

local function is_froglok(e)
	return e.other:GetRaceName() == "Froglok"
end

local function exchange(e, reward)
	e.self:Say("Hmm. . . That seems like a fair trade. Let me see what I've got in my satchel. No. Wait, yes! I do have a fine specimen here that I think you'll agree is of superior quality.")
	e.other:AddEXP(150)
	e.other:SummonItem(reward)
end

function event_say(e)
	if not is_froglok(e) then
		return
	end
	if e.message:findi("hail") then
		e.self:Say("Nice to meet you, " .. e.other:GetName() .. "! Please have a look at my wares, I have taken great pains to brings only the best that the mountains have to offer. Or perhaps you are here to make an [exchange]?")
	elseif e.message:findi("exchange") then
		e.self:Say("I am always in need of more skins, so I will swap three identical unruined pelts for one of my higher quality versions.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if is_froglok(e) then
		if item_lib.check_turn_in(e.trade, {item1 = 12084, item2 = 12084, item3 = 12084}) then
			exchange(e, 12085)
		elseif item_lib.check_turn_in(e.trade, {item1 = 12085, item2 = 12085, item3 = 12085}) then
			exchange(e, 12086)
		elseif item_lib.check_turn_in(e.trade, {item1 = 13753, item2 = 13753, item3 = 13753}) then
			exchange(e, 13754)
		elseif item_lib.check_turn_in(e.trade, {item1 = 13754, item2 = 13754, item3 = 13754}) then
			exchange(e, 13755)
		elseif item_lib.check_turn_in(e.trade, {item1 = 13750, item2 = 13750, item3 = 13750}) then
			exchange(e, 13751)
		elseif item_lib.check_turn_in(e.trade, {item1 = 13751, item2 = 13751, item3 = 13751}) then
			exchange(e, 13752)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
