-- Source: hole/Jaeil_the_Wretched.pl
-- Ranger Epic 1.0: Jaeil the Wretched spawns Jaeil the Insane.
-- Converted from ProjectEQ Perl quest script.
-- items: 17860

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("whimpers pathetically as his reflection catches his eye. He turns and stares pitifully at the ceiling.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 17860}) then
		e.self:Emote("howls in anger, his body seeming to suck energy from the walls around him as he sees his reflection. He pulls a hammer from the bundle in his arms and swings fiercely at your head.")
		-- Retain the original Perl's explicit attack against the hand-in player.
		eq.spawn2(39154, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()):AddToHateList(e.other, 1)
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
