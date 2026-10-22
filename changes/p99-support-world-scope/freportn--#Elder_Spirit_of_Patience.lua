-- enabled: false
-- P99 scope: exclusive later epic hook. Historical callbacks retained below; see p99-support-source-review/world-scope-dispositions.json.
function event_spawn(e)
	eq.set_timer("setapp",1000);
end

function event_timer(e)
	e.self:SetAppearance(3);
end