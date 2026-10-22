import json,pathlib,hashlib,re,collections
ROOT=pathlib.Path(__file__).resolve().parents[2];BASE=ROOT/'changes/p99-conversion-trades'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return (ROOT/p).read_text()
def write(p,d):(ROOT/p).write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
def cache(pattern):
 p=next((ROOT/'reference/p99-wiki').glob(pattern));meta=p.with_suffix('.json');m=json.loads(meta.read_text()) if meta.exists() else {}
 return {'path':str(p.relative_to(ROOT)),'sha256':sha(p),'url':m.get('url') or 'https://wiki.project1999.com/'+pattern.split('/')[-1].split('-')[0],'retrievedAt':m.get('fetchedAt'),'revision':m.get('revision')}
def web(url,note):return {'url':url,'verifiedAt':'2026-10-22','note':note}
paths=json.loads((BASE/'paths.json').read_text());prop=json.loads(read('changes/p99-conversion-trades.json'))
keys='iceclad/Joshel_the_Large;kael/a_bag_of_supplies;necropolis/#an_Odd_Looking_Spider;neriaka/Hukulk;neriaka/Ranjor;nro/#Verrell_Cogswin;skyshrine/Grudash_the_Baker;skyshrine/Mercutius_Del_Torre;skyshrine/Ruru_the_Cook;skyshrine/Torm_Wenrar;steamfont/#Smith_Numden;thurgadina/Fergus_Sawdust;thurgadina/Guard_Dagur;thurgadina/Meg_Tucter;thurgadina/Petcas_Coldbeard;thurgadinb/Loremaster_Solstrin'.split(';')
old={r['key']:r for r in json.loads(read('changes/p99-audit/resolution-report.json'))['originalEmpty']}
bounds={r['key']:r for r in json.loads(read('changes/p99-audit/unconverted-boundaries.json'))['explicitOpenBoundaryRows']}
evidence={}
for k,pattern in [('iceclad/Joshel_the_Large','npc-pages/joshel-the-large-*.wiki'),('kael/a_bag_of_supplies','raw-pages/crest-of-the-fauns-quest-*.wiki'),('neriaka/Hukulk','npc-pages/hukulk-*.wiki'),('neriaka/Ranjor','npc-pages/ranjor-*.wiki'),('skyshrine/Grudash_the_Baker','npc-pages/grudash-the-baker-*.wiki'),('skyshrine/Ruru_the_Cook','npc-pages/ruru-the-cook-*.wiki'),('thurgadina/Guard_Dagur','npc-pages/guard-dagur-*.wiki'),('thurgadina/Meg_Tucter','npc-pages/meg-tucter-*.wiki'),('thurgadina/Petcas_Coldbeard','npc-pages/petcas-coldbeard-*.wiki'),('thurgadinb/Loremaster_Solstrin','npc-pages/loremaster-solstrin-*.wiki')]:evidence[k]=[cache(pattern)]
evidence['necropolis/#an_Odd_Looking_Spider']=[web('https://everquest.allakhazam.com/db/quest.html?quest=2634','Reactivate the Portals explicitly tagged Lost Dungeons of Norrath; entered August 29, 2003. Exact odd-looking-spider note hand-in starts Stiggles clockwork/gnome chain. This is positive later-era identification, not an inference from missing wiki coverage or item numbers.')]
evidence['nro/#Verrell_Cogswin']=[web('https://mboards.eqtraders.com/eq/forum/tradeskills/general-trade-skill-discussion/12170-patch-message-nov-5-2003','Contemporaneous November 5, 2003 patch-note reproduction explicitly announces Verrell red-to-green dragon scale conversion.'),web('https://eqarchives.com/patch/view/2003-11-05-1','Independent archive of the November 5, 2003 patch text corroborates the exact named scale-conversion addition.')]
evidence['skyshrine/Torm_Wenrar']=[web('https://www.project1999.com/forums/showthread.php?t=232503','March 22, 2016 P99 player bug report identifies missing Torm and only 2002+ quest citations; replies describe post-revamp and not-era-appropriate content. These are community accounts, not a quoted staff ruling.')]
evidence['skyshrine/Mercutius_Del_Torre']=[web('https://www.project1999.com/forums/showthread.php?t=317127','January 2017 posts 4/6/10 discuss Mercutius Draconic instruments and distinguish post-Luclin Draconic/Ancients from late-Velious Garath and Essence Lens. Community historical provenance, not a staff ruling.')]
evidence['steamfont/#Smith_Numden']=[web('https://everquest.allakhazam.com/db/quest.html?mid=110702696178364&quest=3031','Parent reviewer verified Welnik\'s Picks and Ore is explicitly tagged Planes of Power and entered 2005, including exact Numden four-pick exchange. This worker re-open returned cache miss; parent verification retained as provenance rather than falsely reporting independent fetch success.')]
evidence['thurgadina/Fergus_Sawdust']=[web('https://www.project1999.com/forums/showthread.php?t=301249','June 25, 2018 first-hand P99 bug report says Fergus initial hail is working and reproduces the same carpentry greeting. Additional claimed follow-ups are not introduced by this bounded source conversion.')]
pie=cache('raw-pages/boysenberry-pie-quest-*.wiki');shawl=cache('raw-pages/coldain-prayer-shawl-quests-*.wiki');mugs=cache('raw-pages/souvenir-mugs-*.wiki')
for k in ['skyshrine/Grudash_the_Baker','skyshrine/Ruru_the_Cook']:evidence[k].append(pie)
for k in ['thurgadina/Meg_Tucter','thurgadinb/Loremaster_Solstrin']:evidence[k].append(shawl)
evidence['thurgadina/Petcas_Coldbeard'] += [mugs,web('https://www.eqprogression.com/warrior-1-5-epic-pre-quest/','Warrior epic 1.5 prequest step 10 identifies Petcas Special Beans used for Coldain Coffee. Epic 1.5 is later than Classic/Kunark/Velious; this supports excluding the brew offer, not importing its modern payment denomination.')]
for k in ['neriaka/Hukulk','neriaka/Ranjor']:evidence[k].append(web('https://wiki.project1999.com/Talk%3AFroglok_Skin_Mask_Quest','Wiki discussion describes troll quest relocation to Neriak with Guktan invasion, but gives an imprecise date and does not establish these exact generic tome-service script versions. Retain uncertainty for exact Neriak identity; do not copy over the separate Grobb quests.'))
reasons={
'iceclad/Joshel_the_Large':('converted_partial','Documented P99 hail and safe refunds converted. Original Icebreaker bandana 60333 acquisition omitted because P99 authority for that reward branch remains unverified; no guessed substitute and no progression claim.'),
'kael/a_bag_of_supplies':('true_runtime_block','Crest of the Fauns requires an explosion and ground Pile of Rubble. Original Perl instead summons rubble directly, casts damaging selfcast1644, and depops. Current executor rejects legacy selfcast and restricts delivered targeted quest spells to beneficial effects. A no-damage/direct-inventory rewrite is not faithful, so no Lua proposal is added.'),
'necropolis/#an_Odd_Looking_Spider':('positively_later','Exact Note to Stiggle 67053 and transformed Stiggles chain identified as Reactivate the Portals, Lost Dungeons of Norrath. No conversion or spawned NPC changes.'),
'neriaka/Hukulk':('uncertain_era_identity','Neriak generic guildmaster/tome-service body is not the documented Grobb Hukulk quest. Exact Neriak service era remains uncertain; do not introduce this relocation or generic tome handler into P99 on name similarity.'),
'neriaka/Ranjor':('uncertain_era_identity','Neriak generic guildmaster/tome-service body is not the documented Grobb Ranjor quest. Exact Neriak service era remains uncertain; preserve Grobb implementation and do not invent Neriak progression.'),
'nro/#Verrell_Cogswin':('positively_later','Named red-to-green-scale quest added November 5, 2003. No alternative Warrior epic scale acquisition route activated.'),
'skyshrine/Grudash_the_Baker':('converted_partial','Only non-pie closing response to signal2 and its Ruru3 signal, plus refund-only trade. Hail, pie offer, and pie replies removed per explicit cached removal warning. This dormant response is not a complete ambient chain or a progression quest.'),
'skyshrine/Mercutius_Del_Torre':('positively_later','Draconic instruments belong to post-Luclin Draconic Loyalist content according to explicit P99 historical discussion. Community provenance is stated; no reward/faction/XP activation.'),
'skyshrine/Ruru_the_Cook':('converted_partial','Standalone non-pie cooking hail, non-pie reactions3/4/5 and refunds. Omit hail signal initiating Grudash pie taunt and arguments1/2 linked to removed pie exchange. No pie acquisition or quest reward is introduced.'),
'skyshrine/Torm_Wenrar':('positively_later','P99 historical discussion identifies post-revamp non-era-appropriate bounty quest, with only 2002+ citations. Preserve reference Perl; do not create bounty rewards or actors.'),
'steamfont/#Smith_Numden':('positively_later','Exact four-pick exchange belongs to Welnik\'s Picks and Ore, Planes of Power. No conversion.'),
'thurgadina/Fergus_Sawdust':('converted_full','Complete original hail/refund-only source converted. Positive P99 observation resolves old missing-page identity concern. No progression exists in this source.'),
'thurgadina/Guard_Dagur':('converted_full','Complete hail/refund source converted with correct distinct Guard Baldvin115132 speaker and safe present/absent lookup. Foreign speech is supported, not a true bridge blocker.'),
'thurgadina/Meg_Tucter':('converted_partial','Geonid lore and refunds converted. Etching Tools8893 eighth-Shawl branch is excluded under documented seven-Shawl P99 cutoff.'),
'thurgadina/Petcas_Coldbeard':('converted_partial','Preserve bounded Icy Mug greeting and all six Ronodun signal responses. All trades refund. Remove later Special Beans60290 and duplicate mug30145 route: P99 identifies Adia as mug seller. Ronodun initiation remains a separate source dependency; no guessed spawns.'),
'thurgadinb/Loremaster_Solstrin':('converted_partial','Documented Hall of Ancestors lore converted, including P99 interested phrase. Eighth-Shawl dialogue and orders/shawl hand-ins omitted; all such offers safely returned. No active progression introduced.')}
# Static exact identities with evidence hashes. Import exclusion is preserved and does not prove world availability.
npcs=[]
for p in (ROOT/'data/npc_types').glob('*.ndjson'):
 for line in p.read_text().splitlines():
  r=json.loads(line)
  if r['name'] in {k.split('/',1)[1] for k in keys}|{'Guard_Baldvin','Ronodun','Stiggles_Cogswin'}:
   npcs.append({'npcId':r['id'],'name':r['name'],'exclude':r['exclude'],'path':str(p.relative_to(ROOT)),'fileSha256':sha(p),'rowSha256':hashlib.sha256(json.dumps(r,sort_keys=True,separators=(',',':')).encode()).hexdigest()})
