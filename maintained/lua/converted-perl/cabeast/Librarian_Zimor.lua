-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Librarian_Zimor.pl
-- items: 3887, 3895, 3893, 18320

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, citizen, I hope that you are here to assist. We are gathering Crusaders to make an assault on the Libraries of Chardok. The slave creations have thrived in their sanctuary for too long. The tomes and texts they have stolen to fill their library belong us. They are even rumored to have a text on the Sacred Khukri of Rile, the Greenmist. If you see such a tome, you must bring it to me immediately. May Cazic-Thule guide you!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 3887}) then
		e.self:Emote("looks disturbed as he examines the book. His hands tremble as he mouths the words on the ancient parchment pages. 'This book may alter the reality you see before you,' the scholar says as he continues to read the tome. 'The information that has been waiting in this book may have been brought to us by your hand, but your fate has obviously been chosen by our Lord. Our mystics have conveyed a new vision to us in this most recent season. Please take this note to Hierophant Oxyn, while I continue to translate this tome.' the Librarian hands you a note and turns his attention back to the book.")
		e.other:SummonItem(3895) -- Note to Oxyn
		e.other:AddEXP(5000)
		e.other:Ding()
		e.other:Faction(442, 20, 0) -- Crusaders of Greenmist
		e.other:Faction(441, 10, 0) -- Legion of Cabilis
	elseif item_lib.check_turn_in(e.trade, {item1 = 3893}) then
		e.self:Say("I am very glad you have returned. Your discovery of the tynnonium is extraordinary! This Sarnak tome has been an incredible source of information. It appears that they have been studying the Greenmist for some time. I'm sure they sought it as nothing more than a trinket to be collected. Their shortsightedness will be their eventual undoing. I have compiled a book of notes that will aid you in your quest for the Greenmist. Please take care to keep this information out of the grasp of our enemies.")
		e.other:SummonItem(18320) -- Notes from the Greenmist Tome
		e.other:AddEXP(5000)
		e.other:Ding()
		e.other:Faction(442, 20, 0) -- Crusaders of Greenmist
		e.other:Faction(441, 10, 0) -- Legion of Cabilis
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
