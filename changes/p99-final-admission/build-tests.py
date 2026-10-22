import json,pathlib,hashlib,re
R=pathlib.Path(__file__).resolve().parents[2];D=R/'changes/p99-final-admission';sha=lambda b:hashlib.sha256(b).hexdigest()
P=json.load(open(R/'changes/p99-final-admission.json'));V=json.load(open(D/'review.json'));cases=[]
def add(name,file,assertions,extra='',kind='isolated_mixed_source_logic'):
 c={'name':name,'sourceSha256':sha((R/file).read_bytes()),'assertions':assertions,'coverageKind':kind}
 c['file' if file.startswith('effective/') else 'proposedFile']=file
 if file.startswith('effective/'):c['assertionScope']='Unchanged baseline behavior capture, not proof of P99 parity or admission.'
 if extra:c['setupExtra']=extra
 cases.append(c)
bykey={x['key']:x for x in V['records']}
for r in V['records']:
 if r['disposition']=='disabled_sole_later_source_body_preserved':
  names=sorted(set(re.findall(r'function\s+(event_\w+)\s*\(', (R/r['proposedFile']).read_text())))
  add('Historical disabled body loads with retained handlers: '+r['key'],r['proposedFile'],';'.join('equal(type('+n+'),"function","'+n+'")'for n in names),'','disabled_historical_body_load_not_runtime_admission')
for key,inp,out in [('freportn/Edwardian_Holyblade',18737,13554),('neriakc/Ulraz_S-Lon',18757,13586)]:
 f=bykey[key]['proposedFile']
 add('Preserved legacy note, extra, repeated and duplicate note: '+key,f,f'trade({{{inp},99999}});reward({out},1);equal(calls.exp,100);equal(remaining[99999],1);equal(remaining[{inp}],0);trade({{{inp},{inp}}});reward({out},2);equal(calls.exp,200);equal(remaining[{inp}],1);equal(calls.returns,2);equal(next(calls.factions),nil)')
 add('Wrong offer is returned: '+key,f,'trade({99999});equal(remaining[99999],1);equal(next(calls.rewards),nil);equal(calls.exp,0);equal(calls.returns,1)')
 add('Greeting retains identity without a later training hook: '+key,f,'say("hail");equal(#calls.speech,1);equal(next(calls.rewards),nil);say("armor");say("training");say("ready to begin your tests");equal(#calls.speech,1);equal(next(calls.rewards),nil)')
for ids in [[9927,9928,9929,9930],[9927],[9928,99999]]:
 f=bykey['freportn/Edwardian_Holyblade']['proposedFile'];add('Edwardian later bracers rejected: '+str(ids),f,'trade({'+','.join(map(str,ids))+'});equal(next(calls.rewards),nil);equal(calls.exp,0);equal(calls.returns,1);'+''.join(f'equal(remaining[{i}],{ids.count(i)});'for i in set(ids)))
for ids in [[19574,16197,19554],[19573],[19570,19570,19570,19570]]:
 f=bykey['neriakc/Ulraz_S-Lon']['proposedFile'];add('Ulraz later weapon and shield rejected: '+str(ids),f,'trade({'+','.join(map(str,ids))+'});equal(next(calls.rewards),nil);equal(calls.exp,0);equal(next(calls.factions),nil);equal(calls.returns,1);'+''.join(f'equal(remaining[{i}],{ids.count(i)});'for i in set(ids)))
f=bykey['neriakc/Ulraz_S-Lon']['proposedFile'];add('Ulraz independent nonreward Ultricle lore retained',f,'say("ultricle");equal(#calls.speech,1);assert(string.find(calls.speech[1],"gray region barren of life",1,true));equal(next(calls.rewards),nil)')
for key,ids in [('kithicor/Innkeep_Min',[21699,99999]),('lavastorm/Symbell_Sunara',[13418,99999]),('nektulos/Kamidra_Voragone',[13088,13088,13088,13088]),('cabwest/Marthor',[8348,8348,8348,8348]),('cabwest/Marthor',[4199,99999]),('neriakc/Medron_Y-Lask',[19571,16170,16170,99999])]:
 f=bykey[key]['proposedFile'];extra='npc.DoAnim=function(_,n) calls.anim=n end' if key.endswith('Medron_Y-Lask') else ''
 add('Removed later offer returned without state or rewards: '+key+str(ids),f,'trade({'+','.join(map(str,ids))+'});equal(next(calls.rewards),nil);equal(calls.exp,0);equal(next(calls.factions),nil);equal(calls.returns,1);'+''.join(f'equal(remaining[{i}],{ids.count(i)});'for i in set(ids)),extra)
for key in ['kithicor/Innkeep_Min','lavastorm/Symbell_Sunara','nektulos/Kamidra_Voragone','cabwest/Marthor','neriakc/Medron_Y-Lask']:
 f=bykey[key]['proposedFile'];extra='npc.DoAnim=function(_,n) calls.anim=n end' if key.endswith('Medron_Y-Lask') else ''
 add('Ambient hail and repeated unrelated offer preserved: '+key,f,'say("hail");equal(#calls.speech,1);say("I have returned");say("help");say("master tynn");equal(#calls.speech,1);trade({99999});trade({99999});equal(remaining[99999],1);equal(calls.returns,2);equal(next(calls.rewards),nil);equal(calls.exp,0)'+(';equal(calls.anim,67)' if extra else ''),extra)
f=bykey['rivervale/Artisan_Bill_Whistletop']['proposedFile']
for race in ['Human','Halfling']:
 add('Bill no later cultural reward or task for '+race,f,'say("hail");say("tasks");say("armor patterns");equal(#calls.speech,'+('0' if race=='Halfling' else '3')+');trade({12372,12373,13077,14019});equal(calls.returns,1);equal(next(calls.rewards),nil);equal(remaining[12372],1);equal(remaining[12373],1);equal(remaining[13077],1);equal(remaining[14019],1);equal(calls.exp,0);trade({99999});equal(remaining[99999],1);equal(calls.returns,2)','other.GetRaceName=function() return "'+race+'" end')
# A behavior capture of the sole unresolved baseline: no claim of its correctness or activation.
r=bykey['gfaydark/Mazziana_Ridgerunner'];add('Unresolved Mazziana baseline consumes scalp without reward',r['baselineFile'],'trade({13791,99999});equal(remaining[13791],0);equal(remaining[99999],1);equal(calls.exp,0);equal(next(calls.rewards),nil);equal(next(calls.factions),nil);equal(calls.returns,1)','','baseline_verification')
(D/'runtime-assertions.json').write_text(json.dumps({'scope':'Hash-bound normalized isolated Lua VM. Historical disabled bodies load deliberately and retained handler definitions are checked, NOT admission. Mixed sources execute focused behavior using actual pinned items helper and strict mocked APIs. No game bridge, world lifecycle, inventory settlement or UI proof.','cases':cases},indent=2)+'\n')
setup=(R/'tools/p99-test-fixture.lua').read_text()+'\npackage.preload["items"]=function()\n'+(R/'sources/projecteq/lua_modules/items.lua').read_text()+'\nend\n'
out=[]
for c in cases:
 f=R/(c.get('proposedFile')or c['file']);assert sha(f.read_bytes())==c['sourceSha256'];out.append({'name':c['name'],'source':f.read_text(),'setup':setup+'\n'+c.get('setupExtra',''),'assertions':c['assertions']})
pathlib.Path('/tmp/p99-final-admission-runtime-input.json').write_text(json.dumps(out))
print(len(cases),'scenarios across',len({c.get('proposedFile')for c in cases if c.get('proposedFile')}),'proposed sources, plus1unchanged baseline')
