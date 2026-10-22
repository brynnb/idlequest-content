import json,pathlib,re,collections
r=pathlib.Path(__file__).resolve().parent.parent;inv=json.load(open(r/'changes/p99-audit/inventory.json'));used=collections.defaultdict(set)
for q in inv['effective']:
 if not q['p99Zone']:continue
 src=(r/q['file']).read_text()
 for n in re.findall(r'\bitem\d*\s*=\s*(\d+)',src):used[int(n)].add(q['key'])
def rows(t):
 for p in (r/'data'/t).glob('*.ndjson'):
  for l in open(p):yield json.loads(l)
recipes={x['id']:x for x in rows('tradeskill_recipe')};out=[]
for e in rows('tradeskill_recipe_entries'):
 if e['item_id'] in used and e.get('successcount',0)>0:
  q=recipes[e['recipe_id']]
  if not q['enabled'] and q['tradeskill']==75:out.append({'id':q['id'],'name':q['name'],'item':e['item_id'],'keys':sorted(used[e['item_id']]),'recipe':q})
(r/'changes/p99-audit/disabled-combine-candidates.json').write_text(json.dumps({'method':'Candidate scan only, not verified P99 mechanics. All in-scope effective Lua literal hand-in IDs intersect disabled quest-container recipe outputs; some scripts can still contain later-era branches.','records':out},indent=2)+'\n')
for x in out:print(x['id'],x['name'],','.join(x['keys']))
