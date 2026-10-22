import json,pathlib,hashlib
R=pathlib.Path(__file__).resolve().parents[2]
def rd(p):return json.loads((R/p).read_text())
def sha(s):return hashlib.sha256(s.encode()).hexdigest()
q=rd('changes/p99-sz-quarg-alias.json')['sources'][0];qf=q['proposedFile'];new=q['afterSha256'];old='51ce2b49a556cd79e3f3ce912d42b9e276db829c6e381ae61dcb31e53436b134'
for f in ['changes/p99-sz-review/hash-sidecar.json','changes/p99-sz-review/ledger-records.json']:
 p=R/f;doc=json.loads(p.read_text().replace(old,new))
 for record in doc.values():
  for ref in record.get('proposals',record.get('proposal_sources',[])):
   if ref.get('proposal')=='changes/p99-sz-quarg-alias.json':ref['proposal_sha256']=sha((R/ref['proposal']).read_text())
 p.write_text(json.dumps(doc,indent=2)+'\n')
cases=[]
def add(name,file,assertions,extra='',baseline=False):
 c={'name':name,'sourceSha256':hashlib.sha256((R/file).read_bytes()).hexdigest(),'assertions':assertions,'coverageKind':'baseline_reproduction' if baseline else 'isolated_proposed_source'}
 c['file' if baseline else 'proposedFile']=file
 if extra:c['setupExtra']=extra
 cases.append(c)
add('Quarg baseline array rewards are silently absent','effective/quests/fieldofbone/Crusader_Quarg.lua','trade({12735,5142});reward(17035,0);reward(5143,0);equal(calls.exp,100000);equal(remaining[12735],0);equal(remaining[5142],0)',baseline=True)
add('Quarg both first-five-stage outputs, extra, existing XP, repeated full offer',qf,'character.level=1;character.class=1;trade({12735,5142,99999});reward(17035,1);reward(5143,1);equal(calls.exp,100000);faction(445,10);faction(441,10);equal(remaining[99999],1);equal(remaining[12735],0);equal(remaining[5142],0);equal(calls.returns,1);trade({5142,12735});reward(17035,2);reward(5143,2);equal(calls.exp,200000);equal(calls.returns,2)')
for ids in ['12735','5142','99999','12735,99999','5142,99999']:
 add('Quarg incomplete or wrong offer '+ids,qf,'trade({'+ids+'});reward(17035,0);reward(5143,0);equal(calls.exp,0);equal(next(calls.factions),nil);equal(calls.returns,1);'+''.join('equal(remaining['+i+'],1);' for i in ids.split(',')))
add('Quarg preserves preceding Zand note reward',qf,'trade({18054,99999});reward(17034,1);reward(17035,0);reward(5143,0);equal(calls.exp,10000);faction(445,10);faction(441,10);equal(remaining[99999],1)')
add('Quarg source guard checks eligibility before consumption under injected nonfriendly fixture',qf,'trade({12735,5142});reward(17035,0);reward(5143,0);equal(remaining[12735],1);equal(remaining[5142],1);equal(calls.exp,0);equal(calls.returns,1)','other.GetFaction=function() return 9 end')
c=rd('changes/p99-source-caitiff-depop.json')['sources'][0]['proposedFile']
add('Caitiff complete pair keeps existing reward XP and requests depop only on success',c,'character.level=1;character.class=1;trade({10179,10178,99999});reward(5408,1);equal(calls.exp,5000);equal(calls.depops,1);equal(remaining[10179],0);equal(remaining[10178],0);equal(remaining[99999],1);equal(calls.returns,1);equal(next(calls.factions),nil)')
for ids in ['10179','10178','99999','10179,10179','10178,99999']:
 add('Caitiff rejected offer does not depop '+ids,c,'trade({'+ids+'});reward(5408,0);equal(calls.exp,0);equal(calls.depops,0);equal(calls.returns,1)')
