import json,pathlib,re,hashlib,collections,datetime
R=pathlib.Path(__file__).resolve().parents[2]
def rd(p):return json.loads((R/p).read_text())
def write(p,x):(R/p).write_text(json.dumps(x,indent=2)+'\n')
def sha(s):return hashlib.sha256(s.encode()).hexdigest()
public=[
 {'id':'public-nonclassic','url':'https://wiki.project1999.com/Non-Classic_Compendium','retrievedAt':'2026-10-22T05:00:11Z','retrievalKind':'web search-index text','reportedCrawlAge':'7 months','freshRawPageFetched':False,'summary':'The post-Luclin section lists newcomer armor, specifically Tranquilsong and Moss Toe, and Jaggedpine Forest. This is family/zone scope evidence, not a full actor-level exclusion list.','failure':'Earlier direct page open failed400Timeout; no freshness or exhaustive category claim.'},
 {'id':'public-tynnonium','url':'https://wiki.project1999.com/Shackle_of_Tynnonium','retrievedAt':'2026-10-22T05:00:46Z','retrievalKind':'web search-index text','reportedCrawlAge':'6 days','freshRawPageFetched':False,'exactExcerpt':'This is a post-Velious (non-Classic) item.','summary':'Explicit non-P99 warning for Shackle of Tynnonium. Local item4199 identity comes from data/items, not this page. Only sole-purpose sources requiring/outputting that item are disabled.'},
 {'id':'public-vampire-teeth','url':'https://wiki.project1999.com/Vampire_Teeth','retrievedAt':'2026-10-22T05:00:11Z','retrievalKind':'web search-index text','reportedCrawlAge':'7 months','freshRawPageFetched':False,'summary':'Both Maid Issis and Butler Syncall fangs are exchanged with the avenging caitiff for Electrum-Bladed Wakizashi, then he despawns. Corroborates the hashed cached NPC page. No XP amount is supplied.'},
 {'id':'public-special-emerald','url':'https://wiki.project1999.com/A_Special_Fire_Emerald','retrievedAt':'2026-10-22T05:09:00Z','retrievalKind':'web search-index text','reportedCrawlAge':'last month','freshRawPageFetched':False,'reportedRevisionUrl':'https://wiki.project1999.com/index.php?title=A_Special_Fire_Emerald&oldid=134402','summary':'Explicitly identifies Fire Emerald to Drake Mountainstorm in Firiona Vie for A Special Fire Emerald, associated with Bones of Darak Lightforge.'}
]
write('changes/p99-source-review/public-evidence.json',{'scope':'Supplemental public evidence; cached search retrieval is not fresh live wiki/API verification. No unrecorded numbers inferred.','records':public})
A=rd('changes/p99-source-review/source-navigation.json')['records'];I={x['key']:x for x in rd('changes/p99-source-review/item-evidence-navigation.json')['records']};P={x['title']:x for x in rd('reference/p99-evidence-index.json')};notes={}
for l in (R/'changes/p99-source-review/manual-dispositions.txt').read_text().splitlines():
 i,k,n=l.split('|',2);notes[int(i)]=(k,n)
assert len(A)==len(notes)==213
# Review artifacts are references, not automatically upgraded into parity verdicts.
artifacts=[]
for pattern in ['changes/*/ledger-records.json','changes/*/manual-facet-review.json','changes/*/manual-notes.json','changes/*/findings.json','changes/*/additional-actor-evidence.json']:
 for f in R.glob(pattern):
  if 'p99-source-review' in str(f):continue
  try:d=json.loads(f.read_text())
  except:continue
  artifacts.append((str(f.relative_to(R)),d))
def records(doc):
 if isinstance(doc,list):return doc
 if isinstance(doc,dict):
  if isinstance(doc.get('records'),list):return doc['records']
  return [dict(v,_title=k) if isinstance(v,dict) else {'_title':k,'value':v} for k,v in doc.items()]
 return []