records=[]
for k in keys:
 src='sources/projecteq/'+k+'.pl';status,reason=reasons[k];p=paths.get(k)
 records.append({'key':k,'status':status,'progressionImplemented':False,'sourcePerl':src,'sourcePerlSha256':sha(ROOT/src),'originalQuestId':old[k]['originalQuestId'],'originalEnabled':old[k]['originalEnabled'],'originalPolicy':old[k]['originalPolicy'],'priorDisposition':bounds[k],'priorResolution':old[k]['originalDisposition'], 'reason':reason,'evidence':evidence[k],'proposedFile':p,'proposedSourceSha256':sha(ROOT/p) if p else None,'target':next((s['target'] for s in prop['sources'] if s['proposedFile']==p),None),'staticIdentityExpectations':[r for r in npcs if r['name']==k.split('/',1)[1]],'runtimeCases':[],'verification':'Full Perl read; evidence review; see validation.json for actual CLI and isolated mocked-Lua results. No game settlement or rendered UI verification.'})
for r in records:
 if r['key']=='kael/a_bag_of_supplies':
  p='changes/p99-audit/downstream-compatibility-summary.json';r['runtimeBlock']={'path':p,'sha256':sha(ROOT/p),'unsupported':'legacy selfcast; non-beneficial targeted quest spells','required':'Evidence-backed damaging explosion plus ground-rubble creation and hand-in/depop settlement, not silent direct SummonItem approximation.'}
 if r['key']=='thurgadina/Guard_Dagur':
  r['runtimeSupport']={'path':'reference/server/internal/quest/lua_bridge.go','sha256':sha(ROOT/'reference/server/internal/quest/lua_bridge.go'),'anchors':['NPCProxy.Say records NPCSpeech name and coordinates','IsMobSpawnedByNpcTypeID and GetMobByNpcTypeID share the live resolver'],'foreignActor':[x for x in npcs if x['npcId']==115132]}
 if r['key']=='thurgadina/Petcas_Coldbeard':
  r['dependencies']=[{'key':'thurgadina/Ronodun','source':'sources/projecteq/thurgadina/Ronodun.pl','sha256':sha(ROOT/'sources/projecteq/thurgadina/Ronodun.pl'),'actorId':115019,'role':'External waypoint23 initiates story; separate conversion required for autonomous chain. No NPC spawns or helper edits in this proposal.'},{'key':'thurgadina/Adia_Coldbeard','proposedFile':'changes/p99-conversions-velious/thurgadina/Adia_Coldbeard.lua','sha256':sha(ROOT/'changes/p99-conversions-velious/thurgadina/Adia_Coldbeard.lua'),'role':'P99-authoritative five-gold souvenir route already proposed; left untouched.'}]
