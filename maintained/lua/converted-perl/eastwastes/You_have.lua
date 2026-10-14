-- Source: server/internal/quest/upstream/projecteq/eastwastes/You_have.pl (sha256 b268b7b5887bba1811f1c747161041cb1f91c3ff3185574e3519f7338cbf3c74)
-- P99: Coldain Prayer Shawl Quests, fourth shawl; see docs/coldain-quest-chains.md.
function event_spawn(e)
  local x, y = e.self:GetX(), e.self:GetY()
  eq.set_proximity(x - 20, x + 20, y - 20, y + 20)
end

function event_enter(e)
  local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
  e.self:Emote("been ambushed!")
  eq.spawn2(116540, 0, 0, x + 5, y - 5, z, 0)
  eq.spawn2(116540, 0, 0, x - 5, y + 5, z, 0)
  eq.depop_with_timer()
end
