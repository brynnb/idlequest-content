"""Bounded source-admission closure. Never edits immutable baseline/policy files."""
import collections,copy,hashlib,json,pathlib,re,datetime
R=pathlib.Path(__file__).resolve().parents[2]; D=R/'changes/p99-final-admission'; PID='p99-final-admission'
def sha(b):return hashlib.sha256(b if isinstance(b,bytes) else b.encode()).hexdigest()
def rd(p):return json.loads((R/p).read_text())
def write(p,x): (R/p).write_text(json.dumps(x,indent=2)+'\n')
A=rd('changes/p99-final-admission/assignment.json'); old=rd('changes/p99-source-review/review-records.json'); assert sha((R/'changes/p99-source-review/review-records.json').read_bytes())==A['sourceReviewSha256']
assert len(A['records'])==121
assert {a['key'] for a in A['records']}=={a['key'] for a in old['records'] if a['disposition']=='later_era_family_or_source_context_preserved_pending_admission_review'}
idx={a['key']:a for a in rd('reference/effective-quests-index.json')}; rows={}
for p in (R/'data/quests').glob('*.ndjson'):
 for l in p.read_text().splitlines():
  a=json.loads(l);rows[a['zone']+'/'+a['name']]=a
owners=collections.defaultdict(list)
for p in sorted((R/'changes').glob('*.json')):
 x=json.loads(p.read_text())
 if x.get('format')!=1 or x.get('id') in [PID,'p99-combined-audit']:continue
 for a in x.get('rows',[]):
  q=a.get('after') or a.get('before')
  if a['table']=='quests':owners[q['zone']+'/'+q['name']].append((str(p.relative_to(R)),a,x))
P={a['title']:a for a in rd('reference/p99-evidence-index.json')};E={}
def ev(i,url,summary,kind='public web search-index text',published=None):
 E[i]={'id':i,'url':url,'summary':summary,'retrievedAt':'2026-10-22','retrievalKind':kind,'revision':None,'freshRawWikiFetched':False}
 if published:E[i]['publishedAt']=published
 return i
def cache(i,t,summary):
 p=P[t];assert sha((R/p['cachePath']).read_bytes())==p['sha256'];ev(i,p['url'],summary,'hash-verified existing P99 raw cache');E[i].update({k:p[k] for k in ['fetchedAt','cachePath','sha256']})
