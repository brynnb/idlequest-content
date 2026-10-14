-- IdleQuest epic 1.0 steps have no minimum level; preserve class and item checks.
-- Reviewed P99 Necromancer Epic 1.0: restore omitted quest directions.
-- Source: lakerathe/Kazen_Fecae.pl
-- Necromancer Epic 1.0: Kazen Fecae apprentice/test/final chain.
-- Converted from ProjectEQ Perl quest script, limited to Epic 1.0 behavior.
-- items: 20641, 20642, 20647, 20653, 18087, 20652, 20544

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("eyes seem to glow as he turns to you and says, 'Leave me be if you have no reason to be here, mortal!'")
	elseif e.message:findi("dark arts") then
		if e.other:Class() == 11 then
			e.self:Emote("looks you up and down, his eyes glowing with a soft red light. 'You wish to study under me? Perhaps, if you prove yourself to follow the twisted path.'")
		else
			e.self:Say("Ha! You call yourself a Necromancer? Come back when you have tortured a few more souls!")
		end
	elseif e.message:findi("prove") then
		e.self:Say("The wandering knight, Sir Edwin Motte, recently slew one of my lesser servants. This foolish knave travels from town to town pretending to be good. Separate his head from his body and return it to me so I may work my magics upon it. This fool will become another plaything for me, even in death.")
	elseif e.message:findi("advance") then
		e.self:Say("I share great secrets with my more powerful servants who show me they are willing to serve without question. Tell my servant the name of any symbol he gives you and he will instruct you. If I give you a symbol, speak its name to me so I may instruct you.")
	elseif e.message:findi("symbol of apprentice") then
		e.self:Say("You have a long way to go before I teach you the true secrets of life and death. Visit Venenzi Oberendi in the Nektulos Forest and show her the symbol. She is collecting reagents for one of my experiments and is taking far too long. I do not wish her dead, yet, I simply need the reagents soon. Retrieve the reagents and give them to my assistant Emkel Kabae. I do not wish to handle them myself.")
	elseif e.message:findi("reagents") then
		e.self:Say("The reagents are the same types the great sorcerer Miragul used to cheat death and become a lich.")
	elseif e.message:findi("symbol of testing") then
		e.self:Say("Show me that you can overcome larger obstacles and manipulate servants. Gather a force for of mercenaries if you like, or so-called friends, if you desire, and prepare for battle, my promising young student. Return to me with the symbol of testing when you are prepared for battle with my creations. Have no fear, I will not slay you myself. If you do live, tell me the name of the symbol you receive.")
	elseif e.message:findi("symbol of insanity") then
		e.self:Say("It is time for you to meet my partner, so to speak. Drendico Metalbones is his name and I assure you he is quite mad. His mind has been rended by fright, dread, and terror in his trips to the planes and his heart is full of hatred now. He has a tome which I wish you to use. Show him your symbol slowly and listen to his rantings well, they hide great knowledge.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20641}) then
		e.self:Say("Excellent! You have done well, my new apprentice.")
		e.other:AddEXP(5000)
		e.other:SummonItem(20642) -- Symbol of the Apprentice
	elseif item_lib.check_turn_in(e.trade, {item1 = 20647}) then
		e.self:Say("Good luck, my student!")
		eq.spawn2(51153, 0, 0, -1498.9, 283.8, 58.4, 115.2) -- a_bone_golem
	elseif item_lib.check_turn_in(e.trade, {item1 = 20653}) then
		e.self:Emote("stares through you at the horizon, then hands you a tome.")
		e.other:AddEXP(10000)
		e.other:SummonItem(18087) -- Tome of Instruction
	elseif item_lib.check_turn_in(e.trade, {item1 = 20652}) then
		e.self:Emote("grins wildly and his eyes flare a deep red. The scythe he promised you flies through the air and into your hand.")
		e.other:AddEXP(10000)
		e.other:SummonItem(20544) -- Scythe of the Shadowed Soul
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_death_complete(e)
	eq.spawn2(51153, 0, 0, -1498.9, 283.8, 58.4, 115.2) -- a_bone_golem
end
