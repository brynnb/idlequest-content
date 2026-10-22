import pathlib,json,hashlib
root=pathlib.Path('.');sha=lambda b:hashlib.sha256(b).hexdigest();coverage=json.load(open('changes/p99-nz-coverage/page-coverage.json'))
recipes={q['id']:q for f in root.glob('data/tradeskill_recipe/*.ndjson') for l in f.open() if(q:=json.loads(l))}
entries=[q for f in root.glob('data/tradeskill_recipe_entries/*.ndjson') for l in f.open() if(q:=json.loads(l))]
checks=[]
for id,title,components,container,output in [(9778,'The Bones of Darak Lightforge',{10013:1,10024:1,10031:1,10032:1,10034:1,10037:1,16507:2},17512,6710),(9636,'The Bones of Darak Lightforge',{i:1 for i in range(6700,6708)},17080,6708),(9673,'The Fishslayers',{13870:4},17968,12155),(9697,'Tiny Skeletons',{12377:4},17986,12376),(9865,"The Lorekeeper's Scrolls",{i:1 for i in range(18264,18271)},17058,31825)]:
 e=[x for x in entries if x['recipe_id']==id];assert {x['item_id']:x['componentcount'] for x in e if x['componentcount']}==components;assert [x['item_id']for x in e if x['iscontainer']]==[container];assert [(x['item_id'],x['successcount'])for x in e if x['successcount']]==[(output,1)];before=recipes[id];assert before['enabled']==0
 evidence=next(x for x in coverage if x['title']==title)['evidence'];pid='p99-tz-recipe-'+str(id)
 p={'format':1,'id':pid,'summary':'Enable existing P99 quest combine with exact documented components, container and output; preserve every other recipe field.','baseManifestSha256':sha((root/'manifest.json').read_bytes()),'evidence':[{'url':evidence['url'],'note':f"Cached {evidence['fetchedAt']}; SHA256 {evidence['sha256']}. Full page read confirms {components} in container {container} creates one {output}. No probabilities/skill metadata changed. Actual inventory combine UI not tested."}],'rows':[{'table':'tradeskill_recipe','before':before,'after':{**before,'enabled':1}}],'sources':[]};(root/'changes'/f'{pid}.json').write_text(json.dumps(p,indent=2)+'\n');checks.append({'title':title,'recipe':before,'entries':e,'evidence':evidence,'entries_sha256':sha(json.dumps(e,sort_keys=True).encode()),'status':'Exact component/container/output match; enabled-only proposal; no runtime combine test'})
(root/'changes/p99-tz-review/recipe-review.json').write_text(json.dumps(checks,indent=2)+'\n')
id=10001;e=[x for x in entries if x['recipe_id']==id];assert {x['item_id']:x['componentcount'] for x in e if x['componentcount']}=={i:1 for i in range(14350,14360)};assert [(x['item_id'],x['successcount'])for x in e if x['successcount']]==[(14360,1),(14361,1)];assert [x['item_id']for x in e if x['iscontainer']]==[17510]
evidence=next(x for x in coverage if x['title']=="Tarton's Wheel")['evidence'];before=recipes[id];pid='p99-tz-recipe-10001';p={'format':1,'id':pid,'summary':'Enable exact documented ten-rod combine; retain known-conflicting nofail fallback explicitly, no invented research chance.','baseManifestSha256':sha((root/'manifest.json').read_bytes()),'evidence':[{'url':evidence['url'],'note':f"Cached SHA256 {evidence['sha256']}. Ten rods14350-14359 in GlowingChest17510 produce Staff14360 and Star14361, consuming chest. P99 explicitly warns research-dependent failure; current nofail1 is known conflict retained because no supported research skill/trivial/failure probability is supplied. Enabling only, NOT complete crafting parity; actual runtime combine untested."}],'rows':[{'table':'tradeskill_recipe','before':before,'after':{**before,'enabled':1}}],'sources':[]};(root/'changes'/f'{pid}.json').write_text(json.dumps(p,indent=2)+'\n');checks.append({'title':"Tarton's Wheel",'recipe':before,'entries':e,'evidence':evidence,'entries_sha256':sha(json.dumps(e,sort_keys=True).encode()),'status':'Exact components/outputs; known nofail conflict deliberately retained, no probability fabricated; enable-only proposal'})
for id,title in [(9835,'Wooly Fungus Quest'),(9777,"Yuio's Illness"),(10015,'Visceral Dagger')]:
 e=[x for x in entries if x['recipe_id']==id];checks.append({'title':title,'recipe':recipes[id],'entries':e,'entries_sha256':sha(json.dumps(e,sort_keys=True).encode()),'status':'Full entries read; already enabled; exact named component and output counts match page. World container/acquisition and live crafting unverified.'})