ev('p99-nonclassic','https://wiki.project1999.com/Non-Classic_Compendium','P99 excludes the post-Luclin assembly-kit newcomer armor family, naming Tranquilsong and Moss Toe; also explicitly excludes Jaggedpine Forest. Actor admission uses exact source/chain links, not names or missing pages.')
ev('beastlord-luclin','https://www.everquest.com/news/eq-shadows-of-luclin-progression-primer','Official expansion history says Luclin introduced Beastlords and Vah Shir. Exported class-specific rewards and exact source/caller links identify these sources, not their NPC names.','official publisher article indexed text','2018-11-20')
ev('berserker-god','https://sony.mediaroom.com/2003-12-17-Sony-Online-Entertainment-Unlocks-the-Gates-of-Discord-for-EverQuest','SOE announcement explicitly introduces the Berserker class in Gates of Discord.','official publisher announcement indexed text','2003-12-17')
ev('short-hybrids','https://www.project1999.com/forums/showthread.php?t=192943','P99 forum reproduces the March 19, 2002 patch identifying newly available halfling ranger/paladin and gnome shadowknight/paladin classes; later than P99 scope.','P99 community forum indexed patch quotation')
ev('omens-epics','https://sony.mediaroom.com/2004-05-06-Sony-Online-Entertainment-Announces-Omens-of-War-Expansion-for-Everquest','SOE announces new epic weapons and task system for Omens of War. Source-specific epic1.5/2.0 identity is separately traced.','official publisher announcement indexed text','2004-05-06')
ev('task-system','https://www.everquest.com/news/imported-eq-enus-50720','Official article says task system began with Omens of War. Exact task154 and1947 calls identify the affected branches.','official article opened successfully','2007-12-11')
ev('tynnonium','https://wiki.project1999.com/Shackle_of_Tynnonium','P99 explicitly labels Shackle of Tynnonium post-Velious and non-P99. Sources are linked through exact4199 or the same Tynnonium/Whistling Fists progression, not all monk lore.')
ev('tynnonium-chain','https://www.project1999.com/forums/archive/index.php/t-280005.html','Indexed quest walkthrough ties Marthor, Gandan, the tomekeeper progression and the Whistling Fists weapon together. Direct archive open timed out; no fresh full-page claim.')
ev('tynnonium-discussion','https://www.project1999.com/forums/showthread.php?t=263875','P99 discussion identifies Tynnonium as a subquest of the Whistling Fists weapon and distinguishes its 2002 timing from the P99 cutoff.')
ev('pop-knowledge','https://www.everquest.com/news/imported-eq-enus-50703','Official article explicitly dates Plane of Knowledge to Planes of Power; Jeren source identifies its Magic Pool/Reflecting Pools of Tanaan hand-in.','official article indexed text','2007-11-30')
ev('druid-epic','https://www.tapatalk.com/groups/eqstromm/druid-epic-1-5-checklist-t1740.html','Druid1.5 checklist records Carved Prexus Totem to Blumblum for Small Trigger Fish, matching62821 to62820.')
ev('mage-epic','https://www.eqmagetower.com/forums/viewtopic.php?sid=efe08f37f1aa7e4d174c6c843643a8d8&t=313','Magician1.5 checklist records Lost Tomekeeper phrase Violet Roses and Tome of Primal Fires, plus High Priest Margle four Ice Burrower Meats spawning Tiknonmanin.')
ev('rogue-epic','https://thesafehouse.org/forums/forum/everquest-wing/quests-of-norrath/15022-fatestealer-epic-1-5-complete-walkthrough','Rogue community walkthrough identifies Lythe Songbird and Notice to Cease and Desist as main Epic1.5 content, not Epic1.0 or the prequest.')
ev('rogue-pre','https://www.eqprogression.com/rogue-1-5-epic-pre-quest-guide/','Actor-specific guide ties Dealer Maeline, Gold-Leafed Urn and card game to Rogue1.5 eligibility; supplemental to exact roguepre source.')
ev('enc-epic','https://mysticallightfighters.com/forum/viewtopic.php?t=32','Enchanter1.5 checklist identifies Taste of Enticement to Advisor Svartmane for First Piece of the Staff.')
ev('enc-epic2','https://www.tapatalk.com/groups/deadmonarchs/enchanter-2-0-t1292.html','Enchanter2.0 checklist includes Alaurin and Vohnkare and final combination with Epic1.5 in Channeling Crystal. Corrects earlier generic epic1.5 categorization.')
ev('necro-pre','https://mysticallightfighters.com/forum/viewtopic.php?t=374','Necromancer1.5/2.0 checklist identifies Biddliss note/tools and Egonis Contract for Sale steps; exact matching items are pinned locally.')
ev('monk-epic','https://www.thesilentminority.net/characters/questshow.php?ID=2105&QuestID=76','Monk1.5 checklist identifies fallen student, cursed dreams and Muramite Sand from Harbingers Spire.')
ev('monk-pre','https://www.tapatalk.com/groups/monklybusiness43508/need-help-with-epic-1-5-prequest-t1746.html','2005 Monkly Business walkthrough records fallen student and the Cedrick/Mystik seals and Medal of Identity prequest.')
ev('ranger-epic','https://www.tapatalk.com/groups/eqstromm/ranger-epic-1-5-t1813.html','Ranger1.5 walkthrough identifies twitching swordfish in Sirens Grotto. Source requires the later quest weapon62646 and grants Captured Swordfish62643.')
ev('warrior-pre','https://www.eqprogression.com/warrior-1-5-epic-pre-quest/','Actor-specific guide identifies Dardek coffee, weapon parts and forged blade returned to Korbuk in Draniks Scar as Warrior1.5 prequest.')
ev('drix-pike','https://www.mboards.eqtraders.com/eq/forum/tradeskills/quests-requiring-trade-skills/16711-iksar-warrior-pike-quests','May2004 first-person thread identifies exact Drix message/satchel chain, Vygan return and Champion Mancatcher Crown Plans. Drix is warrior-pike support, not Beastlord.')
cache('p99-pikes','Warrior Pike Quests','P99 explicitly marks Champion Mancatcher (#6), Manslayer (#7), and Pride of Legion (#8) nonclassic, completed in Gates of Discord. Drix supports #6 through exact message48008 to crown plans48009.')
cache('p99-pal-note','Guild Summons - Hall of Truth Paladin','Classic note and Faded Purple Tunic are documented but canonical giver is Valeron Dushire, not Edwardian. Preserve inherited alternate branch without asserting canonical actor parity.')
cache('p99-sk-note','Guild Summons - The Dead Shadowknight','Classic note and Black Training Tunic are documented but canonical giver is Nezzka Tolax, not Ulraz. Preserve inherited alternate branch without asserting canonical actor parity.')
cache('p99-medron','Medron Y`Lask','P99 documents merchant identity. Retain the source merchant hail/animation while removing exact later BoneMail shield support.')
cache('p99-min','Innkeep Min','P99 documents innkeeper identity. Retain current ambient greeting, remove source-marked Halloween2018 state and scroll branch.')

