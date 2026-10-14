-- P99 Rogue Epic Quest restores dialogue absent from the original Perl.
function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ".")
	elseif e.message:findi("eldreth") then
		-- P99 says this works only sometimes, without specifying a condition.
		-- Deliberate approximation: do not claim Eldreth is away while he is here.
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(51025) then
			e.self:Say("Eldreth is not here right now. *chuckle* He went to find work, but if you know Eldreth, you would know that 'Eldreth working' is an oxymoron! Sometimes I wonder why I still share this tower with him. I suppose I get lonely on this lake, and Jebeker here never has much to say. But I digress. Eldreth will be back sooner rather than later, I would think. You are welcome to stay here and keep me company until he returns, or you can check back later. He is seldom gone more than a few days.")
		end
	end
end
