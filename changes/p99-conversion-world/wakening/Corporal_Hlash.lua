-- name: Corporal_Hlash
-- Source: sources/projecteq/wakening/Corporal_Hlash.pl
-- Source SHA256: a338a17c66ecbdace57e5fc2868a508fd85a1d8d6167e5df1bbc921b6862ec87
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Retain authored route23, spatial speech gate, all four defenders and signals.
-- Perl quest::signal(id,300) means Lua eq.signal(id,0,300), NOT signal ID300.
-- P99 also describes phase pumas absent from Perl; no guessed extra actors are added.
function event_spawn(e)
  eq.set_timer("onset", 60000)
  eq.set_timer("readygo", 150000)
end
function event_timer(e)
  if e.timer == "onset" then
    e.self:MoveTo(-4341, -748, -183, -2, true)
    eq.stop_timer("onset")
  elseif e.timer == "readygo" and e.self:GetX() == -4341 and e.self:GetY() == -748 then
    e.self:Say("Onward men, the eyes of Zek are upon us.")
    eq.stop_timer("readygo")
    eq.signal(119167, 1, 300)
    eq.signal(119166, 1, 300)
    eq.signal(119169, 1, 300)
  end
end
function event_waypoint_arrive(e)
  if e.wp == 5 then
    e.self:Say("Hold here squad")
    eq.signal(119050, 0, 300)
  end
end
function event_say(e)
  if e.message:findi("troop attack") and e.self:GetX() == -225 and e.self:GetY() == 1725 then
    e.self:Shout("Destroy them!!")
    eq.message(10, "Suddenly, all around the Sifaye village, several beings phase into reality.  Their eyes glow with the golden light of divinity, obviously sent from a higher plane of existence.  The Kromzek assault squad is surely doomed. You decided to withdraw and report what you have found, perhaps the Lieutenant will understand.")
    eq.signal(119167, 2, 300)
  end
end
function event_signal(e)
  if e.signal == 1 then
    eq.start(23)
  elseif e.signal == 2 then
    e.self:Say("Grraaaggh! AMBUSH!! Die well!")
    eq.spawn2(119174, 0, 0, -146, 1703, -192, 374)
    eq.spawn2(119174, 0, 0, -149, 1731, -192, 374)
    eq.spawn2(119174, 0, 0, -162, 1738, -192, 374)
    eq.spawn2(119174, 0, 0, -172, 1758, -192, 364)
  end
end