# Mixed sources retain legacy non-later content; no invented XP/faction/timer values.
M={}
M['freportn/Edwardian_Holyblade']='''-- P99 scope: keep legacy guild-note fallback; remove post-Luclin Truthbringer training.
-- Canonical P99 guild-note giver is Valeron Dushire. Existing fallback values retained, not newly certified.
-- items: 18737, 13554
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Greetings and well met " .. e.other:GetName() .. ". I am Edwardian Holyblade, noble paladin of Marr. I have devoted my life and my blade to the glory of Mithaniel Marr.");
    end
end
function event_trade(e)
    local item_lib = require("items");
    if item_lib.check_turn_in(e.trade, {item1 = 18737}) then
        e.self:Say("Thanks."); -- Real text still needed
        e.other:Ding();
        e.other:SummonItem(13554); -- Faded Purple Tunic
        e.other:AddEXP(100);
    end
    item_lib.return_items(e.self, e.other, e.trade);
end
'''
M['neriakc/Ulraz_S-Lon']='''-- P99 scope: keep legacy guild-note fallback and non-reward lore; remove later BoneMail training.
-- Canonical P99 guild-note giver is Nezzka Tolax. Existing fallback values retained, not newly certified.
-- items: 18757, 13586
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("So you are the next pathetic maggot I have the displeasure of training to be a useful Shadowknight of the Lodge of the Dead.")
    elseif e.message:findi("ultricle") then
        e.self:Say("In the Nektulos Forest near the pass to the Lavastorm Mountains is a gray region barren of life whose boundaries are marked by carved stones displaying runes the color of freshly spilt blood. The area the runed stones mark is called the Ultricle. It is where the weak. dead. and dying Teir'Dal that have not earned a noble burial are left to rot and one day if they are lucky join the ranks of the Undead.")
    end
end
function event_trade(e)
    local item_lib = require("items")
    if item_lib.check_turn_in(e.trade, {item1 = 18757}) then
        e.self:Say("Thanks.")
        e.other:SummonItem(13586)
        e.other:AddEXP(100)
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
'''
RET='''function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
'''
M['kithicor/Innkeep_Min']='''-- P99 scope: retain ambient innkeeper hail; remove Halloween2018 state and scroll exchange.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Greetings. " .. e.other:GetName() .. "!  Sure is strange seeing so many visitors lately out here in Kithicor. Good for business I guess!");
    end
end
'''+RET
M['rivervale/Artisan_Bill_Whistletop']='''-- P99 scope: remove source-explicit DoN cultural patterns and tasks500178-500181.
-- Preserve the existing ordinary non-halfling greeting exactly, including its message-independent trigger.
function event_say(e)
    if e.other:GetRaceName() ~= "Halfling" then
        e.self:Say(string.format("Hello %s!  Another fine day here in Rivervale!", e.other:GetCleanName()));
    end
end
'''+RET
M['lavastorm/Symbell_Sunara']='''-- P99 scope: preserve ordinary hail; remove exact later task1947 gnome-meat consumer.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hello, " .. e.other:GetName() .. ".")
    end
end
'''+RET
M['nektulos/Kamidra_Voragone']='''-- P99 scope: remove task154 (Black Eggs for Breakfast) solicitation and snake-egg consumer.
-- Keep only the existing ordinary greeting prefix; do not advertise a removed task.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hello, " .. e.other:GetName() .. ".")
    end
end
'''+RET
M['cabwest/Marthor']='''-- P99 scope: retain ordinary hail; remove later Tynnonium/Whistling Fists brew state and hand-ins.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Emote("hiccups and breathes drunken breath in your face saying, Leave me be, can't you see that I am meditating or something?")
    end
end
'''+RET
medron=rows['neriakc/Medron_Y-Lask']['lua_content'];start=medron.index('function event_say(e)');stop=medron.index('function event_trade(e)')
M['neriakc/Medron_Y-Lask']='-- P99 scope: preserve merchant hail/animation; remove later BoneMail shield exchange.\n'+medron[start:stop]+RET

