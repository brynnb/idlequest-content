-- Converted from ProjectEQ Perl quest script.
-- Source: kaladima/Priest_of_Discord.pl
-- items: 18700

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings. " .. e.other:GetCleanName() .. " .  Are you a child of Order?  If you have come seeking the path of Discord. I require only that you give me your [Tome of Order and Discord] and I shall show you the way.  Only then will you be freed from Order's confining restraints.")
	elseif e.message:findi("tome") then
		e.self:Say("The Tome of Order and Discord was penned by the seventh member of the Tribunal and has become the key to a life of Discord. in spite of the author's pitiful warnings.  Do you not have one. child of Order?  Would you [like to read] it?")
	elseif e.message:findi("read") then
		e.self:Say("Very well.  Here you go.  Simply return it to me to be released from the chains of Order. Your PvP has been disabled.")
		e.other:SetPVP(false)
		e.other:SummonItem(18700) -- Tome of Order and Discord
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18700}) then
		e.self:Say("I see you wish to join us in Discord! Welcome! By turning your back on the protection of Order you are now open to many more opportunities for glory and power. Remember that you can now be harmed by those who have also heard the call of Discord.")
		e.other:SetPVP(true)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
