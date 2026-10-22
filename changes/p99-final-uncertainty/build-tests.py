import json,pathlib,re,hashlib
D=pathlib.Path('changes/p99-final-uncertainty');rs=json.load(open(D/'review.json'))['records'];cases=[]
extra='timers={};stops={};eq.set_timer=function(a,b) timers[a]=b end;eq.stop_timer=function(a) stops[a]=true end;eq.depop=function() calls.depops=calls.depops+1 end;other.Race=function() return "Human" end;'
def add(r,name,a,x=''):
 f=r.get('proposedFile',r['baselineFile']);s=pathlib.Path(f).read_text()
 c=dict(key=r['key'],name=r['key']+' '+name,sourceSha256=hashlib.sha256(s.encode()).hexdigest(),setupExtra=extra+x,assertions=a)
 if r.get('proposedFile'):c['proposedFile']=f
 else:
  c.update(file=f,coverageKind='baseline_verification',coverageNote='Unchanged exact-source characterization only, not proposed-source coverage or P99 parity certification.')
  c['name']=r['key']+' baseline characterization: '+name.replace('P99 exact','documented')
 cases.append(c)
trades={'cazicthule/48255':[(8723,8730)],'felwithea/Arrias_Arcanum':[(31493,31495)],'freporte/Sir_Artanis':[(31492,31496)],'freportn/Sir_Artanis':[(31492,31496)],'qey2hh1/Tarnic_McWillows':[(21987,21988)],'feerrott/Aqaar_Aluram':[(8720,8732)],'guktop/an_old_froglok':[(11275,18499)],'lakerathe/#Triathalon_Bike':[(16889,21800)],'southkarana/#Triathalon_Running_Shoes':[(21800,2300)],'northkarana/#Triathalon_Token':[(2300,20695)]}
for r in rs:
 k=r['key']
 # Source-bound load checks for every reviewed row, never misrepresented as runtime admission.
 add(r,'full source loads all preserved handlers',';'.join('assert(type('+n+')=="function")' for n in r['handlersReviewed'])+';equal(next(calls.rewards),nil)')
 if r.get('proposedFile'):
  if 'event_trade' in r['handlersReviewed']:add(r,'unmatched offer retains item and cash','trade({99999},{gold=10});equal(remaining[99999],1);equal(remaining.gold,10);equal(calls.returns,1);equal(next(calls.rewards),nil)')
  for i,o in trades.get(k,[]):
   add(r,'forced historical exact trade extra repeat '+str(i),f'trade({{{i},99999}},{{gold=10}});reward({o},1);equal(remaining[{i}],0);equal(remaining[99999],1);equal(remaining.gold,10);trade({{{i}}});reward({o},2)')
  if k=='cazicthule/48255':
   add(r,'preserved terminal timer','event_spawn({self=npc});equal(timers.depop,600000);event_timer({self=npc,timer="depop"});equal(stops.depop,true);equal(calls.depops,1)')
   for n,o in enumerate([8730,8728,8727,8726,8729],1):add(r,'preserved random reward option '+str(n),f'character.choice={n};trade({{8723}});reward({o},1);equal(calls.depops,1)')
  if k=='lakerathe/#Triathalon_Swim_Goggles':add(r,'preserved event hail','say("hail");reward(16889,1)')
  if k=='guktop/an_old_froglok':
   add(r,'preserved complete crown hand-in','trade({11274,11276,10254,26999});reward(11277,1);equal(calls.exp,500)')
   add(r,'partial crown returns','trade({11274,11276,10254});reward(11277,0);equal(remaining[11274],1)')
  if k=='neriaka/Bregna':add(r,'preserved exact later receipt','trade({26662,29921,26640,26632});reward(28740,1)')
  if k=='grobb/Bregna':
   add(r,'later receipt blocked without consumption','trade({26662,29921,26640,26632});reward(28740,0);for _,i in ipairs({26662,29921,26640,26632}) do equal(remaining[i],1) end')
   add(r,'independent belt branch unchanged extra repeat','trade({13916,99999},{gold=10});reward(15272,1);equal(remaining[99999],1);equal(remaining.gold,10);equal(calls.exp,100);faction(251,-1);faction(237,5);faction(308,1);trade({13916});reward(15272,2);equal(calls.exp,200)')
  if k=='sirens/Ravaging_Tsunami_Elemental':add(r,'preserved vial aggro and return','trade({11304,99999});reward(11304,1);equal(abilities[1][2],0);equal(abilities[2][2],0);equal(hate,1);equal(remaining[99999],1)','SpecialAbility={immune_aggro=1,no_harm_from_client=2};abilities={};npc.SetSpecialAbility=function(_,a,b) table.insert(abilities,{a,b}) end;npc.AddToHateList=function(_,who,n) hate=n end;')
  if k=='butcher/Dapper_Blackhammer':add(r,'preserved level40 historical recipe','trade({12880,6552},{platinum=500});reward(6551,1);equal(calls.exp,25000)')
  if k=='firiona/Allaria_Sneakyfeet':add(r,'preserved Whistler plans','say("i am worthy");reward(18347,1)')
  if k in ['kaladimb/Harnoff_Splitrock','qeynos/Yakem_Oreslinger']:
   add(r,'preserved restock container','say("'+('run an errand' if 'Harnoff' in k else 'looking for a job')+'");reward(17814,1)')
   for i in [10952,10953]:add(r,'preserved shipment '+str(i),f'trade({{{i},99999}});equal(remaining[{i}],0);equal(remaining[99999],1);equal(#calls.cash,1)')
 if k=='freportn/Palious_Jarten':
  add(r,'P99 exact ten-gold service extra repeat','trade({99999},{gold=11});equal(remaining[99999],1);equal(remaining.gold,1);equal(calls.spells[1][1],213);equal(calls.spells[1][2],42);trade({},{gold=10});equal(#calls.spells,2)')
  add(r,'underpayment retained','trade({99999},{gold=9});equal(remaining.gold,9);equal(#calls.spells,0)')
json.dump({'scope':'Isolated normalized Lua source-bound tests. Disabled scripts are force-loaded only to verify retained body; not live dispatch, settlement or UI validation.','caseCount':len(cases),'cases':cases},open(D/'runtime-assertions.json','w'),indent=2)
