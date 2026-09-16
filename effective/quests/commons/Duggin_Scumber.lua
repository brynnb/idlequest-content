-- Converted from ProjectEQ Perl quest script.
-- Source: commons/Duggin_Scumber.pl

function event_spawn(e)
	e.self:Emote("runs up and steals the note.")
	e.self:Say("Aha!! Foolish Qeynite or whatever you call yourself!! I have found the note and now I shall take it to my superior!! Just try and catch me!!")
	e.other:Faction(281, 1) -- Knights of Truth
	e.other:Faction(271, -1) -- Dismal Rage
	e.other:Faction(330, -1) -- The Freeport Militia
	e.other:Faction(311, 1) -- Steel Warriors
	e.other:Faction(362, 1) -- Priests of Marr
	eq.set_timer("run", 10000)
	eq.set_timer("depop", 600000)
end

function event_timer(e)
	if e.timer == "run" then
		eq.stop_timer("run")
		eq.start(2)
	elseif e.timer == "depop" then
		eq.depop()
	end
end

function event_death_complete(e)
	e.self:Say("Your name shall be added to the most wanted list of the Freeport Militia!!")
end

function event_trade(e)
	e.self:ReturnHandinItems(e.other)
end
