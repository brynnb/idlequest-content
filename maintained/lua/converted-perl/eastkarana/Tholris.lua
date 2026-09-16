-- Source: eastkarana/Tholris.pl; only the P99 epic 1.0 ceremony.
-- Later Mind Crystal / epic 1.5 branches deliberately excluded.
function event_signal(e)
	if e.signal == 99 then
		e.self:Emote("breathes quickly and sweats as he channels his spirit into the sky.")
	end
end