(root/'changes/p99-tz-review/recipe-review.json').write_text(json.dumps(checks,indent=2)+'\n')

for c in checks:
 if c["recipe"]["id"]==9835:c["status"]="Exact eight fungus in17946 to13966 verified; enabled-only proposal parent-owned changes/p99-wooly-recipe/proposal.json. No duplicate local proposal; no live crafting tested."
(root/"changes/p99-tz-review/recipe-review.json").write_text(json.dumps(checks,indent=2)+"\n")
extra_expectations=[]
for id,title,components,outputs,containers,failures in [
 (9809,'The Sword of Nobility',{2410:1,2411:1,2412:1,2413:1},{5403:1},[17878],{}),
 (2325,'Trooper Scale Armor',{14797:2,14796:1,13432:1},{14798:1,13432:1},[15,17164,17947],{13432:1}),
 (7703,'Trooper Scale Armor',{12785:1,13006:1,14798:1,16598:1},{14799:1},[19],{16598:1})]:
 e=[x for x in entries if x['recipe_id']==id];before=recipes[id]
 assert {x['item_id']:x['componentcount']for x in e if x['componentcount']}==components
 assert {x['item_id']:x['successcount']for x in e if x['successcount']}==outputs
 assert {x['item_id']:x['failcount']for x in e if x['failcount']}==failures
 assert sorted(x['item_id']for x in e if x['iscontainer'])==sorted(containers)
 assert before['enabled']==0
 evidence=next(x for x in coverage if x['title']==title)['evidence'];pid='p99-tz-recipe-'+str(id)
 p={'format':1,'id':pid,'summary':'Enable documented exact quest combine, preserving existing failure outputs, probabilities and all other recipe fields.','baseManifestSha256':sha((root/'manifest.json').read_bytes()),'evidence':[{'url':evidence['url'],'note':f"Full cached page SHA256 {evidence['sha256']}. Exact named components {components} and quest output {outputs} verified. Existing containers {containers}, failure outputs {failures}, skill/trivial and nofail retained, not invented or presented as full live crafting proof."}],'rows':[{'table':'tradeskill_recipe','before':before,'after':{**before,'enabled':1}}],'sources':[]}
 (root/'changes'/f'{pid}.json').write_text(json.dumps(p,indent=2)+'\n')
 checks.append({'title':title,'recipe':before,'entries':e,'evidence':evidence,'entries_sha256':sha(json.dumps(e,sort_keys=True).encode()),'status':'Documented component/output match; enabled-only proposal. Existing failure outputs and alternate container support preserved, numerical odds and live crafting not verified.'})
 extra_expectations.append({'recipeId':id,'nofail':before['nofail'],'enabled':1,'mustLearn':before['must_learn'],'replaceContainer':before['replace_container'],'components':list(map(list,components.items())),'containers':[[x,1]for x in containers],'outputs':list(map(list,outputs.items())),'failureOutputs':list(map(list,failures.items())),'evidence':evidence,'reviewArtifact':'changes/p99-tz-review/recipe-review.json','limits':'Exact named inputs and quest output verified. Preserve existing failure/replacement/skill metadata; container registration, world acquisition and actual crafting remain unverified.'})
(root/'changes/p99-tz-review/trooper-sword-recipe-expectations.json').write_text(json.dumps(extra_expectations,indent=2)+'\n')
(root/'changes/p99-tz-review/recipe-review.json').write_text(json.dumps(checks,indent=2)+'\n')

