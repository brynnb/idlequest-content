-- enabled: false
-- Post-Velious exact chain; complete historical callback body retained.
-- Evidence: changes/p99-final-chain-closure/review.json
function event_death_complete(e)
	eq.spawn2(20300,0,0, e.self:GetX()+7,e.self:GetY()+7,e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX(),e.self:GetY()+7,e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX()+7,e.self:GetY(),e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX()-7,e.self:GetY()-7,e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX()-7,e.self:GetY(),e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX(),e.self:GetY()-7,e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX()+7,e.self:GetY()-7,e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX()-7,e.self:GetY()+7,e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX()+14,e.self:GetY()+14,e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
	eq.spawn2(20300,0,0, e.self:GetX()-14,e.self:GetY()-14,e.self:GetZ(),0); -- NPC: #Blackened_Tree_Limb
end