# External-source summaries only, not copyrighted full page dumps.
write('changes/p99-conversion-trades/evidence-summary.json',{'reviewedAt':'2026-10-22','sourcesByKey':evidence})
prop['evidence']=[{'url':e['url'],'note':(e.get('note') or f"Cached P99 evidence {e['path']}; SHA256 {e['sha256']}; retrieval {e.get('retrievedAt')}; revision {e.get('revision')}")} for entries in evidence.values() for e in entries]
# de-duplicate exact repeated evidence
prop['evidence']=list({json.dumps(e,sort_keys=True):e for e in prop['evidence']}.values());write('changes/p99-conversion-trades.json',prop)
# Bound isolated behavior cases to current proposed source; compatible central manifest interface.
cases=[]
def case(k,name,assertions,extra=''):
 cases.append({'name':k+': '+name,'coverageKind':'proposed_source','proposedFile':paths[k],'sourceSha256':sha(ROOT/paths[k]),'setupExtra':extra,'assertions':assertions})
for k in paths:
 case(k,'all trades refunded, unrelated extras and repeat','trade({99999,99999},{gold=350,platinum=2,silver=3,copper=4});equal(remaining[99999],2);equal(remaining.gold,350);equal(remaining.platinum,2);equal(remaining.silver,3);equal(remaining.copper,4);equal(calls.returns,1);equal(next(calls.rewards),nil);equal(next(calls.factions),nil);equal(calls.exp,0);equal(#calls.cash,0);equal(#calls.spells,0);equal(calls.depops,0);trade({99999},{gold=5});equal(remaining.gold,5);equal(calls.returns,2);equal(next(calls.rewards),nil)')
 if k!='skyshrine/Grudash_the_Baker' and k!='thurgadina/Guard_Dagur':case(k,'hail and unrelated speech','say("hail");assert(#calls.speech>0);local n=#calls.speech;say("nonsense with no keyword");equal(#calls.speech,n);equal(next(calls.rewards),nil)')
