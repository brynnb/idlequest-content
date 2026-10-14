-- P99 Coldain Ring Quests, ring two; original ProjectEQ Perl is preserved.
-- Provenance, grid mapping and remaining escort limitations:
-- docs/coldain-quest-chains.md and coldain_rings.json (escort).
local item_lib = require("items")
local hunt_finished = false

function event_spawn(e)
  if e.self:GetNPCTypeID() == 116191 then
    -- The old Perl requests absent grid 271. Existing grid 230 contains the
    -- hunting stops identified by its coordinate comments, with fewer nodes.
    eq.start(230)
  end
end

function event_say(e)
  if e.message:findi("hail") then
    e.self:Say("Hello stranger, I am Boridain, master hunter of the Coldain. Glad to meet you.")
  end
end

function event_trade(e)
  if e.self:GetNPCTypeID() == 116149 and item_lib.check_turn_in(e.trade, {item1 = 30265}) then
    e.self:Say("Say! This looks just like the axe my uncle uses. With this I can kill the beast for sure! Now please, be very quiet, I must track my prey. I won't return to Thurgadin without the hide of the rabid tundra kodiak!")
    eq.spawn2(116191, 0, 0, 1547, -2459, 306.5, 0)
    eq.depop_with_timer()
  elseif e.self:GetNPCTypeID() == 116191 and item_lib.check_turn_in(e.trade, {item1 = 30266}) then
    -- P99 allows a retained skin after starting a fresh hunt with another axe,
    -- but never an unstarted static Boridain. The spawned form is the gate.
    e.self:Say("Yes! I've done it! The vile beast is finally dead. I will at last be revered as the mighty hunter I am. Here is your axe back, I broke it on the killing blow. Take it as proof that you are a friend of the greatest hunter in the history of the Coldain!")
    e.other:SummonItem(30267)
    e.other:AddEXP(5000)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end

function event_waypoint_arrive(e)
  if e.self:GetNPCTypeID() ~= 116191 then return end
  if e.wp == 3 then
    e.self:Say("Boy, all this hunting sure does make ya hungry! Time for a snack.")
  elseif e.wp == 5 then
    e.self:Emote("yawns.")
    e.self:Say("All this tracking is makin me mighty sleepy. Time for a little nap. You keep a lookout.")
    -- Sitting/sleeping poses and the Perl's SetHP nap heal are not delivered
    -- by the runtime yet. Do not call those silent bridge no-ops as a fix.
  elseif e.wp == 7 and not hunt_finished then
    hunt_finished = true
    -- Retire this circular grid at its last hunting stop. The committed
    -- callback persists stop, spawn, closure state and timer together.
    eq.stop()
    e.self:Say("Who am I kidding, I'm no hunter. I'll never be a hunter. I may as well give up and become a miner like dad.")
    eq.spawn2(116545, 0, 0, 1559, -2304, 313, 251)
    -- P99 says "within a minute or so"; 60s is the documented IdleQuest
    -- approximation, replacing the upstream five-minute window.
    eq.set_timer("finish", 60000)
  end
end

function event_waypoint_depart(e)
  if e.self:GetNPCTypeID() ~= 116191 then return end
  if e.wp == 1 then
    e.self:Say("Hmmm, fresh prints. They're HUGE! This must be it! This hunting stuff is easier than I thought.")
  elseif e.wp == 2 then
    e.self:Say("Hmm, that wasn't him. Let's see now, if I were a rabid tundra beast where would I go? This way!")
  elseif e.wp == 3 then
    e.self:Say("Ahh, that's better. Back to the hunt... I think I hear something over yonder. Stay low.")
  elseif e.wp == 4 then
    e.self:Say("Where did that vile beast go now? Wait, what's that over there? Could it be? Only one way to find out!")
  elseif e.wp == 5 then
    e.self:Emote("stretches.")
    e.self:Say("Ahh, refreshing! Back to work... I think I smell the beast! This way.")
  elseif e.wp == 6 then
    e.self:Say("I just don't get it. I thought that was him for sure. I don't see any sign of him now.")
  end
end

function event_timer(e)
  if e.timer == "finish" then
    eq.stop_timer("finish")
    eq.depop()
  end
end

function event_death_complete(e)
  eq.stop_timer("finish")
end
