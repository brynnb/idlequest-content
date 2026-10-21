-- Source: westwastes/a_Kromzek_warrior.lua
-- P99 Leuz's Task: fifteen-minute lifetime, paused during combat.
function event_spawn(e)
  eq.set_timer('Depop', 900 * 1000);
end

function event_combat(e)
  if e.joined then
    eq.stop_timer('Depop');
  else
    eq.set_timer('Depop', 900 * 1000);
  end
end

function event_timer(e)
	if (e.timer == 'Depop') then
		eq.depop();
  end
end
