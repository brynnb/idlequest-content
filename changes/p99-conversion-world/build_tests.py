import hashlib,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/'changes/p99-conversion-world'
extra=r'''
calls.timers={}; calls.stops={}; calls.spawns={}; calls.grids={}; calls.hate={}; calls.illusions={}; calls.appearances={}; calls.doors={}; calls.moves={}; calls.messages={}; calls.globals={}
position={x=10,y=20,z=30,h=40}; present={}
npc.GetX=function() return position.x end; npc.GetY=function() return position.y end
npc.GetZ=function() return position.z end; npc.GetHeading=function() return position.h end
npc.Shout=npc.Say
npc.SendIllusionPacket=function(_,p) table.insert(calls.illusions,p) end
npc.SetAppearance=function(_,p) table.insert(calls.appearances,p) end
npc.MoveTo=function(_,...) table.insert(calls.moves,{...}) end
eq.set_timer=function(name,ms) calls.timers[name]=ms end
eq.stop_timer=function(name) calls.stops[name]=true; calls.timers[name]=nil end
eq.spawn2=function(...) table.insert(calls.spawns,{...}) end
eq.start=function(id) table.insert(calls.grids,id) end
eq.depop=function() calls.depops=calls.depops+1 end
eq.set_proximity=function(...) calls.proximity={...} end
eq.force_door_open=function(id) table.insert(calls.doors,id) end
eq.message=function(color,msg) table.insert(calls.messages,{color,msg}) end
eq.set_global=function(name,value,scope,duration) calls.globals[name]={value,scope,duration} end
eq.delete_global=function(name) calls.globals[name]=nil end
eq.get_entity_list=function() return {GetMobByNpcTypeID=function(_,id) return {valid=present[id] or false,AddToHateList=function(_,target,hate) table.insert(calls.hate,{id,target,hate}) end} end} end
eq.attack_npc_type=function(id) table.insert(calls.hate,{id}) end
function run_event(name,fields) local e=fields or {};e.self=npc;e.other=other;_G['event_'..name](e) end
function trade_q(ids,q)
 local original=event_trade
 event_trade=function(e) e.qglobals=q;original(e) end
 trade(ids)
 event_trade=original
end
function tuple(actual,expected)
 equal(#actual,#expected,'tuple size')
 for i,v in ipairs(expected) do equal(actual[i],v,'tuple '..i) end
end
'''
cases=[]
def add(key,name,assertions):
 p=OUT/(key+'.lua')
 cases.append(dict(name=name,proposedFile=str(p.relative_to(ROOT)),sourceSha256=hashlib.sha256(p.read_bytes()).hexdigest(),setupExtra=extra,assertions=assertions))
add('neriakb/player','Neriak linked classic gates only, no LDoN event',r'''
for _,id in ipairs({1,2,49,50}) do run_event('click_door',{door={GetDoorID=function() return id end}}) end
tuple(calls.doors,{2,49,1,49,1,2});assert(event_enter_zone==nil)
''')
for name in ['#an_enraged_vampire','an_enraged_vampire']:
 add('frozenshadow/'+name,name+' keeps both cosmetic gender intents, not delivery',"character.choice=1;run_event('spawn');character.choice=2;run_event('spawn');equal(calls.illusions[1].gender,0);equal(calls.illusions[2].gender,1)")
