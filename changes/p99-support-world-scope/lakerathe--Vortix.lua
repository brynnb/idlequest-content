-- enabled: false
-- P99 scope: exclusive later epic hook. Historical callbacks retained below; see p99-support-source-review/world-scope-dispositions.json.
-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/Vortix.pl

function event_say(e)
	if e.message:findi("diary") then
		e.self:Say("Kaiaren's Diary? I haven't seen it in some time now. If I were not such a coward, I would have kept it. I have heard rumors of it being torn in half. Some students that wanted to learn the ways of the Celestial Fists were looking for it a while back. One was a pirate that wanted to only learn the Path of the Silent to gain more treasures than he had. The other, wanted to become the most powerful fighter alive. You may want to seek them out and see if they have located pieces of it. I am sorry I could not be of more help. If you do happen to locate the two pieces, bring them back to me and maybe I will be able to aid you further. Now that you know my secret, there is no reason to remain hidden from the world. You will be able to find me resting in the Plane of Tranquility. Be safe, " .. e.other:GetCleanName() .. " .")
		eq.set_global("monk_epic", "4", 5, "F")
		eq.depop()
	end
end
