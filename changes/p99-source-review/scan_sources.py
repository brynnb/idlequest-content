import json,pathlib,re,hashlib,collections
ROOT=pathlib.Path(__file__).resolve().parents[2]
def read(p):return json.loads((ROOT/p).read_text())
def norm(s):return re.sub(r'[^a-z0-9]','',s.lower())
def sha(s):return hashlib.sha256(s.encode()).hexdigest()
A=read('changes/p99-source-review/assignment.json')['records']; P=read('reference/p99-evidence-index.json'); I={x['key']:x for x in read('reference/effective-quests-index.json')}
B=[]
for p in P:
 raw=(ROOT/p['cachePath']).read_bytes(); t=raw.decode('utf-8'); assert hashlib.sha256(raw).hexdigest()==p['sha256'],p['cachePath']; B.append((p,t,norm(t)))
items={}
for f in (ROOT/'data/items').glob('*.ndjson'):
 for line in f.read_text().splitlines():
  x=json.loads(line);items[x['id']]=x['Name']
pol=read('reference/server/internal/quest/content_exclusions.json'); npc=read('reference/server/internal/contentscope/npc_exclusions.json')
rows=[]
for r in A:
 raw=(ROOT/r['baselineFile']).read_bytes(); s=raw.decode('utf-8'); normalized=s.replace('\r\n','\n').replace('\r','\n');n=r['key'].split('/')[1]; hits=[]
 if not n.isdigit():
  for p,t,nt in B:
   if norm(n) in nt or norm(n)==norm(p['title']):
    hits.append({**p,'match':'normalized full NPC name in title/body; identity still requires verification'})
 iid=sorted(set(map(int,re.findall(r'(?:item\d*\s*=\s*|SummonItem\(\s*|HasItem\(\s*)(\d+)',s))))
 ledger=[k for k,v in pol['p99_audit'].items() if r['key'] in v.get('local_quest_keys',[])]
 row={**r,'sourceSha256':hashlib.sha256(raw).hexdigest(),'sourceHashKind':'exact_file_bytes','normalizedLfSourceSha256':sha(normalized),'sourceBytes':len(raw),'sourceLines':len(s.splitlines()),'sourceIdentity':I[r['key']],'actorNameEvidence':hits,'itemIdentities':[{'id':i,'name':items.get(i)} for i in iid],'historicalLedgerPages':ledger}
 rows.append(row)
out={'scope':'Structural navigation for individual semantic review; not parity evidence','cachePagesSearched':len(P),'verifiedCacheHashes':len(P),'records':rows}
(ROOT/'changes/p99-source-review/source-navigation.json').write_text(json.dumps(out,indent=2)+'\n')
for i,r in enumerate(rows):print(i,r['key'],r['sourceLines'],'pages:',','.join(x['title'] for x in r['actorNameEvidence'])[:400])
