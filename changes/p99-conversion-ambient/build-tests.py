import json,pathlib,hashlib,re
P=pathlib.Path('.');O=P/'changes/p99-conversion-ambient';p=json.load(open('changes/p99-conversion-ambient.json'));cases=[]
setup='''calls.moves = {}; calls.timers = {}; calls.animations = {}; calls.proximities = {}; calls.clears = 0; calls.grids = {}
other.GetRaceName = function() return "Gnome" end
npc.MoveTo = function(_,...) table.insert(calls.moves,{...}) end
npc.DoAnim = function(_,id) table.insert(calls.animations,id) end
eq.start = function(grid) table.insert(calls.grids,grid) end
npc.GetX = function() return 10 end
npc.GetY = function() return 20 end
eq.set_timer = function(name,ms) table.insert(calls.timers,{name,ms}) end
eq.set_proximity = function(...) table.insert(calls.proximities,{...}) end
eq.clear_proximity = function() calls.clears=calls.clears+1 end
eq.depop = function() calls.depops=calls.depops+1 end
'''
def add(name,f,a):
 cases.append({'name':name,'proposedFile':f,'sourceSha256':hashlib.sha256(P.joinpath(f).read_bytes()).hexdigest(),'setupExtra':setup,'assertions':a})
coords={'Amberfeld':[[108,665,38,126],[25,542,65,0]],'Coldember':[[93,655,39,488],[15,543,66,0]],'Darakor':[[-79,656,39,0],[-15,544,66,0]],'Darkfrost':[[-4,887,-1,81],[-5,543,66,0]],'Deynekn':[[92,703,39,262],[20,534,68,0]],'Dirkins':[[-103,703,39,264],[0,535,68,0]],'Glacierbane':[[67,654,39,510],[5,545,66,0]],'Icelok':[[67,703,39,270],[10,535,68,0]],'Icepike':[[117,701,39,256],[30,533,68,0]],'Thubins':[[-53,703,39,258],[-20,535,68,0]],'Wintershade':[[6,895,-2,256],[-10,534,67,0]]}
for s in p['sources']:
 f=s['proposedFile'];name=pathlib.Path(f).stem;src=P.joinpath(f).read_text()
 if name.startswith('Councilor_'):
  for sig,co in enumerate(coords[name[10:]],1):
   a=f'event_signal({{self=npc,signal={sig}}});equal(#calls.moves,1);'+''.join(f'equal(calls.moves[1][{i}],{v});' for i,v in enumerate(co,1))+'equal(calls.moves[1][5],true);equal(#calls.speech,0)'
   add(name+f' signal {sig} exact original route and guard flag',f,a)
  add(name+' unknown signal inert',f,'event_signal({self=npc,signal=999});equal(#calls.moves,0);equal(#calls.speech,0)')
  add(name+' repeated independent signal movement',f,'event_signal({self=npc,signal=1});event_signal({self=npc,signal=2});equal(#calls.moves,2);equal(calls.moves[2][5],true)')
 if 'function event_say(' in src:
  add(name+' mixed case hail',f,"say('HaIl');equal(#calls.speech,1)")
  add(name+' unrelated speech inert',f,"say('unrelated');equal(#calls.speech,0);equal(#calls.moves,0)")
  if name=='Brina_Snowfox':add(name+' one repaired race-aware greeting',f,"say('hail');equal(#calls.speech,1);assert(string.find(calls.speech[1],'Gnome?',1,true));assert(not string.find(calls.speech[1],'Wood Elf',1,true));assert(not string.find(calls.speech[1],'%#1472',1,true))")
 if name in ['Novyak_the_Lookout','Initiate_Kroskain','Templar_Franchus','Templar_Tingar','Initiate_Corrith']:
  times={'Novyak_the_Lookout':[('1',2400000)],'Initiate_Kroskain':[('1',320000)],'Templar_Franchus':[('1',480000)],'Templar_Tingar':[('1',480000),('2',840000)],'Initiate_Corrith':[('2',30000)]}[name]
  add(name+' source seconds converted once to milliseconds',f,'event_spawn({self=npc});equal(#calls.timers,'+str(len(times))+');'+''.join(f'equal(calls.timers[{i}][1],"{n}");equal(calls.timers[{i}][2],{t});' for i,(n,t) in enumerate(times,1)))
  for n,t in times:
   expected=2 if name=='Templar_Tingar' and n=='2' else 1
   a=f'event_timer({{self=npc,timer="{n}"}});event_timer({{self=npc,timer="{n}"}});'
   if name=='Initiate_Corrith':a+='equal(#calls.animations,2);equal(calls.animations[1],2);equal(#calls.speech,0)'
   else:a+=f'equal(#calls.speech,{expected*2});equal(calls.speech[1],calls.speech[{expected+1}]);equal(#calls.timers,0)'
   add(name+' repeated timer '+n+' source effect capture only',f,a)
  if name=='Templar_Tingar':add(name+' unknown timer inert',f,'event_timer({self=npc,timer="other"});equal(#calls.speech,0)')
 if name=='Initiate_Sirchthain':
  for r,ms in [(0,10000),(.5,30000),(.999999,49999)]:add(name+f' randomized timer boundary {r}',f,f'math.random=function() return {r} end;event_spawn({{self=npc}});event_timer({{self=npc,timer="2"}});equal(#calls.timers,2);equal(calls.timers[1][2],{ms});equal(calls.timers[2][2],{ms});equal(calls.animations[1],2)')
 if name=='Lieutenant_Ulfur':
  add(name+' existing exact grid bootstrap',f,'event_spawn({self=npc});equal(#calls.grids,1);equal(calls.grids[1],30);equal(#calls.moves,0)')
  for phrase in ['regiment','yes','no']:add(name+' full dialogue '+phrase,f,"say('"+phrase+"');equal(#calls.speech,1)")
  add(name+' independent combined text branches in original order',f,"say('hail regiment yes no');equal(#calls.speech,4);assert(string.find(calls.speech[1],'Hail, there, Gnome',1,true));assert(string.find(calls.speech[2],'favor ranged',1,true))")
  targets=[115104,115206,115105,115207,115107,115208,115109,115110,115209,115112,115113,115211]
  add(name+' waypoint15 exact twelve immediate signal0 requests',f,'event_waypoint_arrive({self=npc,wp=15});equal(#calls.signals,12);equal(#calls.speech,1);'+''.join(f'equal(calls.signals[{i}][1],{id});equal(calls.signals[{i}][2],0);' for i,id in enumerate(targets,1)))
  for wp in [1,14,16,24]:add(name+f' unrelated waypoint {wp} inert',f,f'event_waypoint_arrive({{self=npc,wp={wp}}});equal(#calls.signals,0);equal(#calls.speech,0)')
 if name=='gnomish_captive':
  add(name+' exact original proximity',f,'event_spawn({self=npc});equal(#calls.proximities,1);equal(#calls.proximities[1],4);equal(calls.proximities[1][1],-10);equal(calls.proximities[1][2],30);equal(calls.proximities[1][3],0);equal(calls.proximities[1][4],40)')
  add(name+' enter clears before depop with no player required',f,'local order={};eq.clear_proximity=function() table.insert(order,"clear") end;eq.depop=function() table.insert(order,"depop") end;event_enter({self=npc});equal(#calls.speech,2);equal(order[1],"clear");equal(order[2],"depop");equal(next(calls.rewards),nil)')
 if name=='Julius_Oresko':add(name+' aggro interpolates race only',f,'event_aggro({self=npc,other=other});equal(#calls.speech,1);assert(string.find(calls.speech[1],"A Gnome like you",1,true));equal(next(calls.rewards),nil)')
