-- Source: qeynos/Belious_Naliedin.lua
-- items: 18717, 13502, 20374, 20373
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18717) then
		e.other:Message(MT.Yellow,"As you get your bearings, you hear a beautiful song. It almost seems to draw you towards it. It's as if you can hear a voice in your head as the music surrounds you. 'Welcome to the Wind Spirit's Song. I am Belious Naliedin. Read the note in your inventory and hand it to me when you are ready to begin your training as a bard.' The music then fades as quickly as it had begun.");
	end
end

function event_signal(e)
	e.self:Say("Sure. Go Ahead and play it now, while the stage is clear.");
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Welcome, my name is Belious Naliedin of the League of Antonican Bards. A few years ago, I had finally saved up the money, and I bought this place. I settled in, and have been working here ever since.");
	elseif(e.message:findi("famous bard")) then
		e.self:Say("A famous bard, you say? Why you must be seeking none other than the great Baenar Swiftsong! He is not here as you can see. Mayhap you seek an audience with him? He is a busy man and has not the time to speak with everyone who wishes to preoccupy his time with useless prattle! You are many and he is but one! Leave him be, I beg of you, to continue his songwriting in peace.");
	elseif(e.message:findi("audience with him")) then
		e.self:Emote("laughs briefly. 'Ah! In order to gain an audience with him, you must have a letter of introduction from me, otherwise he will not give you the time of day.'");
	elseif(e.message:findi("letter of introduction")) then
		e.self:Emote("looks around. 'Well, you want a letter of introduction, eh? I think that fifty shiny platinum pieces sounds like a good introduction to me, my friend.'");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18717})) then -- Tattered Note
		e.self:Say("Good day friend, and welcome to the Wind Spirit's Song. Thank you for joining our cause. Go speak with Jusean Evanesque; I'm sure you'll fit in well.");
		e.other:SummonItem(13502); -- #Brown Tunic*
		e.other:Ding();
		e.other:Faction(284,100,0); -- League of Antonican Bards
		e.other:Faction(281,15,0); -- Knights of Truth
		e.other:Faction(262,15,0); -- Guards of Qeynos
		e.other:Faction(304,-5,0); -- Ring of Scale
		e.other:Faction(285,-5,0); -- Mayong Mistmoore
		e.other:AddEXP(100);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20374})) then
		e.self:Say("A famous bard, you say? Why you must be seeking none other than the great Baenar Swiftsong! He is not here as you can see. Mayhap you seek an audience with him? He is a busy man and has not the time to speak with everyone who wishes to preoccupy his time with useless prattle! You are many and he is but one! Leave him be, I beg of you, to continue his songwriting in peace.");
		e.other:Ding();
		e.other:AddEXP(100);
	elseif(item_lib.check_turn_in(e.trade, {platinum = 50})) then
		e.self:Say("Ah! Here is that letter of introduction I was looking for! Baenar likes to frequent a serene fountain in the southern Karanas. He finds the peace there accommodating to his work. He may even sing a tale for you if the mood strikes him.");
		e.other:Ding();
		e.other:SummonItem(20373); -- Item: Letter of Introduction
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:qeynos  ID:1133 -- Belious_Naliedin
