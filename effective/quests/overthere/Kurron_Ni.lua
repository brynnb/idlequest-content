-- Source: overthere/Kurron_Ni.pl
-- Shadow Knight Epic 1.0: Kurron Ni starts the Letter to Duriek combat step.
-- Converted from ProjectEQ Perl quest script.
-- items: 3141, 3145, 3140, 18099

local letter = 0

function event_spawn(e)
	letter = 0
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Out of my way, stranger! I am on a delicate mission; interfere with my search and I shall relieve you of your head!")
	elseif e.message:findi("mission") then
		e.self:Say("My mission was to find a pathetic shadowknight and bring him closer to Innoruuk. My mission is complete! You foolish excuse for a dark knight, I shall take your head!")
		eq.attack(e.other:GetName())
	elseif e.message:findi("seek") then
		e.self:Say("I have traveled here in hopes of finding a soul worthy of assisting me in completing my mission.")
	elseif e.message:findi("i am worthy") then
		e.self:Say("I doubt it, but I have been wrong before. Before I share with you the details of my mission, however, you must first prove your worthiness. Agreed?")
	elseif e.message:findi("agreed") then
		e.self:Say("Return to me with the Darkforge breastplate, greaves and helm, plus 900 platinum.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	-- Keep cash inside the matcher so the shared transaction consumes it too.
	if item_lib.check_turn_in(e.trade, {item1 = 3141, item2 = 3145, item3 = 3140, platinum = 900}) then
		e.self:Say("Well done, " .. e.other:GetName() .. ", I honestly didn't expect to see you again. Yes, yes, this is perfect! My mission is nearly complete!")
		e.other:Faction(404, 7)
		if letter == 0 then
			e.self:AddItem(18099, 1) -- Letter to Duriek, looted after killing Kurron
			letter = 1
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
