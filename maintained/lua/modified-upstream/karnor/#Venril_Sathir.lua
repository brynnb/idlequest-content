-- Source: ProjectEQ karnor/#Venril_Sathir.lua; P99 Venril_Sathirs_remains.
-- The shared spawn2 dependency owns exclusion and the post-death delay.
-- Do not restore the per-character depop here: it restarts/hides the remains
-- independently for every visitor and cannot see the boss's actual death time.
function event_spawn(e)
end
