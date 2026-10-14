-- Source: https://wiki.project1999.com/Venril_Sathir_(Triggered)
-- This is the triggered epic boss, not the regular #Venril_Sathir.
function event_spawn(e)
  eq.set_timer("despawn", 1200000)
end

function event_timer(e)
  if e.timer == "despawn" then
    eq.stop_timer(e.timer)
    eq.depop()
  end
end
