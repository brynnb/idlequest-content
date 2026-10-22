import json,pathlib,re,hashlib
P=pathlib.Path('.');OUT=P/'changes/p99-conversion-ambient'
def rows(t):
 for f in sorted((P/'data'/t).glob('*.ndjson')):
  for l in f.open(): yield json.loads(l)
a=json.loads((OUT/'assignment.json').read_text()); names={r['key'].split('/')[1] for r in a['rows']+json.load(open(OUT/'authorized-extensions.json'))['rows']}; wantedids={110053,110066,115101,115102,115104,115206,115105,115207,115107,115208,115109,115110,115209,115112,115113,115211,129003,129000,129028,129045,115176}
npcs=[r for r in rows('npc_types') if r['name'].lstrip('#') in names or str(r['id']) in names or r['id'] in wantedids]; ids={r['id'] for r in npcs}; se=[r for r in rows('spawnentry') if r['npcID'] in ids]; groups={r['spawngroupID'] for r in se}; sp=[r for r in rows('spawn2') if r['spawngroupID'] in groups]; sd=[r for r in rows('spawn2_disabled') if r.get('spawn2_id') in {s['id'] for s in sp}]; gr={(r['zone'],r['pathgrid']) for r in sp if r['pathgrid']}; grids=[r for r in rows('grid') if r['zoneid'] in [115,129,110,118] and (r['id'] in [6,7,8,11] or ( {115:'thurgadina',129:'thurgadinb',110:'iceclad',118:'greatdivide'}[r['zoneid']],r['id']) in gr)]; gi={(r['zoneid'],r['id']) for r in grids}; ge=[r for r in rows('grid_entries') if (r['zoneid'],r['gridid']) in gi]
(OUT/'identity-and-path-evidence.json').write_text(json.dumps({'npcTypes':npcs,'spawnentry':se,'spawn2':sp,'spawn2Disabled':sd,'grid':grids,'gridEntries':ge},indent=2)+'\n')
idx=json.load(open('reference/p99-evidence-index.json')); keys={'Avalanche (NPC)','The Lost Map','The Mighty Snowfang Hero','Coldain Prayer Shawl Quests','Bind Affinity','Julius Oresko','Julius Oresco'}|{n.replace('_',' ') for n in names}
wiki=[r for r in idx if r['title'].lower() in {k.lower() for k in keys}]; (OUT/'wiki-evidence.json').write_text(json.dumps(wiki,indent=2)+'\n')
for n in npcs:
 if n['name'].lstrip('#') not in names and str(n['id']) not in names:continue
 gs={r['spawngroupID'] for r in se if r['npcID']==n['id']};print(n['id'],n['name'],[(r['id'],r['zone'],r['pathgrid']) for r in sp if r['spawngroupID'] in gs])
