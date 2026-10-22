import json,pathlib,hashlib
root=pathlib.Path('.');h=lambda b:hashlib.sha256(b).hexdigest()
rows=json.load(open('changes/p99-sz-review/manual-facet-review.json'));ledger={r['title']:r for r in rows}
props=[]
for p in root.glob('changes/*.json'):
 if p.name=='p99-combined-audit.json':continue
 try:v=json.load(p.open())
 except:continue
 if isinstance(v,dict) and v.get('sources'):props.append((p,v))
extras={
 'Spider Legs Quest':['skyshrine/Sentry_Kale'],
 'Shadow Knight Epic Quest':['neriaka/Smaka','qcat/Teydar','tox/Knarthenne_Skurl'],
 'Shaman Epic Quest':['erudsxing/Ooglyn','qey2hh1/a_wandering_spirit','emeraldjungle/Spirit_Sentinel_','hole/#High_Scale_Kirn','hole/#High_Scale_Kirn_','citymist/#Neh-Ashiir','citymist/#Neh-Ashiir_','erudsxing/Srafen_the_Soaked','erudsxing/Dillon_the_Drowned','erudsxing/Froham_the_Forgotten','erudsxing/Abe_the_Abandoned','erudsxing/a_greater_spirit']}
for title,keys in extras.items():
 for k in keys:
  p=root/'effective/quests'/(k.replace('#','%23')+'.lua');b=p.read_bytes();maint=[]
  for m in root.glob('maintained/lua/*/'+k+'.lua'):maint.append({'file':str(m),'sha256':h(m.read_bytes()),'equals_effective':m.read_bytes()==b})
  ledger[title]['sources'].append({'key':k,'file':str(p),'sha256':h(b),'maintained':maint,'scope':'Extra exact source fully read for documented chain facets; not a full runtime verification'})
for title,r in ledger.items():
 keys={s['key'] for s in r['sources']}
 if title=='Souvenir Mugs':keys.add('thurgadina/Adia_Coldbeard')
 if title=='Scout Blade':
  for k in ['highkeep/Rodrick_Marslett','highkeep/Jail_Clerk_Maryl']:
   p=root/'effective/quests'/ (k+'.lua');r['sources'].append({'key':k,'file':str(p),'sha256':h(p.read_bytes()),'scope':'Extra NPC sources read for chain dialogue/spawn facets only'})
 r['proposal_sources']=[]
 for p,v in props:
  for row in v.get('rows',[]):
   a=row.get('after') or {};k=a.get('zone','')+'/'+a.get('name','')
   if row.get('table')=='quests' and k in keys:r['proposal_sources'].append({'proposal':str(p),'proposal_sha256':h(p.read_bytes()),'key':k,'lua_sha256':h(a['lua_content'].encode())})
for r in json.load(open('changes/p99-nz-coverage/page-coverage.json')):
 if r['title'].startswith('S') and r['title'] not in ledger:
  ledger[r['title']]={'title':r['title'],'review_status':r['review_status'],'evidence':r['evidence'],'verified_facets':{},'unresolved':['No new deeper review by S worker yet; preserve prior ledger status, do not count as parity.'],'sources':r['scripts']}
json.dump(ledger,open('changes/p99-sz-review/ledger-records.json','w'),indent=2)
json.dump({t:{'evidence':r['evidence'],'sources':r['sources'],'proposals':r.get('proposal_sources',[])} for t,r in ledger.items()},open('changes/p99-sz-review/hash-sidecar.json','w'),indent=2)
print('new facet records',len(rows),'all ledger rows',len(ledger))
