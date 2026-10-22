import json,pathlib,hashlib,subprocess
base=pathlib.Path('changes/p99-support-source-review');review=json.loads((base/'lifecycle-review.json').read_text());d=json.loads((base/'lifecycle-sources.json').read_text());proposals=[json.load(open('changes/'+n+'.json')) for n in ['p99-support-lifecycle-scope','p99-support-lifecycle-values']]
sha=lambda x:hashlib.sha256(x if isinstance(x,bytes) else x.encode()).hexdigest()
assert len(review['records'])==216 and len({r['key'] for r in review['records']})==216
for i,r in enumerate(review['records']):
 assert r['key']==d[i]['key'] and r['reviewedSourceSha256']==sha(d[i]['text'])
 assert r['sourceEvidence']['pointer']==f'/{i}/text' and r['behavior'] and r['limitations']
 for prior in r.get('priorExactKeyReviews',[]):
  assert prior['sourceHashMatches'] and prior['recordSourceSha256']==r['reviewedSourceSha256']
  art=pathlib.Path(prior['artifact']);assert sha(art.read_bytes())==prior['artifactSha256']
for p in proposals:
 assert len(p['rows'])==len(p['sources'])
 for row,s in zip(p['rows'],p['sources']):
  assert row['table']=='quests';assert pathlib.Path(s['proposedFile']).read_bytes().decode()==row['after']['lua_content'];assert sha(row['after']['lua_content'])==s['afterSha256']
  assert {k:v for k,v in row['before'].items() if k not in ['enabled','lua_content']}=={k:v for k,v in row['after'].items() if k not in ['enabled','lua_content']}
  if p['id'].endswith('scope'):
   assert row['after']['enabled']==0 and row['after']['lua_content'].split('\n',2)[2]==row['before']['lua_content']
assert len(proposals[0]['rows'])==22 and len(proposals[1]['rows'])==3
cases=[]
for row in proposals[0]['rows']:
 cases.append({'Name':'preserved-body syntax '+row['after']['zone']+'/'+row['after']['name'],'Source':row['after']['lua_content'],'Setup':'eq={load_encounter=function() end}','Assertions':'assert(true)'})
changes={r['after']['zone']+'/'+r['after']['name']:r['after']['lua_content'] for r in proposals[1]['rows']}
setup='''spawns={}; timers={}; stops={}; guarded=0
eq={spawn2=function(...) table.insert(spawns,{...}) end, set_timer=function(n,v) timers[n]=v end, stop_timer=function(n) stops[n]=true end, ChooseRandom=function(...) return select(1,...) end}
mob={GetX=function() return 11 end,GetY=function() return 22 end,GetZ=function() return 33 end,GetHeading=function() return 44 end,SaveGuardSpot=function(self,x,y,z,h) assert(x==11 and y==22 and z==33 and h==44);guarded=guarded+1 end}
'''
for roll,n,ancient in [(1,2,False),(45,2,False),(46,3,False),(75,3,False),(76,1,False),(90,1,False),(91,1,True),(95,1,True),(96,4,False),(98,4,False),(99,5,False),(100,5,False)]:
 assertions=f'''event_spawn({{}}); assert(#spawns=={n}); assert(spawns[1][1]=={65139 if ancient else 65068})
for i=1,{n-1} do event_signal({{}}); assert(timers["spawn timer"]==nil) end
event_signal({{}}); assert(timers["spawn timer"]==990000)
event_timer({{timer="other"}}); assert(#spawns=={n})
event_timer({{timer="spawn timer"}}); assert(#spawns=={n*2}); assert(stops["spawn timer"])
'''
 cases.append({'Name':'croc last-death timer branch '+str(roll),'Source':changes['guktop/croc_trigger'],'Setup':setup+f'\nmath.random=function() return {roll} end','Assertions':assertions})
cases.append({'Name':'moldmaster exactly three sporelings and guard preservation','Source':changes['runnyeye/#The_Sporali_Moldmaster'],'Setup':setup,'Assertions':'''event_combat({self=mob,joined=true}); assert(guarded==0); event_combat({self=mob,joined=false}); assert(guarded==1); event_death_complete({self=mob}); assert(#spawns==3); for _,s in ipairs(spawns) do assert(s[1]==11164 and s[4]==11 and s[5]==22 and s[6]==33 and s[7]==44) end'''})
cases.append({'Name':'tar goo exactly two children with unchanged positions and no random chance','Source':changes['wakening/119017'],'Setup':setup+'\nmath.random=function() error("not stochastic anymore") end','Assertions':'''event_death_complete({self=mob}); assert(#spawns==2); for _,s in ipairs(spawns) do assert(s[1]==119122 and s[4]==11 and s[5]==22 and s[6]==33 and s[7]==44) end'''})
(base/'lifecycle-review-test-cases.json').write_text(json.dumps(cases,indent=2)+'\n')
run=subprocess.run(['/tmp/p99-ranger-lua-runner'],input=json.dumps(cases),text=True,capture_output=True)
report={'scope':'Isolated pinned GopherLua VM with mocked quest APIs; NOT game bridge/playthrough/settlement.','cases':len(cases),'passed':len(cases) if run.returncode==0 else None,'exitCode':run.returncode,'stdout':run.stdout,'stderr':run.stderr,'reviewSha256':sha((base/'lifecycle-review.json').read_bytes()),'proposalSha256':{p['id']:sha(pathlib.Path('changes/'+p['id']+'.json').read_bytes()) for p in proposals},'staticAssertions':['216 unique keys exactly match assignment/order/source SHA256.','22 scope rows differ only in enabled and two-line prefix; original complete bodies retained exactly.','Three value rows preserve all other row columns and matching proposed-source hashes.','Ten exact prior review artifacts and source hashes verified.','Croc twelve probability-boundary cases preserve original spawning outcomes and schedule990000 only after last death.','Moldmaster emits exactlythree11164 and preserves SaveGuardSpot behavior.','Tar goo emits exactlytwo119122 without RNG.']}
(base/'lifecycle-review-test-results.json').write_text(json.dumps(report,indent=2)+'\n');print(run.stdout,run.stderr);assert run.returncode==0;print('Static assertions passed;36 isolated Lua cases passed.')
