-- Modified from ProjectEQ Lua during P99 quest audit.
-- P99: https://wiki.project1999.com/Hollow_Skull_Quest
-- items: 18010

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Argh... the [beasts] are on my tail. They will find me soon... I gave them the [skull] and still they pursue me!");
	elseif(e.message:findi("skull")) then
		e.self:Say("The skull of Wun Toque! I have found it. And have learned the location of its eyes! But now the [beasts] have it and I must flee...");
	elseif(e.message:findi("beasts")) then
		e.self:Say("Here... No time left... Take this please... My brother [Hyrill] is staying in [Freeport]. Please... Ugh... Must keep moving...");
		e.other:SummonItem(18010); -- Torn Parchment
		eq.spawn2(12182, 0, 0, -15188.57, 1270.43, 68.72, 218):AddToHateList(e.self, 1); -- a_Splitpaw_assassin
		e.self:Say("He has found me! Help meeeeeee!");
	elseif(e.message:findi("hyrill") or e.message:findi("freeport")) then
		e.self:Say("There is no time... must keep moving... ugh.");
	end
end

-- END of FILE zone: ID:12167 -- Yiz_Pon.pl
