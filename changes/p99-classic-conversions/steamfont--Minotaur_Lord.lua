-- P99 NPC page quotes the aggro line. Death line retained from ProjectEQ.
-- Hero spawn-cycle probability is not established here; no invented spawn roll.
function event_aggro(e)
    e.self:Say("I survived the gladiator pens of Qeynos!! What can you do to one such as I?!!")
end

function event_death_complete(e)
    e.self:Say("I die soon! Meldrath, help me!")
end