add('eastwastes/a_Ry-Gorr_messenger','Messenger authored grid233 and departure19 timed respawn',"run_event('spawn');tuple(calls.grids,{233});run_event('waypoint_depart',{wp=18});assert(calls.timers.leave==nil);run_event('waypoint_depart',{wp=19});equal(calls.timers.leave,60000);run_event('timer',{timer='wrong'});equal(calls.depops,0);run_event('timer',{timer='leave'});equal(calls.depops,1);assert(calls.stops.leave)")
add('necropolis/A_Guardian_of_the_Shrine','Jaled trigger preserves exact7XY boundary and conditional owner hate',"run_event('spawn');tuple(calls.proximity,{3,17,13,27});run_event('enter');equal(#calls.hate,0);present[123011]=true;run_event('enter');tuple(calls.hate[1],{123011,other,1})")
add('necropolis/a_nest','Nest six beetles preserve all coordinates and one timed depop',"run_event('aggro');run_event('aggro');equal(#calls.spawns,6);equal(calls.depops,1);for i,p in ipairs({{10,20},{8,20},{12,20},{10,18},{10,22},{11,21}}) do tuple(calls.spawns[i],{123132,0,0,p[1],p[2],30,40}) end")
add('necropolis/a_pile_of_bones','Bones trigger one construct only on combat entry',"run_event('combat',{joined=false});equal(#calls.spawns,0);run_event('combat',{joined=true});run_event('combat',{joined=false});run_event('combat',{joined=true});equal(calls.depops,1);equal(#calls.spawns,1);tuple(calls.spawns[1],{123097,0,0,10,20,30,40})")
add('westwastes/A_sentinel-s_voice','Sentinel complete30XYZ warning bounds and authored respawn',"run_event('spawn');tuple(calls.proximity,{-20,40,-10,50,0,60});run_event('enter');run_event('enter');equal(calls.depops,1);equal(#calls.speech,1);assert(calls.speech[1]:find('Veeshan',1,true))")
add('skyshrine/A_Guardian_of_the_Shrine','Skyshrine warning only signal66 without pretending cross-zone dispatch',"run_event('signal',{signal=65});equal(#calls.speech,0);run_event('signal',{signal=66});equal(#calls.speech,1);assert(calls.speech[1]:find('flee the Skyshrine',1,true))")
warders={'#Hraashna_the_Warder':[128090,128091,128092],'#Nanzata_the_Warder':[128091,128092,128093],'#Tukaarak_the_Warder':[128090,128091,128093],'#Ventani_the_Warder':[128090,128092,128093]}
for name,ids in warders.items():
 add('sleeper/'+name,name+' each other warder suppresses wake; last death signals66 immediately',"for _,id in ipairs({"+','.join(map(str,ids))+"}) do present[id]=true;run_event('death_complete');equal(#calls.signals,0);present[id]=false end;run_event('death_complete');equal(#calls.signals,1);tuple(calls.signals[1],{128094,66,0});equal(#calls.speech,4)")
add('sleeper/#The_Sleeper','Sleeper sleep appearance intent and complete local wake spawn',"run_event('spawn');equal(calls.timers.sleep,1000);run_event('timer',{timer='wrong'});equal(#calls.appearances,0);run_event('timer',{timer='sleep'});tuple(calls.appearances,{1});assert(calls.stops.sleep);run_event('signal',{signal=65});equal(#calls.spawns,0);run_event('signal',{signal=66});equal(calls.depops,1);tuple(calls.spawns[1],{128089,1,0,-1499,-2344.8,-1052.8,0})")
for name in ['Bloodpriest_Ioukond','accolyte_of_Zek']:
 add('wakening/'+name,name+' unconditional cleanup receiver',"run_event('signal',{signal=0});equal(calls.depops,1);run_event('signal',{signal=999});equal(calls.depops,2)")
for name,timer,ms,x,y,grid in [('Berzerker_Dolvad','onset2',55000,-4310,-741,25),('Disciple_Atharm','onset3',90000,-4357,-715,26),('Berzerker_Voldak','onset1',58000,-4311,-720,24)]:
 checks=f"run_event('spawn');equal(calls.timers.{timer},{ms});run_event('timer',{{timer='wrong'}});equal(#calls.moves,0);run_event('timer',{{timer='{timer}'}});tuple(calls.moves[1],{{{x},{y},-183,-2,true}});assert(calls.stops.{timer});run_event('signal',{{signal=9}});equal(#calls.grids,0);run_event('signal',{{signal=1}});tuple(calls.grids,{{{grid}}})"
 if name=='Berzerker_Voldak':checks+=";tuple(calls.signals[1],{119168,1,300});run_event('signal',{signal=2});tuple(calls.signals[2],{119168,2,300});equal(#calls.speech,1)"
 add('wakening/'+name,name+' exact timed walk and authored grid; literal300ms signals',checks)
