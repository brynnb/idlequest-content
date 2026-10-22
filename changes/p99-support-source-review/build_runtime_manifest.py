import pathlib,json,hashlib,re,subprocess,collections,os
root=pathlib.Path('.');base=root/'changes/p99-support-source-review';sha=lambda x:hashlib.sha256(x if isinstance(x,bytes) else x.encode()).hexdigest()
proposals=[json.load(open(p)) for p in sorted(pathlib.Path('changes').glob('p99-support-*.json')) if json.load(open(p)).get('format')==1]
sources={};rows={};bindings=[]
for p in proposals:
 for r in p['rows']:
  assert r['table']=='quests';rows[r['after']['zone']+'/'+r['after']['name']]=r
 for s in p['sources']:
  text=pathlib.Path(s['proposedFile']).read_bytes().decode();assert sha(text)==s['afterSha256']
  matches=[r for r in p['rows'] if r['after']['lua_content']==text]
  row=matches[0] if len(matches)==1 else next(r for r in matches if __import__('urllib.parse',fromlist=['unquote']).unquote(s['target']).endswith('/'+r['after']['zone']+'/'+r['after']['name']+'.lua'))
  sources[s['proposedFile']]={'source':text,'sha256':sha(text),'key':row['after']['zone']+'/'+row['after']['name'],'row':row,'proposal':p['id']}
  bindings.append({'proposedFile':s['proposedFile'],'sourceSha256':sha(text),'key':sources[s['proposedFile']]['key'],'enabled':row['after']['enabled'],'proposal':p['id'],'baselineSourceSha256':sha(row['before']['lua_content'])})
assert len(sources)==92
bykey={v['key']:f for f,v in sources.items()};cases=[]
def add(key,name,assertions,extra='',kind='focused_functional'):
 f=bykey[key];cases.append({'name':name,'key':key,'proposedFile':f,'sourceSha256':sources[f]['sha256'],'setupExtra':extra,'assertions':assertions,'coverageKind':kind})
# Already central-suite-compatible named functional assertions, with source binding rechecked.
named=json.load(open(base/'named-review-runtime-cases.json'))['cases']
for c in named:
 assert c['proposedFile'] in sources and c['sourceSha256']==sources[c['proposedFile']]['sha256'];cases.append(c)
# Disabled sources are never admitted or called here. We force-load bytes in a fresh VM
# with encounter loading inert, checking original callback shapes plus separately proven headers.
for f,x in sources.items():
 r=x['row']
 if r['after']['enabled']!=0:continue
 before=r['before']['lua_content'];prefix=x['source'][:-len(before)]
 assert x['source'].endswith(before) and all(not l.strip() or l.strip().startswith('--')for l in prefix.splitlines())
 assert re.search(r'^--\s*enabled:\s*false\s*$',prefix,re.M)
 handlers=sorted(set(re.findall(r'function\s+(event_\w+)\s*\(',before)))
 assertions=''.join('assert(type('+h+')=="function");'for h in handlers)
 loaders=re.findall(r'eq\.load_encounter\(["\x27]([^"\x27]+)',before)
 assertions+='assert(#support_inert_loads=='+str(len(loaders))+');'
 for i,name in enumerate(loaders,1):assertions+='assert(support_inert_loads['+str(i)+']=='+json.dumps(name)+');'
 add(x['key'],x['key']+' preserved disabled body, forced load only; no activation',assertions,'support_inert_loads={}; eq.load_encounter=function(name) table.insert(support_inert_loads,name) end','disabled_body_preservation')
# The lifecycle worker supplied fourteen actual behavioral assertions for three changed values.
for c in json.load(open(base/'lifecycle-review-test-cases.json')):
 if c['Name'].startswith('preserved-body syntax '):continue
 matches=[x for x in sources.values() if x['source']==c['Source']];assert len(matches)==1
 add(matches[0]['key'],c['Name'],c['Assertions'],c['Setup'])
for c in json.load(open(base/'mixed-hint-tests.json'))['cases']:
 add('gfaydark/'+c['Name'].split(' ')[0],c['Name'],c['Assertions'],c['Setup'])
for c in json.load(open(base/'ocean-fishing-tests.json'))['cases']:
 add('oot/player',c['Name'],c['Assertions'],c['Setup'])