add('Caitiff repeated invalid offers do not advance encounter',c,'trade({10179});trade({10178});trade({99999});reward(5408,0);equal(calls.depops,0);equal(calls.exp,0);equal(calls.returns,3)')
add('Caitiff repeated complete invocations each request depop; not a world-respawn test',c,'trade({10179,10178});trade({10178,10179});reward(5408,2);equal(calls.depops,2);equal(calls.exp,10000)')
for s in rd('changes/p99-source-scope-disables.json')['sources']:
 add('Disabled historical source compiles and unrelated offer returns: '+s['target'],s['proposedFile'],'trade({99999});equal(next(calls.rewards),nil);equal(calls.exp,0);equal(remaining[99999],1);equal(calls.returns,1);equal(calls.depops,0)')
# Unchanged source substeps: behavior capture is not a full-chain or activation claim.
for key,inp,out,xp in [('firiona/Drake_Mountainstorm',10033,10013,0),('freportw/Janam_Rekish',18015,18016,375),('freportw/Rebby_Willend',18923,13158,50),('overthere/Dom_K-Perl',10029,18068,500)]:
 f='effective/quests/'+key+'.lua'
 add('Unchanged documented substep accepted and repeat '+key,f,f'trade({{{inp},99999}});reward({out},1);equal(calls.exp,{xp});equal(remaining[{inp}],0);equal(remaining[99999],1);trade({{{inp}}});reward({out},2);equal(calls.exp,{xp*2})',baseline=True)
 add('Unchanged documented substep wrong offer '+key,f,'trade({99999});equal(next(calls.rewards),nil);equal(remaining[99999],1);equal(calls.exp,0);equal(calls.returns,1)',baseline=True)
f='effective/quests/neriakc/Nallar_Q-Tentu.lua'
add('Unchanged Nallar translation complete pair and repeated offer',f,'trade({18401,10032,99999});reward(18401,1);equal(remaining[18401],0);equal(remaining[10032],0);equal(remaining[99999],1);equal(calls.exp,53110);trade({10032,18401});reward(18401,2);equal(calls.exp,106220)',baseline=True)
for i in [18401,10032,99999]:add('Unchanged Nallar incomplete translation '+str(i),f,'trade({'+str(i)+'});equal(next(calls.rewards),nil);equal(remaining['+str(i)+'],1);equal(calls.exp,0)',baseline=True)
for name in ['Guard_Heridion','Guard_Korlack','Guard_Lecknar','Guard_Menbuknar']:
 add('Unchanged Paineel key service '+name,'effective/quests/paineel/'+name+'.lua',"character.level=1;character.class=1;say('hail');reward(6378,0);say('need keyz');reward(6378,1);say('need keyz');reward(6378,2);say('unrelated');reward(6378,2)",baseline=True)
add('Unchanged Tazgar documented hail penalty, unknown magnitude retained','effective/quests/soltemple/Tazgar.lua',"say('unrelated');equal(next(calls.factions),nil);say('hail');faction(415,-50);say('hail');faction(415,-100)",baseline=True)
(R/'changes/p99-source-review/runtime-assertions.json').write_text(json.dumps({'scope':'Hash-bound normalized Lua logic with pinned helpers and mocked APIs. Disabled-source cases run historical code deliberately: they test compilation/rejection, NOT runtime admission. Static metadata receipt checks actual disabled row/header. No inventory settlement, world depop, acquisition, UI or numeric-P99 proof.','cases':cases},indent=2)+'\n')
setup=(R/'tools/p99-test-fixture.lua').read_text()+'\npackage.preload["items"]=function()\n'+(R/'sources/projecteq/lua_modules/items.lua').read_text()+'\nend\n'
run=[{'name':c['name'],'source':(R/(c.get('proposedFile')or c['file'])).read_text(),'setup':setup+c.get('setupExtra',''),'assertions':c['assertions']}for c in cases]
pathlib.Path('/tmp/p99-source-review-runtime-input.json').write_text(json.dumps(run)+'\n')
print(len(cases),'scenarios')
