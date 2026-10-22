import json,pathlib,hashlib,re
root=pathlib.Path('.');h=lambda b:hashlib.sha256(b).hexdigest()
ledger=json.load(open('changes/p99-sz-review/ledger-records.json'))
text=json.dumps(ledger)
for r in ledger.values():
 if r['review_status']=='source_facets_reviewed_path_open':
  for s in r['sources']:text+='\n'+pathlib.Path(s['file']).read_text()
ids={int(n) for n in re.findall(r'\b\d{4,6}\b',text)}
ids.update(range(18450,18460));ids.update(range(4350,4360))
items=[]
for p in root.glob('data/items/*.ndjson'):
 for line in p.open():
  r=json.loads(line)
  if r['id'] in ids:items.append({'id':r['id'],'name':r['Name'],'file':str(p),'row_sha256':h(json.dumps(r,sort_keys=True,separators=(',',':')).encode())})
json.dump({'scope':'Name lookup aid for numeric references in reviewed text/source; a matching ID alone is NOT proof a number is an item nor a verified quest facet. Row hashes use canonical sorted compact JSON.','items':sorted(items,key=lambda x:x['id'])},open('changes/p99-sz-review/item-name-evidence.json','w'),indent=2)
support=[]
for table in ['tradeskill_recipe','tradeskill_recipe_entries','npc_types','spawnentry','spawn2','faction_list']:
 for p in root.glob('data/'+table+'/*.ndjson'):
  for line in p.open():
   r=json.loads(line)
   wanted=(table=='tradeskill_recipe' and r['id'] in [9235,9351,9766,9767,9727,9825]) or (table=='tradeskill_recipe_entries' and r['recipe_id'] in [9235,9351,9766,9767,9727,9825]) or (table=='npc_types' and r['id'] in [94052,94141]) or (table=='spawnentry' and r['npcID'] in [94052,94141]) or (table=='spawn2' and r['id'] in [13703,13704]) or (table=='faction_list' and r['id'] in [236,334,370])
   if wanted:support.append({'table':table,'file':str(p),'row':r,'row_sha256':h(json.dumps(r,sort_keys=True,separators=(',',':')).encode())})
refs=[]
for file,note in [('reference/server/internal/quest/lua_bridge.go','Class numeric and GetClassName display; findi literalContains; timer/ground-object effects; applyLuaScriptState/captureLuaScriptState'),('reference/server/internal/questluasource/source.go','Normalize legacy Class comparison to GetClassName; prevents false generic class-gate diagnosis'),('reference/server/internal/quest/closure_state_test.go','TestLuaHelperStateAcrossFreshEvents is actual reference bridge test, not executed as part of isolated Lua suite'),('reference/server/internal/quest/runtime_inventory_context_test.go','Actual PlayerInfo fixture Class5 uses Shadow Knight display spelling'),('reference/server/internal/quest/runtime_event.go','Fresh event state passed across script callbacks')]:
 p=pathlib.Path(file);refs.append({'file':file,'sha256':h(p.read_bytes()),'note':note})
json.dump({'hash_format':'Canonical sorted compact JSON for row hashes; raw bytes for source file hashes','rows':support,'runtime_references':refs},open('changes/p99-sz-review/supporting-data-evidence.json','w'),indent=2)
print(len(items),'item lookup rows;',len(support),'supporting rows;',len(refs),'runtime references')
p=root/'changes/p99-sz-review/supporting-data-evidence.json';out=json.load(p.open())
out['active_proposals']=[{'file':str(f),'sha256':h(f.read_bytes())} for f in sorted(root.glob('changes/p99-sz-*.json'))]
for file in ['sources/projecteq/lua_modules/items.lua','tools/p99-test-fixture.lua','tools/p99-lua-runner.go','changes/p99-sz-review/behavior-cases.json']:
 out['runtime_references'].append({'file':file,'sha256':h(pathlib.Path(file).read_bytes()),'note':'Pinned helper or isolated test artifact; mocked effects are not live runtime proof.'})
json.dump(out,p.open('w'),indent=2)
