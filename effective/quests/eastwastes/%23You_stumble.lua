-- Source: server/internal/quest/upstream/projecteq/eastwastes/#You_stumble.pl (sha256 f09f46c08bba2a1c5128cbd4136e7b4cdaf8f9bbe7aefcca1a7d8cb8f69c6cb3)
-- P99: Coldain Prayer Shawl Quests, fourth shawl; see docs/coldain-quest-chains.md.
function event_spawn(e)
  local x, y = e.self:GetX(), e.self:GetY()
  eq.set_proximity(x - 50, x + 50, y - 50, y + 50)
end

function event_enter(e)
  if eq.get_entity_list():IsMobSpawnedByNpcTypeID(116542) then
    e.self:Emote("in the snow.")
    return
  end
  e.self:Emote("and uncover the body of an injured coldain.")
  -- Use the shared unique-spawn settlement rule as well as the visible check:
  -- adjacent trap entries can arrive before the first spawn is published.
  eq.unique_spawn(116542, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0)
  eq.depop_with_timer()
end