# Existing receiver sources are composed proposal updates, not new conversions.
receivers={115104:'Dobbs',115206:'Dobbs',115105:'Enre',115207:'Enre',115107:'Mason',115208:'Mason',115109:'Pert',115110:'Gord',115209:'Gord',115112:'Bjorn',115113:'Clorn',115211:'Clorn'}
for name in sorted(set(receivers.values())):
 f='changes/p99-conversions-velious-flavor/thurgadina/Guard_'+name+'.lua'
 for signal in [0,1,999]:add('Existing Guard_'+name+f' receiver any-ID {signal}',f,f'event_signal({{self=npc,signal={signal}}});equal(#calls.speech,1);equal(#calls.signals,0)')
 add('Existing Guard_'+name+' return-all remains intact',f,'trade({99999},{gold=7});equal(remaining[99999],1);equal(remaining.gold,7);equal(calls.returns,1);equal(next(calls.rewards),nil)')
for missing in [False,True]:
 f='changes/p99-conversion-ambient/thurgadina/Lieutenant_Ulfur.lua';extra='local handlers={}; calls.received={}\n';dependencies=[]
 for n in sorted(set(receivers.values())):
  rf='changes/p99-conversions-velious-flavor/thurgadina/Guard_'+n+'.lua';body=P.joinpath(rf).read_text();dependencies.append({'path':rf,'sha256':hashlib.sha256(body.encode()).hexdigest()});extra+='do local env=setmetatable({}, {__index=_G}); local chunk=assert(loadstring('+json.dumps(body)+')); setfenv(chunk,env);chunk();handlers["'+n+'"]=env.event_signal end\n'
 extra+='local receiverNames={'+','.join('['+str(id)+']="'+n+'"' for id,n in receivers.items())+'}\n'
 extra+='eq.signal=function(id,sig,delay) table.insert(calls.signals,{id,sig,delay}); if '+('id==115104' if missing else 'false')+' then return end; local actor={Emote=function(_,text) table.insert(calls.received,{id,text}) end}; handlers[receiverNames[id]]({self=actor,signal=sig}) end\n'
 add('Ulfur composed receivers isolated '+('one absent target' if missing else 'distinct actors and source order'),f,'event_waypoint_arrive({self=npc,wp=15});equal(#calls.signals,12);equal(#calls.received,'+str(11 if missing else 12)+');'+''.join(f'equal(calls.received[{i}][1],{id});' for i,id in enumerate([id for id in receivers if not(missing and id==115104)],1)))
 cases[-1]['setupExtra']+='\n'+extra;cases[-1]['dependencySources']=dependencies
(O/'runtime-assertions.json').write_text(json.dumps({'kind':'isolated-script-logic-not-live-runtime','cases':cases},indent=2)+'\n');print(len(cases))