noeffects='equal(next(calls.rewards),nil);equal(calls.exp,0);equal(next(calls.factions),nil);equal(#calls.cash,0);equal(#calls.spells,0);equal(#calls.signals,0);equal(calls.depops,0);'
for key,msg,expected in [
 ('lfaydark/Grynnaf_Einoom','Hail, Grynnaf_Einoom','looks at Reviewer and wonders if he is looking for the Scalekeeper?'),
 ('lfaydark/Grynnaf_Einoom','HAIL','looks at Reviewer and wonders if he is looking for the Scalekeeper?'),
 ('lfaydark/Grynnaf_Einoom','Who is the scalekeeper?',"Ahh...Ye be lookin' for Nortlav then. Nortlav is a strong fella. Ye dunna want to mess with the likes of him. He's known as a dragonslayer. I heard that he keeps the scales of the dragons he's slain. Yer not impressed eh? All the dragons he's killed have died by the blade of a [rusty weapon]."),
 ('lfaydark/Grynnaf_Einoom','What rusty weapon?',"Aye. I dunno know why he does what he does. But every dragon he's killed died by the likes of a rusty weapon. I dunno where he is now. but I heard he can be found in the depths of Norrath. surrounded by darkness."),
 ('lfaydark/Grynnaf_Einoom','irrelevant',None),
 ('cabwest/Jaxxtz','Hail',"Greetings, Reviewer, Perhaps you've come to purchase some of my rare supplies? I have a special blend of eleven herbs and spices......oh wait.....I'm sold out of that......anyway. What can I do for you?"),
 ('cabwest/Jaxxtz','HAIL',"Greetings, Reviewer, Perhaps you've come to purchase some of my rare supplies? I have a special blend of eleven herbs and spices......oh wait.....I'm sold out of that......anyway. What can I do for you?"),
 ('cabwest/Jaxxtz','Vagnar',None),('cabwest/Jaxxtz','Dragon kin',None),('cabwest/Jaxxtz','irrelevant',None)]:
 assertion='say('+json.dumps(msg)+');equal(#calls.speech,'+str(1 if expected else 0)+');'
 if expected:assertion+='equal(calls.speech[1],'+json.dumps(expected)+');'
 add(key,key+' documented/preserved/removed dialogue '+msg,assertion+noeffects,'eq.say_link=function(s) return s end')
missing=set(sources)-{c['proposedFile']for c in cases};assert not missing,missing
manifest={'scope':'Current proposed files only, SHA256 bound. Functional assertions use central fixture; disabled sources are force-loaded only with encounter loading inert and callback-shape checks. Header admission and historical body-byte preservation are independently asserted by generator. No activation, live runtime, settlement or complete P99 parity claim.','sourceCount':len(sources),'caseCount':len(cases),'proposalCount':len(proposals),'bindings':bindings,'cases':cases}
(base/'runtime-assertions.json').write_text(json.dumps(manifest,indent=2)+'\n')
setup=pathlib.Path('tools/p99-test-fixture.lua').read_text()+'\npackage.preload["items"]=function()\n'+pathlib.Path('sources/projecteq/lua_modules/items.lua').read_text()+'\nend\n'
vmcases=[{'Name':c['name'],'Source':pathlib.Path(c['proposedFile']).read_bytes().decode(),'Setup':setup+'\n'+c.get('setupExtra',''),'Assertions':c['assertions']}for c in cases]
run=subprocess.run([os.environ.get('SUPPORT_LUA_RUNNER','/tmp/p99-ranger-lua-runner')],input=json.dumps(vmcases),text=True,capture_output=True)
report={'status':'passed'if run.returncode==0 else 'failed','exitCode':run.returncode,'manifestSha256':sha((base/'runtime-assertions.json').read_bytes()),'sourceCount':len(sources),'caseCount':len(cases),'disabledBodyShapeCases':sum(c.get('coverageKind')=='disabled_body_preservation'for c in cases),'currentFileReads':True,'runnerSourceSha256':sha(pathlib.Path('tools/p99-lua-runner.go').read_bytes()),'runnerBinarySha256':sha(pathlib.Path(os.environ.get('SUPPORT_LUA_RUNNER','/tmp/p99-ranger-lua-runner')).read_bytes()),'baseFixtureSha256':sha(pathlib.Path('tools/p99-test-fixture.lua').read_bytes()),'itemsModuleSha256':sha(pathlib.Path('sources/projecteq/lua_modules/items.lua').read_bytes()),'stdout':run.stdout,'stderr':run.stderr,'cases':[{'name':c['name'],'file':c['proposedFile'],'sourceSha256':c['sourceSha256']}for c in cases]}
(base/'runtime-manifest-receipt.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items()if k not in ['cases','stdout']}));assert run.returncode==0
