import json,hashlib,pathlib,subprocess
base=pathlib.Path('changes/p99-support-source-review');p=json.load(open('changes/p99-support-ocean-fishing-scope.json'));r=p['rows'][0];proof=json.load(open(base/'ocean-fishing-proof.json'))
sha=lambda x:hashlib.sha256(x if isinstance(x,bytes) else x.encode()).hexdigest()
assert {k:v for k,v in r['before'].items() if k!='lua_content'}=={k:v for k,v in r['after'].items() if k!='lua_content'}
assert r['after']['enabled']==1
assert r['after']['lua_content'].split('\n',1)[1]==r['before']['lua_content'].split('function event_fish_success(e)')[0]
assert sha(r['after']['lua_content'])==proof['currentSourceSha256']==p['sources'][0]['afterSha256']
for d in proof['dependencies']:assert sha(pathlib.Path(d['file']).read_bytes())==d['sha256']
cases=[]
for name,globals_,count in [('no flag','{}',0),('string flag','{strongbox="1"}',1),('false non-nil flag','{strongbox=false}',1),('later epic flag only','{paladin_epic="3"}',0)]:
 setup='''ground={};deleted={};player={};globals='''+globals_+''';eq={get_qglobals=function(self)assert(self==player);return globals end,create_ground_object=function(...)table.insert(ground,{...})end,delete_global=function(g)table.insert(deleted,g)end}'''
 assertion='assert(event_fish_success==nil);event_enter_zone({self=player});assert(#ground=='+str(count)+');assert(#deleted=='+str(count)+')'
 if count:assertion+='; assert(deleted[1]=="strongbox"); local a=ground[1];assert(#a==6 and a[1]==13860 and a[2]==-9200 and a[3]==-430 and a[4]==-293 and a[5]==0 and a[6]==3000000)'
 cases.append({'Name':'classic strongbox '+name,'Source':r['after']['lua_content'],'Setup':setup,'Assertions':assertion})
run=subprocess.run(['/tmp/p99-ranger-lua-runner'],input=json.dumps(cases),text=True,capture_output=True)
report={'cases':cases,'exitCode':run.returncode,'passed':run.returncode==0,'stdout':run.stdout,'stderr':run.stderr,'sourceSha256':sha(r['after']['lua_content']),'proposalSha256':sha(pathlib.Path('changes/p99-support-ocean-fishing-scope.json').read_bytes()),'scope':'Isolated pinned Lua VM and static byte-preservation proof, not live gameplay.'};(base/'ocean-fishing-tests.json').write_text(json.dumps(report,indent=2)+'\n');print(run.stdout,run.stderr);assert run.returncode==0
