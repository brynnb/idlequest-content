-- Explicit mock contract for isolated script logic, not real transaction tests.
function string.findi(s, pattern) return string.find(string.lower(s), string.lower(pattern), 1, true) end
calls = { rewards={}, factions={}, speech={}, spells={}, cash={}, exp=0, returns=0, signals={}, zone_flags={}, depops=0 }
character = { class=4, level=50 }
local function strict(t, label)
 return setmetatable(t, {__index=function(_,k) error('Unmocked '..label..' API: '..k) end})
end
other = strict({
 GetCleanName=function() return "Reviewer" end, GetName=function() return 'Reviewer' end, GetID=function() return 42 end,
 GetClass=function() return character.class end, Class=function() return character.class end,
 GetLevel=function() return character.level end,
 GetClassName=function() return character.class==4 and 'Ranger' or 'Warrior' end,
 GetFaction=function() return 1 end,
 SummonItem=function(_,id,quantity) calls.rewards[id]=(calls.rewards[id] or 0)+(quantity or 1) end,
 Faction=function(_,id,value) calls.factions[id]=(calls.factions[id] or 0)+value end,
 AddEXP=function(_,value) calls.exp=calls.exp+value end,
 QuestReward=function(_,npc,c,s,g,p,item,xp) if type(c)=="table" then item=c.itemid;xp=c.exp or 0 elseif (c or 0)+(s or 0)+(g or 0)+(p or 0)>0 then table.insert(calls.cash,{c or 0,s or 0,g or 0,p or 0}) end; calls.exp=calls.exp+(xp or 0); if item and item~=0 then calls.rewards[item]=(calls.rewards[item] or 0)+1 end end,
 Ding=function() end,
 GiveCash=function(_,c,s,g,p) table.insert(calls.cash,{c,s,g,p}) end,
},'character')
npc = strict({
 Say=function(_,text) table.insert(calls.speech,text) end,
 Emote=function(_,text) table.insert(calls.speech,text) end,
 CastSpell=function(_,id,target) table.insert(calls.spells,{id,target}) end,
 CheckHandin=function(_,client,available,required,instances)
  for id,n in pairs(required) do if (remaining[id] or 0)<n then return false end end
  for id,n in pairs(required) do remaining[id]=remaining[id]-n end
  return true
 end,
 ReturnHandinItems=function() calls.returns=calls.returns+1 end,
},'NPC')
eq = strict({handin=function(required) return npc:CheckHandin(other,remaining,required,{}) end,depop_with_timer=function() calls.depops=calls.depops+1 end,set_zone_flag=function(id) table.insert(calls.zone_flags,id) end,signal=function(id,value,delay) table.insert(calls.signals,{id,value,delay or 0}) end,ChooseRandom=function(...) return (select(character.choice or 1,...)) end},'eq')
function say(text) event_say({self=npc,other=other,message=text}) end
function trade(ids,coins)
 remaining={}; local t={self=npc,other=other,platinum=0,gold=0,silver=0,copper=0}
 for i=1,4 do
  local id=ids[i] or 0
  t['item'..i]={valid=id~=0,GetID=function() return id end}
  if id~=0 then remaining[id]=(remaining[id] or 0)+1 end
 end
 for k,v in pairs(coins or {}) do t[k]=v;remaining[k]=v end
 event_trade({self=npc,other=other,trade=t})
end
function equal(actual,expected,label) assert(actual==expected,(label or 'value')..': expected '..tostring(expected)..', got '..tostring(actual)) end
function reward(id,n) equal(calls.rewards[id] or 0,n,'reward '..id) end
function faction(id,n) equal(calls.factions[id] or 0,n,'faction '..id) end
