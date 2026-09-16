-- Converted from ProjectEQ Perl quest script with IdleQuest starting note support.
-- Source: kaladimb/Priestess_Ghalea.pl
-- P99 audit: Soil of Underfoot Quest
-- items: 18765, 13514, 12106, 12282

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 50, x + 50, y - 50, y + 50)
end

function event_enter(e)
	if e.other:HasItem(18765) then
		e.other:Message(MT.Yellow, "High Priestess Ghalea greets you with genuine enthusiasm. 'Hello there! Welcome to the Underfoot Cathedral! Read the note in your inventory and when you are ready to begin your training, hand me your note! May Brell bless us all!'")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Church of Underfoot. Please open your soul to the greatness of Brell Serilis. May he guide you in all your future endeavors. And may your soles long for the [Soil of Underfoot].")
	elseif e.message:findi("soil of underfoot") then
		local fac = e.other:GetFaction(e.self)
		if fac >= 5 then
			e.self:Say("The Clerics of Underfoot have yet to see your faith directed towards our wills. Perhaps you should assist Master Gunlok Jure in the crusade against the undead.")
		else
			e.self:Say("I can trust you with the soil of Underfoot, but first you must obtain four portions of fairy dust. Return them to me and I shall mix it and pray over it. Then I shall give you a pouch of soil of Underfoot.")
		end
	elseif e.message:findi("candle of bravery") then
		e.self:Say("The Candle of Bravery is used for temple ceremonies here in Kaladim. When the candle burns out, I must venture to the frigid village of Halas far to the north of the continent of Antonica. There I will take the candlestick and the [soil of Underfoot] to Dok. He must create the candle in the very ornate candlestick.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18765}) then
		e.self:Say("Welcome to the Underfoot Cathedral. I am High Priestess Ghalea. Here is your guild tunic. Now, let's get you started helping us spread the will of Brell.")
		e.other:SummonItem(13514)
		e.other:AddEXP(100)
		e.other:Faction(227, 100, 0)
		e.other:Faction(274, 100, 0)
		e.other:Faction(293, 75, 0)
		e.other:Ding()
	elseif e.other:GetFaction(e.self) < 5 and item_lib.check_turn_in(e.trade, {item1 = 12106, item2 = 12106, item3 = 12106, item4 = 12106}) then
		e.self:Say("May the mighty power of Brell saturate this soil with his divinity. Here you are, my noble friend. You may have a pouch of the soil of Underfoot.")
		e.other:SummonItem(12282)
		e.other:Faction(227, 2, 0)
		e.other:Faction(274, 2, 0)
		e.other:Faction(293, 2, 0)
		e.other:AddEXP(500)
		e.other:GiveCash(0, 0, 4, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
