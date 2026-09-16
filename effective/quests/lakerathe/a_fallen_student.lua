-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/a_fallen_student.pl
-- items: 48122, 48100, 48101, 48102

local function qglobal(e, key)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals[key]
end

function event_say(e)
	local monk_epic = qglobal(e, "monk_epic")
	local mnk_pre = qglobal(e, "MnkPre")

	if e.message:findi("hail") then
		if monk_epic == nil then
			eq.zone_emote(MT.Emote, "As you look at this individual, you can tell he has something bothering him greatly.")
			e.self:Say("Eh? There is nothing I can help you with. I have nothing for myself anymore... except these [cursed dreams].")
			if e.other:HasItem(10652) or mnk_pre == "3" then
				eq.set_global("monk_epic", "1", 5, "F")
			elseif mnk_pre == nil then
				eq.set_global("MnkPre", "1", 5, "F")
			end
		elseif monk_epic == "1" then
			e.self:Say("In my dreams I see sand as red as blood and skies scorched from war. It is a terrible vision that has haunted me greatly. Please find a way to let me know if this is fact or fiction, " .. e.other:GetName() .. ".")
		end
	end

	if e.message:findi("cursed dreams") then
		if monk_epic == "1" then
			e.self:Say("I pray that they stay locked within my mind for the world as we know it would be changed forever. In my dreams I see sand as red as blood and skies scorched from war. It is a terrible [vision].")
		elseif mnk_pre == "1" then
			e.self:Say("I sense something within you. You may walk the path, but I must be certain. The information I possess is too important to give to just anyone. If you believe you are worthy of the information I hold you will complete this [task] I ask.")
		end
	end

	if e.message:findi("task") then
		e.self:Say("Do not think that it will be an easy feat, even for one with such capabilities as yourself. There are two masters you must find. They will show you the ways of the enlightened. Return to me after you have gained proof of your deeds.")
	end

	if e.message:findi("the way") and mnk_pre == "2" then
		e.self:Say("Very well then. There is a place full of mirrors. Locate one of them and speak the words, I am ready to be tested. It is at this point you will face the darkness within yourself. You will have to face this foe alone, remember that. Return to me if you manage to prove that you are worthy of true enlightenment.")
	end

	if monk_epic == "1" and e.message:findi("vision") then
		e.self:Say("I have seen visions of a dark foe gaining new strength in a plane unknown to me. It grows stronger with every passing minute. It gathers those that stand for chaos and disorder and is sending them out to search for the ultimate power of the Immortals, but it cannot be real. History reveals that he has been defeated. I see this same dream every night. It haunts me greatly. This dream seems too real, however, to not have some truth to it. If only I knew if this was the gift of foresight, or if I have finally lost my mind. If I only knew, I would be able to rest again.")
	end

	if monk_epic == "2" and e.message:findi("time") then
		e.self:Say("Time for what? Time for us to find a way to defeat this menace that threatens our ways of life. Go out and find one that may know more about the [power of the Immortals]. Please do not return until you have found someone to help.")
	end

	if e.message:findi("diary") then
		e.self:Say("Kaiarens Diary? I havent seen it in some time now. If I were not such a coward, I would have kept it. I have heard rumors of it being torn in half. Some students that wanted to learn the ways of the Celestial Fists were looking for it a while back. One was a pirate that wanted to only learn the Path of the Silent to gain more treasures then he had. The other, wanted to become the most powerful fighter alive. You may want to seek them out and see if they have located pieces of it. I am sorry I could not be of more help. If you do happen to locate the two pieces, bring them back to me and maybe I will be able to aid you further. Now that you know my secret, there is no reason to remain hidden from the world. You will be able to find me resting in the Plane of Tranquility. Be safe, " .. e.other:GetName() .. " .")
	end

	if monk_epic == "3" and e.message:findi("Vortix") then
		e.self:Say("I see you know who I truly am now. It does not matter though. There is nothing I can help you with. Danl should have been able to help you more than I could.")
		eq.unique_spawn(203433, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
		eq.depop_with_timer()
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 48122}) then
		e.self:Say("Where did you find this? Could it really be happening now, after all of this time? It couldnt be. He had been defeated... there is little [time] left for us now I am afraid.")
		eq.set_global("monk_epic", "2", 5, "F")
	elseif item_lib.check_turn_in(e.trade, {item1 = 48100, item2 = 48101}) then
		e.self:Say("I see you do have the skill that is needed to continue this quest, but you must now face your hardest foe yet. For your final task, you will be alone, and in that moment you will have to face your true self. Many cannot bear to see what they find within. It is at that time we really see what we are capable of. If you wish to continue, I will show you [the way].")
		eq.set_global("MnkPre", "2", 5, "F")
	elseif item_lib.check_turn_in(e.trade, {item1 = 48102}) then
		e.self:Say("So I see you do truely have the ability to follow the path of the Enlightened. I am sorry I was not sure before but I am now. Now I must tell you of my [cursed dreams].")
		eq.set_global("MnkPre", "3", 5, "F")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
