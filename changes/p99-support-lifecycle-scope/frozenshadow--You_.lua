-- enabled: false
-- P99 scope: Only MnkPre=2 mirror test; the shared MnkPre path is explicitly Monk Epic 1.5/2.0 prequest in qey2hh1/Mystik. Historical body retained below.
function event_spawn(e)
  eq.set_timer('delay', 2000);
end

function event_timer(e)
  eq.stop_timer('delay');
  eq.set_proximity(e.self:GetX()-15, e.self:GetX()+15, e.self:GetY()-15, e.self:GetY()+15, -999999, 999999, true);
  eq.enable_proximity_say();
end

function event_proximity_say(e)
  eq.debug("prox_say " .. e.message .. " " .. e.other:GetName());
  local qglobals = eq.get_qglobals(e.other)
  local mnk_pre = tonumber(qglobals["MnkPre"]);
  if (mnk_pre == nil) then mnk_pre = 0; end

  eq.debug("mnk_pre " .. mnk_pre);
    
  if (mnk_pre == 2) then
    if (e.message:findi("I am ready to be tested")) then
      eq.spawn2(111190, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()); -- NPC: Mirror_Reflection
      eq.depop_with_timer();
    end
  end
end