add('wakening/Corporal_Hlash','Hlash all timers, spatial gates, squad signals and four defender positions',r'''
run_event('spawn');equal(calls.timers.onset,60000);equal(calls.timers.readygo,150000)
run_event('timer',{timer='wrong'});equal(#calls.moves,0)
run_event('timer',{timer='onset'});tuple(calls.moves[1],{-4341,-748,-183,-2,true});assert(calls.stops.onset)
run_event('timer',{timer='readygo'});equal(#calls.signals,0);equal(calls.timers.readygo,150000)
position.x=-4341;position.y=-748;run_event('timer',{timer='readygo'});assert(calls.stops.readygo)
for i,id in ipairs({119167,119166,119169}) do tuple(calls.signals[i],{id,1,300}) end
run_event('waypoint_arrive',{wp=4});equal(#calls.signals,3);run_event('waypoint_arrive',{wp=5});tuple(calls.signals[4],{119050,0,300})
say('troop attack');equal(#calls.signals,4);position.x=-225;position.y=1725;say('troop attack');tuple(calls.signals[5],{119167,2,300});equal(calls.messages[1][1],10)
run_event('signal',{signal=1});tuple(calls.grids,{23});run_event('signal',{signal=2});equal(#calls.spawns,4)
for i,p in ipairs({{-146,1703,374},{-149,1731,374},{-162,1738,374},{-172,1758,364}}) do tuple(calls.spawns[i],{119174,0,0,p[1],p[2],-192,p[3]}) end
''')
add('wakening/a_sifaye_defender','Defender all four hate targets, missing target fallback and5minute cleanup',r'''
for i,id in ipairs({119166,119167,119168,119169}) do present[id]=true;character.choice=i;run_event('spawn');tuple(calls.hate[i],{id}) end
present={};run_event('spawn');equal(#calls.hate,4);equal(calls.timers.leave,300000);equal(#calls.speech,1)
run_event('timer',{timer='wrong'});equal(calls.depops,0);run_event('timer',{timer='leave'});equal(calls.depops,1);assert(calls.stops.leave)
''')
add('wakening/Phenocryst','Phenocryst complete focus hand-ins, three giants and one-hour cleanup; policy remains disabled',r'''
say('hail');say('help you');say('find what');say('I will gather these stones for you');reward(1694,1);faction(458,10)
trade({1692,99999});reward(1701,1);equal(remaining[99999],1)
trade({1693});equal(calls.globals.veliumfocus[1],'1')
trade({1694,1695,1697,1696});reward(1698,1);equal(#calls.spawns,3);equal(calls.timers.cleanup,3600000)
tuple(calls.spawns[1],{119158,0,0,408.10,-690.21,-201.55,374});tuple(calls.spawns[2],{119158,0,0,-564.04,-985.80,-191.31,374});tuple(calls.spawns[3],{119164,0,0,303.02,254.44,-201.54,374})
trade({1698,1699,1699,99999});reward(1700,0);equal(remaining[1699],2)
trade({1698,1699,1699,1699});reward(1700,1);faction(458,65);equal(calls.exp,0);equal(calls.returns,5)
run_event('timer',{timer='wrong'});equal(#calls.signals,0);run_event('timer',{timer='cleanup'});tuple(calls.signals[1],{119158,0,0});tuple(calls.signals[2],{119164,0,0});assert(calls.stops.cleanup)
''')
add('wakening/Lieutenant_Krofer','Krofer optional preparation, safe state gate, P99 cash, squad spawn and exact replacement',r'''
say('prepared');reward(1706,1);say('next assignment');say('hail')
trade_q({22851,22851,22852,1703},{});equal(calls.exp,0);equal(remaining[22851],2)
trade_q({1702},{});equal(calls.exp,1000);equal(calls.globals.krofer_assignment[1],'1')
trade_q({22851,22851,22852,1703},{krofer_assignment='1'});equal(calls.exp,2000);tuple(calls.cash[1],{1,0,2,10});assert(calls.globals.krofer_assignment==nil)
trade_q({1704,99999},{});reward(1705,1);tuple(calls.cash[2],{0,5,4,11});equal(remaining[99999],1)
trade_q({1707},{});reward(1708,1);equal(calls.exp,4000);equal(#calls.spawns,4);faction(448,20);faction(419,20);faction(429,20);faction(430,-60)
for i,p in ipairs({{119168,-4975,-699},{119166,-4954,-697},{119167,-4954,-671},{119169,-4976,-672}}) do tuple(calls.spawns[i],{p[1],0,0,p[2],p[3],-182,126}) end
run_event('signal',{signal=0});tuple(calls.spawns[5],{119173,0,0,10,20,30,40});equal(calls.depops,1);equal(calls.returns,5)
''')
add('wakening/#Lieutenant_Krofer','Replacement Krofer exact report reward, wrong-item return and25minute expiry',"run_event('spawn');equal(calls.timers.leave,1500000);trade({99999});equal(calls.exp,0);equal(remaining[99999],1);trade({1708,99999});reward(1709,1);equal(calls.exp,1000);equal(remaining[99999],1);equal(calls.depops,1);run_event('timer',{timer='wrong'});equal(calls.depops,1);run_event('timer',{timer='leave'});equal(calls.depops,2);assert(calls.stops.leave)")
(OUT/'behavior-cases.json').write_text(json.dumps({'kind':'isolated-script-behavior-not-game-runtime','cases':cases},indent=2)+'\n')