explicit={
 'fieldofbone/Trooper_Drix':('later_warrior_pike_helper',['p99-pikes','drix-pike'],'Exact48008 goes to upstream Drill Master Vygan for48009 Champion Crown Plans; P99 excludes Champion Mancatcher #6 as Gates of Discord. Earlier Beastlord label corrected.'),
 'felwitheb/Elishia_Leafrunner':('later_jaggedpine_helper',['p99-nonclassic'],'Exact8969/8970 letters are issued/received by jaggedpine/#Jeremy_Leafrunner; the only source service requires the excluded Jaggedpine zone. Earlier newcomer-armor association corrected.'),
 'freportn/Edwardian_Holyblade':('mixed_later_armor_removed',['p99-nonclassic','p99-pal-note'],'Remove Truthbringer kit/molds and9927-9930 weapon hand-in. Preserve18737 to13554, Ding and100XP; no new faction or canonical actor claim. Keep initial greeting sentences without training prompts.'),
 'neriakc/Ulraz_S-Lon':('mixed_later_armor_removed',['p99-nonclassic','p99-sk-note'],'Remove BoneMail request19584 and weapon/shield branches. Preserve18757 to13586 and100XP, initial greeting sentence and Ultricle lore.'),
 'kithicor/Innkeep_Min':('mixed_later_event_removed',['p99-min'],'Remove exact Halloween2018 global progression and21699 to46200 scroll exchange; preserve existing ordinary hail. Source itself explicitly dates removed event2018.'),
 'rivervale/Artisan_Bill_Whistletop':('mixed_later_tasks_removed',['task-system'],'Remove source-explicit DoN cultural armor38447 and tasks500178-500181; preserve existing non-halfling greeting with original trigger. No merchant or NPC data changed.'),
 'lavastorm/Symbell_Sunara':('mixed_later_tasks_removed',['task-system'],'Remove source exact task1947 activity4 meat13418 consumer. Preserve ordinary hail; all offered items now return, no invented task reward.'),
 'nektulos/Kamidra_Voragone':('mixed_later_tasks_removed',['task-system'],'Upstream exact taskselector154 identifies Black Eggs for Breakfast. Remove egg13088 consumption and removed-task help prompts; preserve greeting prefix.'),
 'cabwest/Marthor':('mixed_later_chain_removed',['tynnonium','tynnonium-chain'],'Remove brew8348 state/timer and4199 return/directions, all explicitly advancing Tynnonium and Whistling Fists. Preserve ordinary hail without later solicitation.'),
 'neriakc/Medron_Y-Lask':('mixed_later_armor_removed',['p99-nonclassic','p99-medron'],'Ulraz produces frame19571 and directs two Basilisk Hatchling Skins16170 to Medron. Remove that exact later armor-support exchange; preserve merchant greeting and DoAnim67.'),
 'gfaydark/Mazziana_Ridgerunner':('unresolved_exact_era_evidence_not_found',[],'Only source behavior is generic hail and one-to-four classic Orc Scalps13791 consumed for acknowledgement, without reward. Upstream contains no task ID, later-class restriction, later-zone caller or armor-family link. Third-party PEQ-derived spawn-era data is not independent admission proof. Keep unchanged rather than guessing a reward or disabling from name/absence; exact actor quest-date/caller evidence still needed.'),
}
EP={
 'cobaltscar/Blumblum_Swigwater':['druid-epic'], 'cobaltscar/High_Priest_Margle':['mage-epic'],
 'freportw/Lythe_Songbird':['rogue-epic'],'frozenshadow/#Advisor_Svartmane':['enc-epic'],
 'highkeep/Dealer_Maeline':['rogue-pre'],'lakerathe/#Egonis':['necro-pre'],'lakerathe/a_fallen_student':['monk-epic','monk-pre'],
 'necropolis/#Hsagra-s_Shade':[],'sirens/a_twitching_swordfish':['ranger-epic'],'steamfont/#Biddliss_Sperandu':['necro-pre'],
 'thurgadina/Dardek_Bladewright':['warrior-pre'],'wakening/#Alaurin':['enc-epic2'],'wakening/#Lantaric-Dar':[],
 'westwastes/#Vohnkare':['enc-epic2'],'westwastes/a_Lost_Tomekeeper':['mage-epic']}
