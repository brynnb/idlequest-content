-- enabled: false
-- P99 scope: exclusive later epic hook. Historical callbacks retained below; see p99-support-source-review/world-scope-dispositions.json.
function event_signal(e)
	if e.signal==1 then
		e.self:Say("I am truly here. I have truly made it back to my home and those I respect most. I understand I have you to thank, dear heyokah. A thousand blessings upon you.");
	end
end

function event_spawn(e)
	eq.set_timer("setapp",1000);
end

function event_timer(e)
	e.self:SetAppearance(3);
end