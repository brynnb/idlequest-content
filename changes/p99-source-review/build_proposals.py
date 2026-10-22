import json,pathlib,hashlib,copy
R=pathlib.Path(__file__).resolve().parents[2]
def rd(p): return json.loads((R/p).read_text())
def write(p,x): (R/p).parent.mkdir(parents=True,exist_ok=True); (R/p).write_text(json.dumps(x,indent=2)+'\n')
def sha(s):return hashlib.sha256(s.encode()).hexdigest()
idx={x['key']:x for x in rd('reference/effective-quests-index.json')}
rows={}
for p in (R/'data/quests').glob('*.ndjson'):
 for line in p.read_text().splitlines():
  r=json.loads(line);rows[r['zone']+'/'+r['name']]=r
P={p['title']:p for p in rd('reference/p99-evidence-index.json')}
def evidence(title,note):
 p=P[title];return {'url':p['url'],'note':note+' Cache '+p['cachePath']+'; fetched '+p['fetchedAt']+'; SHA256 '+p['sha256']+'; revision unavailable. Not a live wiki freshness claim.'}
def proposal(id,summary,ev):return {'format':1,'id':id,'summary':summary,'baseManifestSha256':hashlib.sha256((R/'manifest.json').read_bytes()).hexdigest(),'evidence':ev,'rows':[],'sources':[]}
def add(p,key,after,enabled=None):
 i=idx[key];b=rows[key];assert b['lua_content']==(R/i['file']).read_bytes().decode('utf-8'); a=copy.deepcopy(b);a['lua_content']=after
 if enabled is not None:a['enabled']=enabled
 f='changes/'+p['id']+'/'+key.replace('/','--')+'.lua';(R/f).parent.mkdir(parents=True,exist_ok=True);(R/f).write_text(after)
 target=i['preferredSource'] if i['preferredSource'].startswith('maintained/') else 'maintained/lua/modified-upstream/'+key+'.lua'
 p['rows'].append({'table':'quests','before':b,'after':a});p['sources'].append({'target':target,'beforeSha256':hashlib.sha256((R/target).read_bytes()).hexdigest() if (R/target).exists() else None,'proposedFile':f,'afterSha256':sha(after)})
 return f
D=proposal('p99-source-scope-disables','Disable seven standalone source-only later/inactive P99 quest scripts using explicit P99 evidence. Retain complete historical Lua bodies and all NPC data. No blanket era inference from enabled flags, missing names or absent items.',[
 evidence('Shaman Skull Quests','P99 explicitly states only steps1–5 exist and later steps were added in Luclin. These five source bodies implement only steps6–8.'),
 evidence("Guild Summons - Faydark's Champions",'Notes explicitly identify Samatansyn Flamecaller as not active, despite era-inaccurate referral dialogue; his source contains only Trueshot newcomer armor/weapon.'),
 evidence('Dionna',"NPC description explicitly identifies Fabian's Strings as Planes of Power and no P99 quest. Source has only Fabian note→placeholder reward; NPC remains present.")])
SK=['dalnir/a_coerced_channeler','charasis/An_Iksar_Apparition','charasis/the_spirit_of_Rile','fieldofbone/Oracle_Qulin','fieldofbone/Oracle_Vauris']
for key in SK+['gfaydark/Samatansyn_Flamecaller','qeynos/Dionna']:
 reason='P99 Shaman Skull Quests explicitly excludes steps6–8 (Luclin); first-five-stage sources are not changed.' if key in SK else ('P99 Faydark\'s Champions notes explicitly identify Samatansyn as inactive; only later newcomer armor is implemented here.' if key.startswith('gfaydark') else 'P99 Dionna description identifies Fabian\'s Strings as Planes of Power; preserve NPC data, disable this sole later quest source.')
 add(D,key,'-- enabled: false\n-- '+reason+' Historical source body retained below.\n'+rows[key]['lua_content'],0)