SHORT={'akanon/Garret_Zethkog','akanon/Lewis_Reldnok','rivervale/Kaya_Cloudfoot','rivervale/Megosh_Thistlethorn'}
BERS={'grobb/Daboo_Dogak','halas/Shanis_MacDarren','kaladimb/Dravel_Axethrasher','oggok/Baddi_Waca'}
JAG={'qeynos/Lord_Mrallon','qeytoqrg/Rilca_Leafrunner','qrg/Gurrin_Nitestorm','qrg/Jhaya_Wyndrunner','qrg/Lerian_Wyndrunner'}
Pproposal={'format':1,'id':PID,'summary':'Close later-content admission for a bounded 121-source assignment: preserve exact historical Lua bodies under explicit disabled headers for sole later quests; remove exact later branches from mixed sources while preserving legacy notes and ambient behavior. No NPC data or authoritative quest policies changed.','baseManifestSha256':sha((R/'manifest.json').read_bytes()),'evidence':[],'rows':[],'sources':[]}
review=[]; bindings=[]
for a in A['records']:
 k=a['key'];b=rows[k];raw=(R/a['baselineFile']).read_bytes();s=raw.decode();assert sha(raw)==a['baselineSourceSha256'];assert b['lua_content']==s
 os=owners[k]; assert [p for p,_,_ in os]==a['existingOwners'],(k,'ownership changed')
 if k in explicit:cat,eids,reason=explicit[k]
 elif k in SHORT:cat,eids,reason='later_race_class_only',['short-hybrids'],a['sourceSpecificReview']
 elif k in BERS:cat,eids,reason='later_berserker_only',['berserker-god'],a['sourceSpecificReview']
 elif a['sourceCategory']=='later_class':cat,eids,reason='later_beastlord_only',['beastlord-luclin'],a['sourceSpecificReview']
 elif a['sourceCategory']=='later_tynnonium':cat,eids,reason='later_tynnonium_only',['tynnonium','tynnonium-chain','tynnonium-discussion'],a['sourceSpecificReview']
 elif a['sourceCategory']=='later_epic':cat,eids,reason='later_epic_only',['omens-epics']+EP[k],a['sourceSpecificReview']
 elif k in JAG:cat,eids,reason='later_jaggedpine_only',['p99-nonclassic'],a['sourceSpecificReview']
 elif k=='droga/Jeren_Manri':cat,eids,reason='later_planes_of_power_only',['pop-knowledge'],a['sourceSpecificReview']
 else:
  assert a['sourceCategory'] in ['newbie','newbie_support','newbie_mixed_later'],(k,a['sourceCategory'])
  cat,eids,reason='later_newcomer_armor_only',['p99-nonclassic'],a['sourceSpecificReview']
 if k in ['wakening/#Alaurin','westwastes/#Vohnkare']:reason+=' Exact public checklist identifies this as enchanter2.0, not1.5.'
 if k=='freportw/Lythe_Songbird':reason+=' Exact public walkthrough identifies main Rogue1.5, correcting the prior prequest label.'
 if k in ['neriaka/Andara_C-Luzz','neriakb/Andara_C-Luzz']:reason+=' Exact caller Selzar L-Crit sends the rogue to Andara for an AshenBone-family bow, not BoneMail; earlier label corrected.'
 rr={'key':k,'questRowId':b['id'],'assignmentOrdinal':a['ordinal'],'supersedes':'changes/p99-source-review/review-records.json#'+k,'previousDisposition':a['disposition'],'baselineFile':a['baselineFile'],'baselineSourceSha256':sha(raw),'beforeSha256':sha(raw),'sourceCategory':cat,'reason':reason,'publicEvidenceIds':eids,'publicEvidence':[E[i] for i in eids],'currentOwnersBefore':a['existingOwners'],'handlersReviewed':a['handlersReviewed'],'bodyReviewBasis':'Prior full-source review bound by exact byte hash; this admission pass rechecked branch/item/caller identity and existing proposal ownership.','runtimeAdmission':'Not established by source review, enabled flags, headers, or isolated VM tests. No all-quests-playable claim.'}
 if os:
  assert len(os)==1
  p,o,pd=os[0]; assert o['after']['enabled']==0 and o['after']['lua_content'].startswith('-- enabled: false\n')
  refs=[x for x in pd['sources'] if x.get('afterSha256')==sha(o['after']['lua_content'])];assert len(refs)==1
  rr.update(disposition='already_disabled_by_existing_owner',proposal=p,proposalSha256=sha((R/p).read_bytes()),proposedFile=refs[0]['proposedFile'],proposedSourceSha256=refs[0]['afterSha256'],enabled=0)
 elif k=='gfaydark/Mazziana_Ridgerunner':rr.update(disposition='unchanged_precise_admission_ambiguity',enabled=b['enabled'])
 else:
  disable=k not in M
  after=('-- enabled: false\n-- P99 source-only scope exclusion: '+cat+'. Historical callback body preserved byte-for-byte below.\n'+s) if disable else M[k]
  out='changes/'+PID+'/'+k.replace('/','--').replace('#','%23')+'.lua';(R/out).write_bytes(after.encode())
  ar=copy.deepcopy(b);ar['lua_content']=after;ar['enabled']=0 if disable else b['enabled'];ar['has_say_event']=1 if 'function event_say(' in after else 0
  target=idx[k]['preferredSource'];target=target if target.startswith('maintained/') else 'maintained/lua/modified-upstream/'+k+'.lua'
  sr={'target':target,'beforeSha256':sha((R/target).read_bytes()) if (R/target).exists() else None,'proposedFile':out,'afterSha256':sha(after)}
  Pproposal['rows'].append({'table':'quests','before':b,'after':ar});Pproposal['sources'].append(sr)
  rr.update(disposition='disabled_sole_later_source_body_preserved' if disable else 'removed_later_branch_preserved_mixed_source',proposal='changes/'+PID+'.json',proposedFile=out,proposedSourceSha256=sha(after),enabled=ar['enabled'],preservedHistoricalBody=disable)
  if disable:assert after.split('\n',2)[2].encode()==raw
  bindings.append({'key':k,'baselineFile':a['baselineFile'],'baselineSourceSha256':sha(raw),'proposedFile':out,'proposedSourceSha256':sha(after),'target':target,'targetBeforeSha256':sr['beforeSha256'],'bodyPreservedExactBytes':disable})
 rr['localEvidenceFile']='changes/p99-final-admission/local-evidence.json'
 rr['publicSourceRepository']='https://github.com/brynnb/idlequest-content'
 review.append(rr)
