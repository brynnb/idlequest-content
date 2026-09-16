-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/Ixpacan.pl
-- items: 48041, 48044, 4267, 48043, 48042

local function has_skullcap_global(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["skullcap"] == "1"
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hmm. . .is there something I can help you with? I am far too [busy] to listen to your problems though so I take that back.")
	elseif e.message:findi("busy") then
		e.self:Say("It is none of your concern unless you are truly gifted in the dark   art of necromancy. If so, you will have some form of proof to show me.")
	elseif e.message:findi("wish to hear") and has_skullcap_global(e) then
		e.self:Say("I have recently found a volume on summoning a great minion from the Great Library of Charasis but I can't find all of the needed items. Being as I am one of the [sages of Cabilis], I request you go and [collect these items] for me.")
	elseif e.message:findi("sages of cabilis") and has_skullcap_global(e) then
		e.self:Say("Ah, they are all but a memory now. We used to be welcome within the city of Cabilis but our quest for greater power led to our exile. No matter now, go retrieve the items and you will be one of the chosen to walk beside greatness.")
	elseif e.message:findi("collect these items") and has_skullcap_global(e) then
		e.self:Say("As you should broodling. The the first is a brittle bone, which was once used for reincarnations. The second item is a poisoned soul, this is from an iksar that died a cruel and twisted death. The death was so awful, it's spirit still roams around angry. The third you will find in the burning heat. The final item is a gem of reflection. I have yet to find someone that knows how to create one. Even those fools in Cabilis probably wouldn't know. Maybe you can locate that one yourself. Bring all of these items back to me and I shall do the rest.")
		e.other:SummonItem(48041)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 48044, item2 = 4267}) then
		e.self:Say("I see now that I lack the skill necessary to control the Dark Arts. Maybe it would be wiser to allow another such as yourself to continue forward. Please accept this token as a reward in your mastering of the Dark Arts.")
		e.other:AddEXP(20000)
		e.other:SummonItem(48043)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4267}) then
		e.other:SummonItem(4267)
		eq.set_global("skullcap", "1", 5, "F")
		e.self:Say("Oh, I see you are truly gifted in the dark arts. Well I will explain my dilemma to you now if you [wish to hear].")
	elseif item_lib.check_turn_in(e.trade, {item1 = 48042}) then
		e.self:Say("Wonderful! You have brought all of the items I have asked for. Your future seems very bright with the rest of the Sages. Step back now as I conjure the child of Charasis.")
		e.self:Emote("As Ixpacan starts his incantations, you can see an image begin to appear from the shadows.")
		eq.spawn2(93189, 0, 0, e.self:GetX(), e.self:GetY() + 5, e.self:GetZ(), e.self:GetHeading())
		e.self:Say("It's out of my control! Defeat it before it destroys us both!")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
