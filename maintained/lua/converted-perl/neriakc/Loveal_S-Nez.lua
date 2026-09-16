-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Loveal_S-Nez.pl
-- P99 audit: Sir Lindeal's Testimony
-- items: 18828, 2317, 13390, 5374, 18889, 13009, 13005, 13002

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What is this I see before me? A would-be hero of the Dead? You reek of false bravado. I have seen others much stronger than you meet their fate at the end of a blade. I see no reason to continue our conversation. How can one such as you assist with my [delegated duties]?")
	elseif e.message:findi("delegated duties") then
		e.self:Say("Why do you ask? I know why. Glory has captured your affections. Those who seek glory find death. Still, you may be of some use. Before I assign you a task, I must be assured of your power. I require you to [perform a test].")
	elseif e.message:findi("perform a test") then
		if e.other:GetFaction(e.self) >= 5 then
			e.self:Say("How dare you enter my presence?! In the name of the Dead I should strike you down!")
		else
			e.self:Say("In the Lavastorm Mountain Range there have been sightings of a paladin, one Sir Lindeal. He has compromised our routes between.. well, that is none of your concern. All you need to know is that this paladin of the Temple of Marr must be sent to his everlasting life. Do so and prove your worth to us. I await your proof. Use no assistance. If you are truly his equal then I shall know. I know all.")
		end
	elseif e.message:findi("thex mallet") then
		e.self:Say("All you can know is that the Thex Mallet is desired by our Queen. If we are not successful in its retrieval, it will be our heads which adorn her trophy room. We have learned its location and believe it to be broken into three separate pieces.")
	elseif e.message:findi("queen cristanos thex") then
		e.self:Say("The Queen of the Teir'Dal is the most powerful of all. It is she who should sit on the throne and not King Naythox. The Dead are her humble servants. We await the day when she shall finally take her rightful position as ruler of Neriak.")
	elseif e.message:findi("king naythox thex") then
		e.self:Say("A competent and powerful warrior, but a warrior nonetheless. He has suppressed the true glory of the Teir'Dal. Perhaps it is time for a new ruler of Neriak.")
	elseif e.message:findi("appointed tasks") then
		e.self:Say("Very well. You have gained the appropriate power. I require you to journey to the Commonlands and seek out Kizdean Gix. He is a member of a very important force. Tell him 'Utalk Adarev Otcin'. Remember this password.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18828}) then
		if e.other:GetFaction(e.self) >= 5 then
			e.self:Say("How dare you enter my presence?! In the name of the Dead I should strike you down!")
			e.other:SummonItem(18828)
		else
			e.self:Say("So you have succeeded where others have failed. You show promise. Take this then. You shall be a valuable asset to the Dead and soon this shall be of value to one so great. This will help you on your way. Are you still interested in my [appointed tasks]?")
			e.other:SummonItem(2317)
			e.other:GiveCash(0, 0, 14, 0)
			e.other:AddEXP(33750)
			e.other:Ding()
			e.other:Faction(239, 25, 0)
			e.other:Faction(303, 3, 0)
			e.other:Faction(278, -3, 0)
			e.other:Faction(275, -3, 0)
			e.other:Faction(245, -3, 0)
			e.other:Faction(1522, -50, 0)
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 13390}) then
		e.self:Say("Oh how grand it is!! Look at it!! I feel the power trembling within. Who would have thought such an item would be abandoned? You have performed supremely. Queen Cristanos shall reward me greatly and I shall reward you greatly. Here is my weapon from years past.. the Reaper of the Dead. I believe it has one soul still trapped within.")
		e.other:SummonItem(5374)
		e.other:AddEXP(33750)
		e.other:Ding()
		e.other:Faction(239, 100, 0)
		e.other:Faction(303, 15, 0)
		e.other:Faction(278, -15, 0)
		e.other:Faction(275, -15, 0)
		e.other:Faction(245, -15, 0)
		e.other:Faction(1522, -200, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18889}) then
		e.self:Say("I see my expeditionary unit has encountered problems. I must send a dragoon unit to Befallen at once. I must not allow the [Thex Mallet] to fall into the hands of some simple adventurer. Here is payment for your quick service.")
		e.other:GiveCash(4, 0, 0, 0)
		e.other:SummonItem(13009, 2)
		e.other:SummonItem(13005, 2)
		e.other:SummonItem(13002)
		e.other:AddEXP(100)
		e.other:Ding()
		e.other:Faction(239, 10, 0)
		e.other:Faction(303, 1, 0)
		e.other:Faction(278, -1, 0)
		e.other:Faction(275, -1, 0)
		e.other:Faction(245, -1, 0)
		e.other:Faction(1522, -20, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
