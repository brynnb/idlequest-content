import json,re,hashlib,pathlib
D=pathlib.Path('changes/p99-final-chain-closure');R=pathlib.Path('.');h=lambda s:hashlib.sha256(s.encode()).hexdigest()
j=json.load(open(D/'review.json'));rs=j['records']+j['additionalRecords'];cases=[];bindings=[]
extra='''spawns={};timers={};stops={};npc.GetX=function() return 10 end;npc.GetY=function() return 20 end;npc.GetZ=function() return 30 end;npc.GetHeading=function() return 40 end
npc.Shout=npc.Say;eq.spawn2=function(...) table.insert(spawns,{...});return npc end;eq.unique_spawn=eq.spawn2;eq.depop=function() calls.depops=calls.depops+1 end;eq.set_timer=function(a,b) timers[a]=b end;eq.stop_timer=function(a) stops[a]=true end;eq.depop_all=function(id) calls.depopAll=id end
'''
def add(r,label,a,x='',baseline=False):
 f=r['baselineFile'] if baseline or not r.get('proposedFile') else r['proposedFile'];z=dict(key=r['key'],name=r['key']+' '+label,assertions=a,setupExtra=extra+x,sourceSha256=h(R.joinpath(f).read_text()))
 if f.startswith('changes/'):z['proposedFile']=f
 else:z.update(file=f,coverageKind='baseline_verification')
 cases.append(z)
for r in rs:
 if not r.get('proposedFile'):continue
 s=R.joinpath(r['proposedFile']).read_text();bindings.append(dict(key=r['key'],proposedFile=r['proposedFile'],sourceSha256=h(s),baselineSourceSha256=r['baselineSourceSha256'],enabled=r['proposedEnabled']))
 if r['action']=='disable_preserve_full_body':
  names=re.findall(r'^function (\w+)\(',s,re.M);add(r,'archival source loads inert with preserved callbacks',';'.join('assert(type('+f+')=="function")' for f in names)+';equal(#spawns,0);equal(calls.depops,0);equal(next(calls.rewards),nil)')
 k=r['key'];a=None;x=''
 if k=='befallen/#a_skeletal_foreman':a='event_spawn({self=npc});equal(timers.shout,300000);event_timer({self=npc,timer="shout"});equal(#calls.speech,2);event_death_complete({self=npc});equal(spawns[1][1],36091)'
 elif k=='befallen/a_skeletal_excavator':a='math.random=function() return 21 end;event_death_complete({self=npc});equal(#spawns,0);math.random=function() return 20 end;event_death_complete({self=npc});equal(spawns[1][1],36092)'
 elif k=='cazicthule/#a_Thul_Tae_Ew_High_Priest':a='event_spawn({self=npc});equal(#spawns,9);equal(spawns[1][1],48057);for i=2,5 do equal(spawns[i][1],48029) end;event_death_complete({self=npc});equal(calls.signals[1][1],48057);equal(calls.signals[1][2],1);equal(calls.signals[1][3],5)'
 elif k=='cazicthule/#Avatar_of_Fear':a='event_death_complete({self=npc});equal(calls.signals[1][1],48030);equal(calls.depopAll,48253)'
 elif k=='frontiermtns/#a_goblin_whipcracker':
  x='eq.get_zone_time=function() return {zone_hour=19} end;other.GetLanguageSkill=function() return 100 end;buff=false;other.FindBuff=function(_,id) equal(id,5574);return buff end;'
  a='event_say({self=npc,other=other,message="start the contest",language=14});equal(#spawns,0);buff=true;event_say({self=npc,other=other,message="start the contest",language=14});equal(#spawns,3);equal(spawns[1][1],92198);equal(spawns[2][1],92199);equal(spawns[3][1],92200)'
 elif k=='kithicor/#Blackened_Treant':a='event_death_complete({self=npc});equal(#spawns,10);for _,s in ipairs(spawns) do equal(s[1],20300) end'
 elif k=='kithicor/#Blackened_Tree_Limb':
  x='eq.get_entity_list=function() return {GetNPCList=function() return {entries=function() return nil end} end} end;'
  a='event_death_complete({self=npc});equal(spawns[1][1],20301);equal(spawns[1][4],17);equal(spawns[1][5],27)'
 elif k in ['lakeofillomen/Impervious_Bloodbeast','lakerathe/#Gnoll_Scavenger','nro/a_lamented_knight']:
  a='event_death_complete({self=npc});equal(calls.signals[1][1],'+str({'lakeofillomen/Impervious_Bloodbeast':85091,'lakerathe/#Gnoll_Scavenger':51156,'nro/a_lamented_knight':392057}[k])+');equal(calls.signals[1][2],0)'
 elif k in ['nro/a_haunt','nro/a_spirit','nro/a_guardian_tormentor']:
  a='event_death_complete({self=npc});equal(spawns[1][1],'+str({'nro/a_haunt':392105,'nro/a_spirit':392106,'nro/a_guardian_tormentor':392107}[k])+');equal(spawns[1][4],10);equal(spawns[1][5],20);equal(spawns[1][6],30);equal(spawns[1][7],40)'
 elif k=='qey2hh1/12183':a='event_spawn({self=npc});equal(timers.Werewolf1Depop,1800000);for i=1,3 do event_death_complete({self=npc}) end;equal(#spawns,0);event_death_complete({self=npc});equal(spawns[1][1],12185)'
 elif k=='qey2hh1/12184':a='event_death_complete({self=npc});equal(spawns[1][1],12185)'
 elif k.startswith('rathemtn/'):
  a='event_spawn({self=npc});event_death_complete({self=npc});equal(spawns[1][1],'+('50230' if 'Rambling' in k else '50231')+');equal(#calls.speech,2)'
 elif k=='timorous/Draz_Nurakk':a='event_death_complete({self=npc});equal(#spawns,6);for _,s in ipairs(spawns) do equal(s[1],96322) end'
 elif k in ['timorous/Grandmaster_Rinmark','timorous/Master_Rinmark']:
  t='Depop1' if 'Grand' in k else 'Depop2';n=96319 if 'Grand' in k else 96320
  a=f'event_spawn({{self=npc}});equal(timers.{t},90000);event_timer({{self=npc,timer="unrelated"}});equal(#spawns,0);event_combat({{self=npc,joined=true}});equal(stops.{t},true);event_combat({{self=npc,joined=false}});equal(timers.{t},90000);event_timer({{self=npc,timer="{t}"}});equal(spawns[1][1],{n});equal(calls.depops,1)'
 elif k=='timorous/Rinmark':a='event_spawn({self=npc});equal(timers.Depop3,90000);event_combat({self=npc,joined=true});equal(stops.Depop3,true);event_timer({self=npc,timer="Depop3"});equal(calls.depops,1);event_death_complete({self=npc});equal(#calls.speech,2)'
 elif k.startswith('warslikswood/'):a='event_spawn({self=npc});equal(timers.signal_master,60000);event_timer({self=npc,timer="other"});equal(#calls.signals,0);event_timer({self=npc,timer="signal_master"});equal(stops.signal_master,true);equal(calls.signals[1][1],79127);equal(calls.signals[1][2],1);event_death_complete({self=npc});equal(calls.signals[2][2],2);event_signal({self=npc});equal(calls.depops,1)'
 elif k=='befallen/#Sir_Ariam_Arcanum':a='say("truth");reward(31492,1);reward(18474,1);say("dead");reward(31492,2);reward(18474,2);say("travel to felwithe");reward(31493,1);trade({99999},{gold=10});equal(remaining[99999],1);equal(remaining.gold,10);equal(calls.returns,1)'
 if a:add(r,'force-loaded historical chain identity (not disabled dispatch)',a,x)
 if k=='timorous/an_Iksar_master':
  add(r,'baseline later entry reproduction','say("test of patience");equal(#spawns,1);equal(spawns[1][1],96318);equal(calls.depops,1)',baseline=True)
  for phrase in ['test of patience','I request the test of patience','unrelated']:
   add(r,'later trial cannot be entered '+phrase,'say("'+phrase+'");equal(#spawns,0);equal(calls.depops,0);equal(next(calls.rewards),nil);equal(#calls.speech,0)')
  for phrase,item in [('return the hand to Cabilis',17036),('assist old Rinmark in completing his rock garden',17039),('student',17040)]:add(r,'classic request '+phrase,'say("'+phrase+'");reward('+str(item)+',1);equal(#spawns,0);equal(calls.depops,0)')
  for phrase in ['hail','master rinmark','talon southpaw','Gomoz','whistling fists']:add(r,'retained classic dialogue '+phrase,'say("'+phrase+'");equal(#calls.speech,1);equal(#spawns,0)')
  for item,out,xp in [(12815,12797,20000),(12829,None,30000),(12836,4195,30000)]:
   aa=f'trade({{{item},99999}},{{gold=10}});equal(remaining[{item}],0);equal(remaining[99999],1);equal(remaining.gold,10);equal(calls.exp,{xp});faction(444,20);faction(441,10);equal(calls.returns,1);trade({{{item}}});equal(calls.exp,{xp*2});equal(calls.returns,2);'
   aa+=f'reward({out},2)' if out else 'equal(next(calls.rewards),nil)'
   add(r,'classic trade extra/refund/repeat '+str(item),aa)
  add(r,'unmatched offer returned','trade({99999},{gold=10});equal(remaining[99999],1);equal(remaining.gold,10);equal(calls.returns,1);equal(next(calls.rewards),nil);equal(calls.exp,0)')