Pproposal['evidence']=[{'url':x['url'],'note':x['summary']+' Retrieved 2026-10-22 as '+x['retrievalKind']+'. Revision unavailable. Exact per-source rationale and local source/item/caller hashes are in changes/p99-final-admission/review.json and local-evidence.json.'}for x in E.values()]
write('changes/'+PID+'.json',Pproposal)
write('changes/'+PID+'/public-evidence.json',{'scope':'Public source excerpts summarized rather than copied. No exhaustive/fresh wiki fetch claim. P99 direct pages frequently timed out; existing 8,911-page cache reused with hashes. Previously denied ZAM access was not retried or bypassed.','records':list(E.values())})
write('changes/'+PID+'/review.json',{'scope':'Exactly 121 original pending-admission sources. Supersedes only their pending-admission labels, not the immutable policies or earlier evidence. No additional sources were edited.','assignmentFile':'changes/'+PID+'/assignment.json','assignmentSha256':sha((D/'assignment.json').read_bytes()),'originalCount':len(review),'dispositionCounts':dict(collections.Counter(x['disposition']for x in review)),'records':review,'additionalRecords':[],'limitations':['Exact P99 numeric XP, factions, coin, random distributions and timing were not fabricated.','Disabled-source load/preservation tests deliberately load historical code: they do not prove runtime exclusion or activation.','Mixed-source tests are isolated normalized Lua logic with pinned helper and strict mocked APIs, not game inventory settlement, actual world dispatch or UI.','No NPC rows, spawn tables, merchants or authoritative quest policy files changed.','Mazziana requires exact actor-specific historical/caller evidence; a PEQ-derived era flag or missing wiki page is insufficient.']})
write('changes/'+PID+'/source-bindings.json',bindings)
print(len(review),dict(collections.Counter(x['disposition']for x in review)),len(Pproposal['rows']),'edits')
