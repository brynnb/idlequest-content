-- name: Berzerker_Voldak
-- Source: sources/projecteq/wakening/Berzerker_Voldak.pl
-- Source SHA256: 0169c078ce10d546ab97b06d9412dc137b56e9f84b982592df503bb9b03ffbae
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Literal signal delays are milliseconds in BOTH Perl and Lua.
-- Owner-scoped grid starts plus signals pass current structural preflight.
-- No public-world actor header: these are player-owned quest spawns.
function event_spawn(e)
  eq.set_timer("onset1", 58000)
end
function event_timer(e)
  if e.timer ~= "onset1" then return end
  e.self:MoveTo(-4311, -720, -183, -2, true)
  eq.stop_timer("onset1")
end
function event_signal(e)
  if e.signal == 1 then
    eq.start(24)
    eq.signal(119168, 1, 300)
  elseif e.signal == 2 then
    e.self:Say("Woah! we're being ambushed!!")
    eq.signal(119168, 2, 300)
  end
end
