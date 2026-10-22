-- P99 A Tar Goo: the larger goo splits into two smaller goos on death.
function event_death_complete(e)
      eq.spawn2(119122, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()); -- NPC: a_tar_goo
      eq.spawn2(119122, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()); -- NPC: a_tar_goo
end