D['evidence'].append({'url':'https://wiki.project1999.com/Shackle_of_Tynnonium','note':'Public wiki search-index result retrieved2026-10-22T05:00:46Z, reported crawled6days earlier. Exact excerpt: "This is a post-Velious (non-Classic) item." No fresh raw/API fetch claimed; see public-evidence.json. Only three sole-purpose sources which output or require item4199 are disabled; classic Steel and mixed lore actors retained.'})
for key in ['dreadlands/Veltar','charasis/Gandan_Tailfist','sebilis/a_fallen_monk']:
 add(D,key,'-- enabled: false\n-- P99 Shackle of Tynnonium is explicitly post-Velious/non-P99. This sole-purpose later chain source is retained below; classic Steel and mixed lore actors are unchanged.\n'+rows[key]['lua_content'],0)
D['summary']=D['summary'].replace('seven standalone','ten standalone')
write('changes/'+D['id']+'.json',D)
C=proposal('p99-source-caitiff-depop','Preserve Vampire Teeth reward and existing unknown XP; depop the avenging caitiff only after the documented complete fang hand-in.',[evidence('An avenging caitiff','NPC description explicitly says fang turn-in despawns the actor; related quest is Vampire Teeth.'),{'url':'https://wiki.project1999.com/Vampire_Teeth','note':'Public search-index text retrieved2026-10-22 (reported crawled7months earlier) independently documents both fangs→Electrum-Bladed Wakizashi and immediate despawn. This is supplemental indexed evidence, not a fresh raw wiki/API fetch; see changes/p99-source-review/public-evidence.json.'}])
key='mistmoore/an_avenging_caitiff';s=rows[key]['lua_content'];old='\t\te.other:AddEXP(5000)';assert s.count(old)==1
add(C,key,s.replace(old,old+'\n\t\teq.depop_with_timer() -- P99 Vampire Teeth: caitiff leaves after receiving both fangs.'))
write('changes/'+C['id']+'.json',C)
# Parent authorized this existing proposal amendment so it does not conflict with its phrase correction.
p='changes/p99-sz-quarg-alias.json';Q=rd(p);qr=next(r for r in Q['rows'] if r['before']['name']=='Crusader_Quarg');s=qr['after']['lua_content'];old='e.other:QuestReward(e.self,{items = {17035,5143},exp =100000});'
new='e.other:SummonItem(17035); -- Step4 C.O.R.N. chest is documented P99 content.\n\t\te.other:SummonItem(5143); -- Iron Cudgel of the Mystic; bridge does not support QuestReward items arrays.\n\t\te.other:AddEXP(100000);'
if old in s:s=s.replace(old,new)
else:assert new in s
qr['after']['lua_content']=s
for t in Q['sources']:
 if 'Crusader_Quarg' in t['target']:
  (R/t['proposedFile']).write_text(s);t['afterSha256']=sha(s)
Q['summary']='Accept advertised Crusader Quarg phrase, preserving old punctuation alias, and deliver both documented first-five-stage rewards through explicit SummonItem calls supported by the bridge. Retain existing100000XP without asserting its exact P99 magnitude.'
if not any('items array' in e['note'] for e in Q['evidence']):Q['evidence'].append(evidence('Shaman Skull Quests','Steps3–4 document the Mystic cudgel and C.O.R.N. chest for the next preserved stage. Pinned lua_bridge.go QuestReward reads scalar itemid, not items array; no numerical XP change.'))
write(p,Q)
# Keep old tests unchanged except for their source binding.
p='changes/p99-sz-review/behavior-cases.json';B=rd(p)
for b in B:
 if 'Crusader_Quarg' in b.get('proposedFile',''):
  if 'source' in b:b['source']=s
  if 'sourceSha256' in b:b['sourceSha256']=sha(s)
write(p,B)
print('Generated',D['id'],len(D['rows']),'source-only disables;',C['id'],'and amended Quarg proposal/source/test binding.')
