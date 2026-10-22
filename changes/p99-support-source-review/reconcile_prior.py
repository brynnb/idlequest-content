import json,glob,hashlib,collections
from pathlib import Path
assignment=json.load(open('changes/p99-support-source-review/assignment.json'))['records']; keys={x['key']:x for x in assignment};out=collections.defaultdict(list)
files=glob.glob('changes/*review/manual-facet-review.json')+['changes/p99-af-review/findings.json','changes/p99-am-review/ledger-records.json','changes/p99-source-review/review-records.json']
for f in files:
 j=json.load(open(f)); records=j.get('pages',j.get('records',j)) if isinstance(j,dict) else j
 if isinstance(records,dict):records=[dict(v,title=k) if isinstance(v,dict) and 'title' not in v else v for k,v in records.items()]
 fh=hashlib.sha256(Path(f).read_bytes()).hexdigest()
 for i,r in enumerate(records):
  if not isinstance(r,dict):continue
  if f.endswith('/findings.json') and r.get('review_level')!='manual_selected_facets':continue
  title=r.get('title',r.get('key'));arr=r.get('sources',r.get('scripts',[]))
  if isinstance(arr,dict):arr=[dict(v,key=k) for k,v in arr.items()]
  if r.get('effective_sources'):arr+= [dict(v,key=k) for k,v in r['effective_sources'].items()]
  if r.get('key'):arr += [r]
  for s in arr:
   if not isinstance(s,dict) or s.get('key') not in keys:continue
   k=s['key'];h=s.get('sha256',s.get('currentSourceSha256',s.get('sourceSha256')))
   match=h==keys[k]['currentSourceSha256']; limits=r.get('unresolved',r.get('unverified',r.get('limits',[])))
   out[k].append({'file':f,'fileSha256':fh,'recordIndex':i,'title':title,'recordSourceSha256':h,'currentHashMatch':match,'facets':r.get('verified_facets',r.get('reviewed_facets',r.get('facets',{}))),'limitations':limits,'evidence':r.get('evidence')})
Path('changes/p99-support-source-review/prior-source-reconciliation.json').write_text(json.dumps(dict(out),indent=2)+'\n')
print('keys_with_prior_substantive_source_mapping',len(out),'world',sum(k in out for k in keys if keys[k]['structuralDisposition'].startswith('world')),'named',sum(k in out for k in keys if keys[k]['structuralDisposition'].startswith('name')))
for k,v in out.items():
 if keys[k]['structuralDisposition'].startswith('world'):print(k,[(x['title'],x['currentHashMatch']) for x in v])