chains={16:'Bard Epic Quest',26:'Shaman Epic Quest',35:'Shaman Epic Quest',36:'Shaman Epic Quest',93:'Armor of the Priest Quests',113:'Cleric Epic Quest',115:'Bard Epic Quest',116:'Armor of the Priest Quests',122:'The Spirit of Garzicor',124:'The Spirit of Garzicor',125:'The Spirit of Garzicor',180:'Armor of the Priest Quests',189:'Rogue Epic Quest',195:'The Spirit of Garzicor',196:'Cleric Epic Quest',202:'Coldain Prayer Shawl Quests',203:'Coldain Prayer Shawl Quests',204:'Coldain Ring Quests'}
for i in range(103,109):chains[i]='Rogue Epic Quest'
extra={19:["Shestar's Scaled Coif Quest"],32:['Monk Shackle Quests','An Iksar slave','An iksar slave'],51:['The Bones of Darak Lightforge'],72:['Note for Janam'],75:['Note for Rebby'],83:['More Help for Innoruuk'],139:['The Visiting Priestess'],149:['The Tome Raider']}
changed={}
for p in ['changes/p99-source-scope-disables.json','changes/p99-source-caitiff-depop.json']:
 d=rd(p)
 for row,src in zip(d['rows'],d['sources']):changed[row['before']['zone']+'/'+row['before']['name']]={'proposal':p,'proposedFile':src['proposedFile'],'sourceSha256':src['afterSha256'],'enabled':row['after']['enabled']}
E={};out=[]
for i,r in enumerate(A):
 cat,note=notes[i];key=r['key'];raw=(R/r['baselineFile']).read_bytes();s=raw.decode('utf-8');assert hashlib.sha256(raw).hexdigest()==r['sourceSha256'];assert sha(s.replace('\r\n','\n').replace('\r','\n'))==r['normalizedLfSourceSha256'];ev={x['title'] for x in r['actorNameEvidence']};ev.update(extra.get(i,[]))
 if i in chains:ev.add(chains[i])
 if cat=='disable_skull':ev.add('Shaman Skull Quests')
 if cat=='disable_inactive':ev.add("Guild Summons - Faydark's Champions")
 ev.update(I[key].get('numericNpcNamePages',[]))
 ev={t for t in ev if t in P}
 for t in ev:E[t]=P[t]
 refs=[]
 for path,doc in artifacts:
  for rec in records(doc):
   text=json.dumps(rec)
   exact=key in text
   chain=bool(i in chains and (rec.get('title')==chains[i] or rec.get('_title')==chains[i]))
   if exact or chain:
    refs.append({'artifact':path,'record':rec.get('title',rec.get('_title','unnamed')),'relation':'exact source-key reference' if exact else 'chain-owner record only; not exact actor coverage','recordStatus':rec.get('review_status'),'doesNotProveFullChain':True})
 pub=[]
 if cat.startswith('newbie') or i in [165,174,176,177,178]:pub.append('public-nonclassic')
 if 'tynnonium' in cat:pub.append('public-tynnonium')
 if i==120:pub.append('public-vampire-teeth')
 if i==51:pub.append('public-special-emerald')
 action='proposed_source_only_disable' if cat.startswith('disable_') else ('proposed_documented_depop' if i==120 else 'unchanged')
 if cat=='existing_coverage':status='existing_review_artifact_reference' if any('exact source' in x['relation'] for x in refs) else 'existing_chain_owner_actor_verification_not_inferred'
 elif cat.startswith('disable_') or i==120:status='bounded_evidence_backed_proposal'
 elif cat in ['p99_substep','p99_support']:status='unchanged_documented_substep_or_service_not_full_chain'
 elif cat.startswith('newbie') or cat in ['later_class','later_class_mixed','later_epic','later_explicit','later_tynnonium']:status='later_era_family_or_source_context_preserved_pending_admission_review'
 else:status='unresolved_no_exact_p99_implementation_proof'
 out.append({'ordinal':i,'key':key,'questRowId':r['id'],'baselineFile':r['baselineFile'],'baselineSourceSha256':r['sourceSha256'],'baselineHashKind':'exact_file_bytes','baselineNormalizedLfSourceSha256':r['normalizedLfSourceSha256'],'baselineSourceBytes':r['sourceBytes'],'sourceLines':r['sourceLines'],'handlersReviewed':r['handlers'],'disposition':status,'sourceCategory':cat,'sourceSpecificReview':note,'action':action,'proposedState':changed.get(key),'cachedEvidenceTitles':sorted(ev),'publicEvidenceIds':pub,'existingReviewReferences':refs,'itemEvidenceNavigation':'item-evidence-navigation.json#'+key,'numericNpcIdentity':I[key].get('numericNpcIdentity'),'baselineQuestPolicy':r.get('questPolicy'),'baselineNpcPolicyCandidates':r.get('npcPolicyCandidates',[]),'runtimeAdmission':'not proven by enabled row, source presence, item existence, name match, or isolated VM execution','parityLimitations':['No full-chain claim from this individual source disposition.','Unknown numerical XP, faction, coin, timing and random probabilities are not silently certified or retuned.','Acquisition, actual spawn identity, engine settlement and player UI remain separate evidence requirements.']})
