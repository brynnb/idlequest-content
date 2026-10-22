import json,pathlib,sys,re
r=pathlib.Path('.')
p=json.load(open('changes/p99-nz-coverage/page-coverage.json'))
items={x['id']:x['Name'] for f in r.glob('data/items/*.ndjson') for l in f.open() if (x:=json.loads(l))}
for title in sys.argv[1:]:
 row=next(x for x in p if x['title']==title)
 print('\n### PAGE',title,'\n'+(r/row['evidence']['cachePath']).read_text())
 for s in row['scripts']:
  if not s.get('file'):
   print('UNRESOLVED SOURCE',s);continue
  if s['key'].startswith(('freeportwest/','freeporteast/','mistythicket/','highpasshold/','commonlands/')):continue
  text=(r/s['file']).read_text();print('\n### SOURCE',s['file'],'\n'+text)
  ids=set(map(int,re.findall(r'\b\d{3,}\b',text)))
  print('ITEMS',[(i,items[i]) for i in sorted(ids) if i in items])