case('iceclad/Joshel_the_Large','bandana branch not activated','say("icebreaker");equal(#calls.speech,0);reward(60333,0);say("hail");assert(string.find(calls.speech[1],"Icebreaker",1,true));reward(60333,0)')
case('thurgadina/Meg_Tucter','eighth Shawl tools omitted','say("I need a set of Etching Tools");equal(#calls.speech,0);reward(8893,0);trade({8893,99999});equal(remaining[8893],1);equal(remaining[99999],1)')
k='thurgadinb/Loremaster_Solstrin'
for phrase in ['I am interested','what heroes','what sacred tomb']:case(k,'classic lore '+phrase,'say('+json.dumps(phrase)+');assert(#calls.speech>0);equal(next(calls.rewards),nil)')
case(k,'later offers and shawls preserved','say("working with gemstones");say("issue kit");equal(#calls.speech,0);trade({8896,8895,1199,99999});equal(remaining[8896],1);equal(remaining[8895],1);equal(remaining[1199],1);equal(remaining[99999],1);reward(18610,0);reward(18611,0);reward(17651,0);reward(8895,0)')
k='thurgadina/Guard_Dagur'
extra='foreign_speech={};baldvin={Say=function(_,text) table.insert(foreign_speech,{name="Guard Baldvin",id=115132,text=text}) end};entity_list={IsMobSpawnedByNpcTypeID=function(_,id) equal(id,115132);return character.baldvinPresent end,GetMobByNpcTypeID=function(_,id) equal(id,115132);character.lookups=(character.lookups or 0)+1;return character.lookupNil and nil or baldvin end};eq.get_entity_list=function() return entity_list end'
case(k,'Baldvin present is distinct speaker','character.baldvinPresent=true;say("hail");equal(#calls.speech,1);assert(string.find(calls.speech[1],"Reviewer",1,true));equal(#foreign_speech,1);equal(foreign_speech[1].id,115132);equal(foreign_speech[1].name,"Guard Baldvin");assert(string.find(foreign_speech[1].text,"pit",1,true));say("hail");equal(#foreign_speech,2);equal(character.lookups,2)',extra)
case(k,'Baldvin absent never looked up','character.baldvinPresent=false;say("hail");equal(#calls.speech,1);equal(#foreign_speech,0);equal(character.lookups,nil);say("unrelated");equal(#calls.speech,1)',extra)
case(k,'missing foreign proxy safely ignored','character.baldvinPresent=true;entity_list.GetMobByNpcTypeID=function() return nil end;say("hail");equal(#calls.speech,1);equal(#foreign_speech,0)',extra)
k='skyshrine/Grudash_the_Baker'
case(k,'non-pie closing signal identity and delay','event_signal({self=npc,signal=2});equal(#calls.speech,1);equal(#calls.signals,1);equal(calls.signals[1][1],114496);equal(calls.signals[1][2],3);equal(calls.signals[1][3],1);assert(not string.find(string.lower(calls.speech[1]),"pie",1,true));equal(event_say,nil)')
case(k,'removed pie signals do nothing','for _,n in ipairs({1,3,999}) do event_signal({self=npc,signal=n}) end;equal(#calls.speech,0);equal(#calls.signals,0);equal(next(calls.rewards),nil)')
k='skyshrine/Ruru_the_Cook'
case(k,'hail does not trigger removed pie taunt','say("hail");equal(#calls.signals,0);equal(next(calls.rewards),nil)')
for sig in [3,4,5]:case(k,'non-pie reaction '+str(sig),f'event_signal({{self=npc,signal={sig}}});equal(#calls.speech,1);equal(#calls.signals,0);assert(not string.find(string.lower(calls.speech[1]),"pie",1,true))')
case(k,'pie argument and unknown signals omitted','for _,n in ipairs({1,2,999}) do event_signal({self=npc,signal=n}) end;equal(#calls.speech,0);equal(#calls.signals,0)')
k='thurgadina/Petcas_Coldbeard'
case(k,'later coffee and duplicate mug absent','say("souvenirs");say("special brew");equal(#calls.speech,0);trade({60290,30145,99999},{gold=350});equal(remaining.gold,350);equal(remaining[60290],1);equal(remaining[30145],1);reward(60290,0);reward(30145,0)')
for sig in range(1,7):
 assertion=f'event_signal({{self=npc,signal={sig}}});equal(#calls.speech,{0 if sig==3 else 1});equal(#calls.signals,{int(sig<6)});'
 if sig<6:assertion+=f'equal(calls.signals[1][1],115019);equal(calls.signals[1][2],{sig});equal(calls.signals[1][3],0);'
 case(k,'Ronodun response '+str(sig),assertion+'equal(next(calls.rewards),nil)')
