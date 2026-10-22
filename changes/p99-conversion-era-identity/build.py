import json,pathlib,re,hashlib,collections
P=pathlib.Path('.'); O=P/'changes/p99-conversion-era-identity'; O.mkdir(exist_ok=True)
H=lambda b:hashlib.sha256(b).hexdigest()
def bind(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':H(p.read_bytes())}
def write(p,obj):pathlib.Path(p).write_text(json.dumps(obj,indent=2,ensure_ascii=False)+'\n')
A=json.load(open('changes/p99-conversion-closure/assignments.json'))['assignments']['root_era_identity']; K={a['key'] for a in A}; N={k.split('/')[1] for k in K}
# Exact source and record bindings include complete row images, not name-only evidence.
def collect(table,pred):
 out=[]
 for f in sorted((P/'data'/table).glob('*.ndjson')):
  hits=[]
  for ln,line in enumerate(f.open(),1):
   r=json.loads(line)
   if pred(r):hits.append({'table':table,'path':str(f),'line':ln,'row':r,'rowSha256':H(json.dumps(r,sort_keys=True,separators=(',',':')).encode())})
  if hits:
   h=H(f.read_bytes())
   for r in hits:r['fileSha256']=h
   out.extend(hits)
 return out
Q=collect('quests',lambda r:r['zone']+'/'+r['name'] in K); QM={r['row']['zone']+'/'+r['row']['name']:r for r in Q}
extra={48040,48254,48255,48215,127105,110115,123151,123114,123022,117088,48004,48001}
NPC=collect('npc_types',lambda r:r['name'] in N or r['id'] in extra); IDS={r['row']['id'] for r in NPC}
SE=collect('spawnentry',lambda r:r['npcID'] in IDS); G={r['row']['spawngroupID'] for r in SE}; S2=collect('spawn2',lambda r:r['spawngroupID'] in G)
IT=collect('items',lambda r:r['id'] in {8723,8726,8727,8728,8729,8730,52355,52361,67053,87311,11139,14321,13980,14031})
SP=collect('spells_new',lambda r:r['id']==11658)
LT={r['row'].get('loottable_id') for r in NPC if r['row']['id'] in {127105,48209,48210}}
LTE=collect('loottable_entries',lambda r:r['loottable_id'] in LT); LD={r['row']['lootdrop_id'] for r in LTE}; LDE=collect('lootdrop_entries',lambda r:r['lootdrop_id'] in LD)
write(O/'data-evidence.json',{'canonicalRowHash':'SHA256 of UTF-8 JSON sorted keys, compact separators','quests':Q,'npcTypes':NPC,'spawnentry':SE,'spawn2':S2,'items':IT,'spells':SP,'loottableEntries':LTE,'lootdropEntries':LDE})
# Preserve all independent Perl if branches and original prose, interpolating the user fields only.
key='misty/Bidils_the_Quickhand'; src=P/'sources/projecteq'/f'{key}.pl'; s=src.read_text()
branches=re.findall(r'if\(\$text=~/(.*?)/i\)\s*\{(.*?)\n\s*\}',s,re.S)
assert len(branches)==14,len(branches)
def lua_string(t):
 return ' .. '.join('e.other:GetCleanName()' if p=='$name' else 'e.other:GetRaceName()' if p=='$race' else json.dumps(p) for p in re.split(r'(\$name|\$race)',t) if p)
out='-- name: Bidils_the_Quickhand\n-- Full dialogue-only conversion of the preserved Realm of Heroes source.\n-- No coin exchange or GM-event reward is invented; NPC availability is unchanged.\n-- See changes/p99-conversion-era-identity/closure-review.json for evidence and limits.\nfunction event_say(e)\n'
expect=[]
for phrase,body in branches:
 out+='    if e.message:findi('+json.dumps(phrase)+') then\n'
 actions=re.findall(r'quest::(say|emote)\("(.*?)"\);',body,re.S);assert actions
 for kind,text in actions:out+='        e.self:'+('Say' if kind=='say' else 'Emote')+'('+lua_string(text)+')\n'
 out+='    end\n';expect.append({'phrase':phrase,'responses':[t.replace('$name','Reviewer').replace('$race','Halfling') for _,t in actions]})
out+='end\n\n-- Unmatched offers must be returned; the source has no reward hand-in.\nfunction event_trade(e)\n    local item_lib = require("items")\n    item_lib.return_items(e.self, e.other, e.trade)\nend\n'
f=O/'misty/Bidils_the_Quickhand.lua';f.parent.mkdir(exist_ok=True);f.write_text(out)
old=QM[key]['row'];new={**old,'lua_content':out,'has_say_event':1}
proposal={'format':1,'id':'p99-conversion-era-identity','summary':'Convert all fourteen Bidils Realm of Heroes dialogue branches with safe unmatched-item refunds; preserve NPC availability and do not invent GM-event rewards. Other assigned sources receive source-bound era/event/runtime dispositions.','baseManifestSha256':H((P/'manifest.json').read_bytes()),'evidence':[{'url':'https://wiki.project1999.com/The_Realm_of_Heroes_--_Felwithe?action=raw','note':'Cached 2026-07-17T23:37:51.655Z; related Realm of Heroes quest marked Kunark and reward None (GM event). This does not independently establish Bidils placement or exact text.'},{'url':'https://libraryoferudin.com/doc/eq1npc-misty-bidils-the-quickhand','note':'Search index inspected 2026-10-22; mirror of Verant/SOE Misty Thicket dialogue corroborates exact source identity and prose. Direct entity fetch returned cache miss; no live P99 Bidils page claimed.'}],'rows':[{'table':'quests','before':old,'after':new}],'sources':[{'target':'maintained/lua/converted-perl/'+key+'.lua','beforeSha256':None,'proposedFile':str(f),'afterSha256':H(f.read_bytes())}]}
write('changes/p99-conversion-era-identity.json',proposal);write(O/'dialogue-expectations.json',expect)
print('Data rows:',len(Q),len(NPC),len(SE),len(S2),len(IT),len(SP),len(LTE),len(LDE),'branches',len(branches))