# Full Warrior Pike stages0-5 recipe review; later-era stages are not enabled.
pike=json.loads((root/'changes/p99-tz-review/warrior-pike-recipe-candidates.json').read_text());pike_expectations=[]
evidence=next(x for x in coverage if x['title']=='Warrior Pike Quests')['evidence']
for c in pike:
 before=c['recipe'];id=before['id'];es=c['entries'];after=dict(before);after_entries=[dict(e)for e in es];rows=[]
 if id in [3532,9776,9783,9792,9797]:
  assert before['enabled']==0;after['enabled']=1
 if id==5381:assert before['trivial']==17;after['trivial']=15
 if after!=before:rows.append({'table':'tradeskill_recipe','before':before,'after':after})
 if id==9783:
  bad=next(e for e in es if e['successcount']);assert bad['item_id']==12912 and bad['successcount']==1
  fixed={**bad,'item_id':12913};rows.append({'table':'tradeskill_recipe_entries','before':bad,'after':fixed});after_entries=[fixed if e==bad else e for e in es]
 if rows:
  pid='p99-tz-recipe-'+str(id)
  note='Full cached Warrior Pike page confirms exact components and output. Only enabled flag changed; all existing failure/odds metadata retained.'
  if id==9783:note+=' Correct wrong Four Warbeads12912 to documented Four Crushed Shields12913, required by Hikyg. Four12910 in17043 are unchanged.'
  if id==5381:note='Page explicitly states Legionnaire Mancatcher Crown smithing trivial15; correct17 to15. Components, reusable tool, failed-combine returns and every other field unchanged.'
  p={'format':1,'id':pid,'summary':note,'baseManifestSha256':sha((root/'manifest.json').read_bytes()),'evidence':[{'url':evidence['url'],'note':note+' Cached SHA256 '+evidence['sha256']+'. No world/crafting UI proof. Only documented stages0-5; stages6-8 excluded as page says Gates of Discord.'}],'rows':rows,'sources':[]};(root/'changes'/f'{pid}.json').write_text(json.dumps(p,indent=2)+'\n')
 components={e['item_id']:e['componentcount']for e in after_entries if e['componentcount']};outputs={e['item_id']:e['successcount']for e in after_entries if e['successcount']};failures={e['item_id']:e['failcount']for e in after_entries if e['failcount']};containers=[e['item_id']for e in after_entries if e['iscontainer']]
 pike_expectations.append({'recipeId':id,'nofail':after['nofail'],'enabled':after['enabled'],'mustLearn':after['must_learn'],'replaceContainer':after['replace_container'],'components':list(map(list,components.items())),'containers':[[x,1]for x in containers],'outputs':list(map(list,outputs.items())),'failureOutputs':list(map(list,failures.items())),'evidence':evidence,'reviewArtifact':'changes/p99-tz-review/warrior-pike-recipe-candidates.json','limits':'All thirteen recipes independently compared with page. Exact component/count/quest output and documented failure returns match except corrected9783 output;5381 trivial corrected. Soldier Pike trivial63 vs page under63 unresolved; Trooper65 fits page bound63-74 but not exact evidence; Mancatcher170 question-mark estimate and all failure odds unverified. Live crafting/container registration unverified.'})
 checks.append({'title':'Warrior Pike Quests','recipe':before,'entries':es,'evidence':evidence,'entries_sha256':sha(json.dumps(es,sort_keys=True).encode()),'status':'Full manual component/output/failure-return review; see pike expectations for corrections and exact metadata limits.'})
(root/'changes/p99-tz-review/warrior-pike-recipe-expectations.json').write_text(json.dumps(pike_expectations,indent=2)+'\n')
(root/'changes/p99-tz-review/recipe-review.json').write_text(json.dumps(checks,indent=2)+'\n')

id=13008;before=recipes[id];es=[x for x in entries if x['recipe_id']==id];components={i:1 for i in range(13170,13180)}
assert {x['item_id']:x['componentcount']for x in es if x['componentcount']}==components
assert [(x['item_id'],x['successcount'])for x in es if x['successcount']]==[(13181,1)]
assert [x['item_id']for x in es if x['iscontainer']]==[17012]
assert before['enabled']==0
evidence=next(x for x in coverage if x['title']=='Taxes')['evidence'];pid='p99-tz-recipe-13008'
p={'format':1,'id':pid,'summary':'Enable exact documented ten-payment Tax Collection Box combine; preserve every other recipe field.','baseManifestSha256':sha((root/'manifest.json').read_bytes()),'evidence':[{'url':evidence['url'],'note':'Full cached page SHA256 '+evidence['sha256']+' requires one each of ten payments13170-13179 in Tax Collection Box17012, producing Full Box13181. No odds, skills, container metadata or other fields changed; static recipe correction is not live crafting proof.'}],'rows':[{'table':'tradeskill_recipe','before':before,'after':{**before,'enabled':1}}],'sources':[]};(root/'changes'/f'{pid}.json').write_text(json.dumps(p,indent=2)+'\n')
x={'recipeId':id,'nofail':before['nofail'],'enabled':1,'mustLearn':before['must_learn'],'replaceContainer':before['replace_container'],'components':list(map(list,components.items())),'containers':[[17012,1]],'outputs':[[13181,1]],'failureOutputs':[],'evidence':evidence,'reviewArtifact':'changes/p99-tz-review/taxes-recipe-review.json','limits':'Exact ten distinct payments, container and quest output manually checked. Preserve existing nofail/replacement metadata; runtime world container and crafting remain unverified.'};(root/'changes/p99-tz-review/taxes-recipe-expectations.json').write_text(json.dumps([x],indent=2)+'\n')
checks.append({'title':'Taxes','recipe':before,'entries':es,'evidence':evidence,'entries_sha256':sha(json.dumps(es,sort_keys=True).encode()),'status':'Exact10 distinct payments, container and full-box output verified; enabled-only proposal, live crafting unverified.'});(root/'changes/p99-tz-review/recipe-review.json').write_text(json.dumps(checks,indent=2)+'\n')
