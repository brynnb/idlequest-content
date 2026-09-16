-- Source: grobb/Treskar.lua
-- P99 audit: Froglok Skin Mask Quest
-- items: 12190, 2308, 12199, 5020

function event_say(e)
	local pfaction = e.other:GetFaction(e.self)

	if e.message:findi("hail") then
		e.self:Say("You dare to speak to Master Treskar!! You be [sent by Hukulk] or you be hurtin'!! Me have no time to waste with ugly one like you!!")
	elseif pfaction > 4 then
		reject(e, pfaction)
	elseif e.message:findi("sent by hukulk") then
		e.self:Say("Ha!! Hukulk accept puny troll now?!! Ha!! You join us and you join fight. Nightkeep enemy is " .. e.other:GetName() .. " enemy!! You help smash [other weak shadowknights]. Them weak. We true power!! You bash good and maybe you do [secret mission] for Treskar.")
	elseif e.message:findi("other weak shadowknights") then
		e.self:Say("Other shadowknights is ogre shadowknights! They name is Greenbloods. They no match for Nightkeep! We tear arms from ogre bodies. You not as powerful as Treskar so you smash young Greenbloods. You hunt YOUNG members of Greenblood shadowknights. You bring me black shadow tunic and me share treasures from Nightkeep vault with puny " .. e.other:GetName() .. ". Go!")
	elseif e.message:findi("secret mission") then
		e.self:Say("Nightkeep hear bashers see fungus man spore guardian in Innothule. Him protect young fungus man spores so they grow big, BIG an' attack trolls!! You go find spore guardian. Smash his big red head!! Bring Treskar that huge mushroom head of his to prove he walk no more. You do this and me give you froglok skin mask.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local pfaction = e.other:GetFaction(e.self)

	if pfaction > 4 then
		e.self:Say("You no friend to Treskar!")
	elseif item_lib.check_turn_in(e.trade, {item1 = 12190}) then
		e.self:Say("You do it!! You am great knight. Me give you special froglok skin mask. Shaman make for Nightkeep. It make you smarter like Treskar..Me tink so!!")
		e.other:SummonItem(2308) -- Item: Froglok Skin Mask
		e.other:Ding()
		e.other:Faction(235, 1, 0) -- Da Bashers
		e.other:Faction(222, -5, 0) -- Broken Skull Clan
		e.other:Faction(308, 20, 0) -- Shadowknights of Night Keep
		e.other:Faction(261, -3, 0) -- Green Blood Knights
		e.other:AddEXP(10000)
		e.other:GiveCash(3, 1, 2, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12199, item2 = 12199, item3 = 12199, gold = 2}) then
		e.self:Say("Hmm... You do good job. You surprise Treskar. Maybe you good after all. Maybe Treskar give you [secret mission]. Maybe not.")
		e.other:SummonItem(5020) -- Item: Rusty Battle Axe
		e.other:Ding()
		e.other:Faction(235, 1, 0) -- Da Bashers
		e.other:Faction(222, -5, 0) -- Broken Skull Clan
		e.other:Faction(308, 20, 0) -- Shadowknights of Night Keep
		e.other:Faction(261, -3, 0) -- Green Blood Knights
		e.other:AddEXP(1000)
	end

	item_lib.return_items(e.self, e.other, e.trade)
end

function reject(e, pfaction)
	if pfaction < 6 then
		e.self:Say("Me talk to you 'bout dat when you do more to help Nightkeep! Kill all Greenbloods! Kill all froggies!")
	else
		e.self:Say("'<..Sniff, sniff, sniff..> Me smell the blood of enemy in you. You fool to talk to Nightkeep shadowknight! Me bleed you if you no run!")
	end
end