case(k,'unknown signal no-op','event_signal({self=npc,signal=999});equal(#calls.speech,0);equal(#calls.signals,0)')
write('changes/p99-conversion-trades/runtime-assertions.json',cases)
for r in records:r['runtimeCases']=[c['name'] for c in cases if c['proposedFile']==r['proposedFile']]
review={'schemaVersion':1,'reviewedAt':'2026-10-22','scope':'Sixteen assigned original Perl-only trade-handler boundary records; eight bounded flavor/refund conversions, zero progression quests newly completed.','counts':dict(collections.Counter(r['status'] for r in records)),'sourceBoundCases':len(cases),'proposal':'changes/p99-conversion-trades.json','proposalSha256':sha(ROOT/'changes/p99-conversion-trades.json'),'baselineManifestSha256':sha(ROOT/'manifest.json'),'inputReviewBindings':[{ 'path':p,'sha256':sha(ROOT/p)} for p in ['changes/p99-audit/resolution-report.json','changes/p99-audit/unconverted-boundaries.json']],'records':records,'limits':['No immutable baseline, NPC row, spawn row, other proposal or central tool edited.','All source enabled flags and existing policy remain unchanged. NPC exclude=1 is recorded, not changed; scripts do not imply actor activation.','Mocked VM behavior is not game runtime settlement, signal delivery, world lifecycle, inventory rollback, or rendered UI testing.','The eight converted trade handlers only refund; no item, cash, XP or faction reward is activated.']}
review['signalContractEvidence']={'url':'https://github.com/EQEmu/EQEmu/blob/4aceae18b94ffaafc08e2b17bc41cd72c77f795d/zone/questmgr.cpp#L1729-L1741','commit':'4aceae18b94ffaafc08e2b17bc41cd72c77f795d','gitBlob':'92de69567b33381d7442e3c91d19f1b0607a43eb','verifiedAt':'2026-10-22','provenance':'Parent reviewer verified exact pinned official source through connected GitHub read; native ls-remote resolved the revision.','contract':'signalwith(npc_id, signal_id, wait_ms) takes milliseconds; signal(npc_id, wait_ms) delegates signalwith(npc_id,0,wait_ms). Lua eq.signal third argument is milliseconds; preserve the numeric wait.','p99ValueLimit':'Grudash 1ms is an identified upstream fallback, not independently established P99 timing. No numeric correction invented.'}
for r in records:
 if r['key']=='skyshrine/Grudash_the_Baker':r['signalDelayFallback']={'milliseconds':1,'authority':'original Perl source; official EQEmu units','p99TimingVerified':False,'targetNpcId':114496,'targetNpcName':'Ruru_the_Cook'}
write('changes/p99-conversion-trades/closure-review.json',review)
print(json.dumps({'counts':review['counts'],'cases':len(cases),'proposalSha256':review['proposalSha256']},indent=2))
