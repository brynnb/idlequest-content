-- enabled: false
-- P99 scope: exclusive later epic hook. Historical callbacks retained below; see p99-support-source-review/world-scope-dispositions.json.
function event_combat(e)
  if e.joined then
	eq.set_timer("depop", 1800 * 1000);
	e.self:Say("Very well then. Prepare your soul to be cleansed.");
  end
end

function event_timer(e)
	if(e.timer=="depop") then
		eq.depop();
	end
end
