import pathlib,json,re,hashlib
s=pathlib.Path(open('/tmp/p99-validation-current-path').read());a=pathlib.Path(open('/tmp/p99-validation-current-artifacts').read());m=json.load(open(s/'manifest.json'));p=json.load(open(s/'changes/p99-combined-audit.json'))
def ids(table):
 out=set()
 for file in m['tables'][table]['shards']:
  for line in open(s/file):
   if line.strip():out.add(json.loads(line)['id'])
 return out
sets={'item':ids('items'),'faction':ids('faction_list')}
patterns=[('item',r'\bitem\d*\s*=\s*(\d+)'),('item',r':SummonItem\(\s*(\d+)'),('item',r':QuestReward\([^,\n]+,\s*[^,\n]+,\s*[^,\n]+,\s*[^,\n]+,\s*[^,\n]+,\s*(\d+)\s*[,)]'),('faction',r':Faction\(\s*(\d+)'),('item',r'\beq\.create_ground_object\(\s*(\d+)')]
def scan(files):
 count=0;missing=[]
 for file in files:
  text=(s/file).read_text()
  for kind,pattern in patterns:
   for match in re.finditer(pattern,text):
    id=int(match[1])
    if not id:continue
    count+=1
    if id not in sets[kind]:missing.append({'file':file,'kind':kind,'id':id,'line':text[:match.start()].count('\n')+1})
 return {'files':len(files),'literalReferences':count,'missing':missing}
baseline=[x.relative_to(s).as_posix()for x in (s/'effective').rglob('*.lua')]
proposed=[x['proposedFile']for x in p['sources']if x['proposedFile'].endswith('.lua')]
result={'method':'Diagnostic lexical literals: itemN hand-in keys, SummonItem, scalar QuestReward, Faction, create_ground_object. Includes disabled/unreachable code and may include comments; excludes dynamic expressions, random pools, keyed tables and acquisition. Missing baseline literals are not introduced regressions.','baselineEffective':scan(baseline),'proposedSources':scan(proposed)}
(a/'full-reference-diagnostic.json').write_text(json.dumps(result,indent=2));print(json.dumps({k:({'files':v['files'],'literalReferences':v['literalReferences'],'missing':len(v['missing'])}if isinstance(v,dict)else v)for k,v in result.items()},indent=2))