summary=collections.Counter(x['disposition'] for x in out);categories=collections.Counter(x['sourceCategory'] for x in out)
write('changes/p99-source-review/evidence-catalogue.json',{'cachedPages':E,'publicEvidence':'public-evidence.json'})
write('changes/p99-source-review/review-records.json',{'scope':'213 lexical candidates reviewed as existing Lua sources, not213 missing P99 quests. Full event bodies and all handlers considered; descriptive dialogue is not independently certified word-for-word. Cache corpus8911 plus bounded public search; no fresh exhaustive wiki/category claim.','assignmentSha256':hashlib.sha256((R/'changes/p99-source-review/assignment.json').read_bytes()).hexdigest(),'cachePagesSearched':8911,'cacheHashVerification':'scan_sources.py and scan_item_evidence.py assert every cached body hash','manualDispositionCount':213,'dispositionCounts':dict(summary),'sourceCategoryCounts':dict(categories),'records':out})
# Scope and immutability assertions for owned changes.
checks=[]
for fn in ['changes/p99-source-scope-disables.json','changes/p99-source-caitiff-depop.json','changes/p99-sz-quarg-alias.json']:
 d=rd(fn)
 for row,src in zip(d['rows'],d['sources']):
  b,a=row['before'],row['after'];key=b['zone']+'/'+b['name'];assert row['table']=='quests';assert (R/src['proposedFile']).read_bytes()==a['lua_content'].encode('utf-8');assert sha(a['lua_content'])==src['afterSha256'];assert (R/('effective/quests/'+key+'.lua')).read_bytes()==b['lua_content'].encode('utf-8')
  if fn.endswith('scope-disables.json'):
   assert a['enabled']==0 and a['lua_content'].startswith('-- enabled: false\n');assert a['lua_content'].split('\n',2)[2]==b['lua_content'];assert {k:v for k,v in a.items() if k not in ['enabled','lua_content']}=={k:v for k,v in b.items() if k not in ['enabled','lua_content']}
  checks.append({'key':key,'proposal':fn,'proposedFile':src['proposedFile'],'sourceSha256':src['afterSha256'],'enabled':a['enabled'],'baselineUnchanged':True,'disabledHeaderMatchesRow':a['enabled']!=0 or a['lua_content'].startswith('-- enabled: false\n'),'historicalBodyPreserved':a['lua_content'].endswith(b['lua_content']) if a['enabled']==0 else None})
write('changes/p99-source-review/scope-receipt.json',{'kind':'static scope/header/hash assertions, not live admission or world behavior','completedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'assignmentSources':213,'allAssignmentBaselineHashesMatch':True,'baselineHashKind':'exact_file_bytes','normalizedLfHashesAreSeparate':True,'ownedAffectedSourceCount':len(checks),'disabledSources':sum(x['enabled']==0 for x in checks),'npcRowsModified':0,'existingPoliciesModified':False,'fullChainClaim':False,'checks':checks})
print('Dispositions',dict(summary));print('Categories',dict(categories));print('Static receipt',len(checks),'sources;',sum(x['enabled']==0 for x in checks),'disabled')
