-- P99 human Lhranc attacks the turn-in owner; the sword is earned from his
-- existing guaranteed corpse drop, not a second token/Marl exchange.
-- Source: preserved P99 epic quick/short walkthroughs and Lhranc NPC page.
-- Do not reinstate the later two-hour quest timer: P99 says a failed fight
-- does not despawn him. Ordinary owner/zone quest-spawn lifecycle still applies.
function event_spawn(e)
  eq.attack(e.other:GetName())
end
