import json,pathlib,re,collections,hashlib
R=pathlib.Path(__file__).resolve().parents[2]
def read(p):return json.loads((R/p).read_text())
def norm(s):return re.sub('[^a-z0-9]','',s.lower())
A=read('changes/p99-source-review/source-navigation.json')['records'];P=read('reference/p99-evidence-index.json');names={};np={}
for table,out,field in [('items',names,'Name'),('npc_types',np,'name')]:
 for f in (R/'data'/table).glob('*.ndjson'):
  for l in f.read_text().splitlines():
   x=json.loads(l);out[x['id']]=x[field]
patterns={};idsbykey={};aliasbykey={}
for r in A:
 s=(R/r['baselineFile']).read_text();ids={x['id'] for x in r['itemIdentities']}
 for line in s.splitlines():
  if re.match(r'\s*--\s*items:',line):ids.update(map(int,re.findall(r'\d+',line)))
 for m in re.finditer(r'QuestReward\(\s*e\.self\s*,\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*(\d+)',s):ids.add(int(m[1]))
 idsbykey[r['key']]=sorted(ids)
 for i in ids:
  if i in names and len(norm(names[i]))>=8:patterns.setdefault(norm(names[i]),set()).add('item:'+str(i))
 alias=r['key'].split('/')[1]
 if alias.isdigit() and int(alias) in np:
  aliasbykey[r['key']]={'npcId':int(alias),'name':np[int(alias)]};patterns.setdefault(norm(np[int(alias)]),set()).add('npc:'+alias)
# Aho-Corasick exact normalized full-name search over every cached body and title.
nexts=[{}];fails=[0];outs=[set()]
for p,tags in patterns.items():
 state=0
 for c in p:
  if c not in nexts[state]:nexts[state][c]=len(nexts);nexts.append({});fails.append(0);outs.append(set())
  state=nexts[state][c]
 outs[state].update(tags)
queue=collections.deque(nexts[0].values())
while queue:
 v=queue.popleft()
 for c,u in nexts[v].items():
  queue.append(u);f=fails[v]
  while f and c not in nexts[f]:f=fails[f]
  fails[u]=nexts[f].get(c,0);outs[u].update(outs[fails[u]])
hits=collections.defaultdict(list)
for p in P:
 raw=(R/p['cachePath']).read_bytes();t=raw.decode('utf-8');assert hashlib.sha256(raw).hexdigest()==p['sha256'];state=0;found=set()
 for c in norm(p['title']+' '+t):
  while state and c not in nexts[state]:state=fails[state]
  state=nexts[state].get(c,0)
  if outs[state]:found.update(outs[state])
 for tag in found:hits[tag].append(p['title'])
records=[]
for r in A:
 e={'key':r['key'],'itemNameMatches':[{'id':i,'name':names.get(i),'pages':hits.get('item:'+str(i),[])} for i in idsbykey[r['key']] if names.get(i)]}
 if r['key'] in aliasbykey:e['numericNpcIdentity']=aliasbykey[r['key']];e['numericNpcNamePages']=hits.get('npc:'+str(e['numericNpcIdentity']['npcId']),[])
 records.append(e)
(R/'changes/p99-source-review/item-evidence-navigation.json').write_text(json.dumps({'scope':'Lexical navigation only, not item identity/quest scope/parity proof. Includes source comment item IDs and positional QuestReward outputs; dynamic item expressions are not complete. All8911 page bodies/titles searched; an absent match is NOT absence evidence.','cachePagesSearched':len(P),'patternsSearched':len(patterns),'records':records},indent=2)+'\n')
print(len(P),'pages;',len(patterns),'item/alias patterns;',len(records),'sources')
