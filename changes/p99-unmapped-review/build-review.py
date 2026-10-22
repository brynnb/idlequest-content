import json,re,hashlib,pathlib,collections,urllib.parse
ROOT=pathlib.Path(__file__).resolve().parents[2]
x=json.loads((ROOT/'changes/p99-audit/inventory.json').read_text())
pages={p['title']:p for p in x['pages']}; ledger={p['title']:p for p in x['pageLedger']}; effective={p['key']:p for p in x['effective']}
def norm(t): return urllib.parse.unquote(t).replace('_',' ').lstrip(':').split('#')[0].strip()
def resolve(t):
 t=norm(t); seen=[]
 while t in pages and t not in seen:
  seen.append(t); s=(ROOT/pages[t]['cachePath']).read_text(); m=re.match(r'#redirect\s*\[\[([^]|]+)',s,re.I)
  if not m: break
  t=norm(m[1])
 return t,seen
rows=[]
guides={"Garfo's Solo Shaman Epic Guide", "Kurrat's Magician Epic Guide",'Magician Quests Checklists','Qeynos Leveling Quests',"Rohane's Rogue Epic Guide"}
for p in x['pages']:
 if p['reviewStatus']!='not-recorded':continue
 raw=(ROOT/p['cachePath']).read_bytes(); s=raw.decode(); assert hashlib.sha256(raw).hexdigest()==p['sha256']
 redirect=re.match(r'#redirect\s*\[\[([^]|]+)',s,re.I)
 if redirect: c='redirect'; reason='Explicit MediaWiki redirect; follow canonical page, do not create duplicate Lua.'
 elif p['title'] in guides:c='player-guide';reason='Secondary walkthrough/checklist for existing quests, not a distinct quest; canonical quest review remains authoritative.'
 elif '{{Itembox' in s:c='item-reference';reason='Itembox/Itempage record with item lore, sources, and/or related quest links; not a distinct quest.'
 elif '{{Spellpagesmart' in s:c='spell-reference';reason='Spell definition and merchant source, not a quest.'
 elif p['title']=='Patch Note Sources':c='historical-reference';reason='Historical patch-source index, not a quest.'
 elif p['title'].startswith('Class Race Quest List/') or p['title'] in ['Class Epic Quest List','Popular Quests by Reward','Shaman Spells (Quest)','Skyshrine Armor Quests']:c='quest-index';reason='Lists other quests without an independent turn-in or quest implementation.'
 else:raise Exception(p['title'])
 links=list(dict.fromkeys(norm(t) for t in re.findall(r'\[\[([^]|]+)',s)))
 links+= [norm(t) for t in re.findall(r'https://wiki.project1999.com/([^\s\]]+)',s)]
 refs=[]
 for t in dict.fromkeys(links):
  resolved,chain=resolve(t)
  if resolved in ledger:
   l=ledger[resolved]; refs.append({'linkedTitle':t,'canonicalTitle':resolved,'redirectChain':chain,'baselineReviewStatus':l.get('review_status'),'baselineMatchStatus':l.get('match_status'),'localQuestKeys':l.get('local_quest_keys',[])})
 fields={m[1]:m[2].strip() for m in re.finditer(r'^\|(notes|relatedquests|dropsfrom|bookcontents)[ \t]*=[ \t]*(.*?)(?=^\|\w+[ \t]*=|^}}|\Z)',s,re.S|re.M)}
 uncertainty=[]
 if c=='player-guide':uncertainty.append('Independent guide claims have not been comprehensively compared to every Lua, recipe, loot and runtime step; canonical quest coverage must not be inferred from this classification.')
 if c=='item-reference':uncertainty.append('Item names can identify multiple IDs; related-quest links are navigation evidence, not exact-ID or Lua-parity proof.')
 if p['title']=='Dirty Goblin Parchment':
  uncertainty.append('Book contains an embedded exchange: Grinning Goblin Brew + Mt. Death Mineral Salts -> Goblin Temper. Unnamed tribe brewer not resolved; no matched Droga/Nurga source/effective handler. Do not infer exact quantities beyond prose or manufacture NPC.')
 if p['title'] in ['Parchment of Flayed Skin',"Korucust's note to Venril"]:uncertainty.append('Page explicitly says no known quest use; absence of known use is not proof no historical use ever existed.')
 if p['title'] in ['A Glowing Rolled-Up Note','A Tattered and Worn Note']:uncertainty.append('Seasonal/GM-event item association; no ordinary Classic-to-Velious quest should be enabled from this item page.')
 if p['title']=='Scribbled Parchment':uncertainty.append('Page links Enchanter Epic Quest, while Rogue Epic Quest also uses an identically named parchment; do not merge IDs by display name.')
 keys=sorted(set(k for r in refs for k in r['localQuestKeys']))
 scripts=[{a:b for a,b in effective[k].items() if a in ['key','file','sha256','enabled','sourceStatus','preferredSource']} for k in keys if k in effective]
 row={'title':p['title'],'classification':c,'classificationReason':reason,'reviewDate':'2026-10-22','reviewLevel':'page-type and canonical-reference review only; not quest parity','evidence':{k:p[k] for k in ['cachePath','sha256','bytes','url','fetchedAt','revision']},'evidenceHashVerified':True,'redirectTarget':norm(redirect[1]) if redirect else None,'canonicalQuestReferences':refs,'linkedEffectiveScripts':scripts,'evidenceFields':fields,'unresolved':uncertainty,'verification':{'sourceClassification':'reviewed','questMechanics':'not_established_by_this_record','runtime':'not_run','ui':'not_run','connectedChain':'not_run'}}
 rows.append(row)
out=ROOT/'changes/p99-unmapped-review';(out/'page-review.json').write_text(json.dumps(rows,indent=2)+'\n')
summary={'pages':len(rows),'classificationCounts':dict(collections.Counter(r['classification'] for r in rows)),'independentQuestPagesIdentified':0,'unresolvedEmbeddedMechanics':['Dirty Goblin Parchment'],'baselineChanged':False,'proposedLuaChanges':0,'limits':'All missing-ledger pages classified, not all gameplay claims verified. Canonical review remains separate.'}
(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary,indent=2))
