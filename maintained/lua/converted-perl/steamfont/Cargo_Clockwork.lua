-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/Cargo_Clockwork.pl

local delivery = 0
local bandit1id = 56178
local bandit2id = 56179
local bandit3id = 56180

function event_spawn(e)
	eq.set_timer("CargoTimer", 5000)
end

function event_signal(e)
	e.self:Emote("Chuga.. Chug..Chug..")
	e.self:Say("This unit requires maintenance.")
end

function event_timer(e)
	local zone_time = eq.get_zone_time()
	if eq.get_data("CargoClockwork") == "" and zone_time.zone_hour == 8 then
		eq.set_data("CargoClockwork", "1", "H2")
		eq.start(177)
	end
end

function event_waypoint_arrive(e)
	if e.wp == 1 and delivery == 1 then
		eq.stop()
		delivery = 0
	end
	if e.wp == 8 then
		e.self:Say("kachunk .. kachunk..")
		eq.signal(56066, 1) -- Watchman Grep
	end
	if e.wp == 10 and delivery == 0 then
		delivery = 1
		e.self:Emote("Chuga.. Chug..Chug..")
		e.self:Emote("The chugging of the Cargo Clockwork comes to a halt.")
		eq.spawn2(bandit1id, 0, 0, 30, -700, -109, 124) -- Hector
		eq.spawn2(bandit2id, 0, 0, 95, -732, -108, 480) -- Renaldo
		eq.spawn2(bandit3id, 0, 0, 53, -615, -107, 226) -- Jerald
		e.self:Say("This is highway robbery.")
	end
end

function event_death_complete(e)
	eq.stop_timer("CargoTimer")
	delivery = 0
	eq.signal(bandit1id, 0)
	eq.signal(bandit2id, 0)
	eq.signal(bandit3id, 0)
end
