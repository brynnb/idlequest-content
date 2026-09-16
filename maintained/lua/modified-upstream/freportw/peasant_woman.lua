-- P99 Paladin epic. The visible delivery option contains "water", so it must
-- resolve before the generic water question. Retain the typed P99 phrase too.
function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("grunts as she tries to fill two buckets of [water]. Her frail arms strain at her work and pain fills her eyes with tears.")
	elseif e.other:Class() == "Paladin" then
		if e.message:findi("i will take it") or e.message:findi("take this water to him") then
			e.self:Say("Surely you are a pure soul. If you would take this bucket of water to my brother, I would be forever grateful. I am just so tired, I need to rest... She slumps to the floor and begins to breathe shallowly, in short, harsh gasps.")
			e.other:SummonItem(29008)
		elseif e.message:findi("water") then
			e.self:Say("Aye, water, m'lord. For my brother. He is very sick. He's needin' drink. He's burnin' up. I am sick myself but still able to move, a little. I must [take this water to him] before he gets worse.")
		end
	end
end