# Unchanged rows: source-bound baseline verification, not proposed fixes.
for r in rs:
 k=r['key']
 if k=='neriakc/Xantis_Ixtax':
  add(r,'retained ten-gold replacement plus extra and repeat','trade({13394,99999},{gold=11});reward(13394,1);equal(remaining[13394],0);equal(remaining[99999],1);equal(remaining.gold,1);equal(calls.returns,1);trade({13394},{gold=10});reward(13394,2);equal(calls.returns,2)')
  for coins in ['gold=9','platinum=1']:
   add(r,'underpaid or nonconfigured denomination '+coins,'trade({13394,99999},{'+coins+'});reward(13394,0);equal(remaining[13394],1);equal(remaining[99999],1);equal(calls.returns,1)')
  add(r,'missing ring retains gold','trade({99999},{gold=10});reward(13394,0);equal(remaining.gold,10);equal(remaining[99999],1)')
 elif k=='paineel/Librarian_Kesler':
  for topic in ['the history of paineel','the hole','the underfoot','the old paineel']:add(r,'known missing grant '+topic,'say("tell me about '+topic+'");equal(#calls.speech,1);equal(next(calls.rewards),nil)')
 elif k=='sebilis/#froglok_krup_knight':add(r,'unresolved encounter retained exact random branch','math.random=function() return 2 end;event_death_complete({self=npc});equal(#spawns,0);math.random=function() return 1 end;event_death_complete({self=npc});equal(spawns[1][1],89182)')
m={'scope':'Isolated normalized Lua with central strict fixture and actual public items.lua. Disabled sources are force-loaded only to verify preserved historical identity, not game dispatch. Baseline cases are explicitly not proposed changes. No private runtime or real settlement proof.','caseCount':len(cases),'sourceCount':25,'bindings':bindings,'cases':cases};(D/'runtime-assertions.json').write_text(json.dumps(m,indent=2)+'\n');print('cases',len(cases))
