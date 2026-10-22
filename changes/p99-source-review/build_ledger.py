import json,pathlib,hashlib
R=pathlib.Path(__file__).resolve().parents[2]
def rd(p):return json.loads((R/p).read_text())
def sha(p):return hashlib.sha256((R/p).read_bytes()).hexdigest()
E=rd('changes/p99-source-review/evidence-catalogue.json')['cachedPages']
S=rd('changes/p99-source-review/scope-receipt.json')['checks']
prior=rd('changes/p99-sz-review/ledger-records.json')['Shaman Skull Quests']
skull=['dalnir/a_coerced_channeler','charasis/An_Iksar_Apparition','charasis/the_spirit_of_Rile','fieldofbone/Oracle_Qulin','fieldofbone/Oracle_Vauris','fieldofbone/Crusader_Quarg']
def refs(keys):
 return [{'key':s['key'],'proposal':s['proposal'],'proposal_sha256':sha(s['proposal']),'lua_sha256':s['sourceSha256'],'proposedFile':s['proposedFile'],'enabled':s['enabled']} for s in S if s['key'] in keys]
def evidence(title):
 e=E[title];return {'title':title,'url':e['url'],'raw_cache':e['cachePath'],'sha256':e['sha256'],'fetched_at':e['fetchedAt'],'revision':e.get('revision')}
base={'review_status':'partial','reviewed_at':'2026-10-22','match_status':'bounded_source_correction_with_open_chain_limits'}
record={**base,'local_quest_keys':sorted(set(skull+[x['key'] for x in prior['sources']])),'p99_source':evidence('Shaman Skull Quests'),
 'notes':[
 'Source-reconciliation supplement to the earlier S-Z review, not a new full-chain completion claim.',
 'The cached quest page explicitly limits P99 to the first five Skull quests. Five sole-purpose later sources are proposed disabled by row/header only; their full historical bodies and NPC data are retained.',
 'Crusader Quarg preserves the prior advertised-phrase fix. Complete C.O.B.B. 12735 plus Seer cudgel 5142 now explicitly summon Mystic cudgel 5143 and chest 17035 with the existing 100000 XP. The unsupported QuestReward items array silently lost both rewards in the pinned bridge. The chest is for preserved step4 C.O.R.N., not a later excluded step.',
 'The preceding Zand note 18054 to chest 17034 branch, its existing 10000 XP and faction calls are unchanged. Existing friendly-faction adaptation and class/level neutrality are retained.',
 'Hash-bound VM tests reproduce the baseline reward loss and cover the repair, wrong/partial/extra/repeated offers, the preceding note, and an injected nonfriendly guard. Static scope tests separately verify disabled metadata and preserved historical bodies.'
 ],
 'unresolved':[
 'No full-chain claim: loot acquisition, actual NPC variants, real container crafting, inventory settlement, world timing and player UI remain unverified by this supplement.',
 'Exact XP, faction deltas and unrecorded minor coin remain undocumented and unchanged; retained constants are not P99 numerical evidence.',
 'Isolated invocation of disabled historical Lua tests compilation and rejection only, not runtime admission. Policy/admission preservation is a separate static assertion.'
 ],
 'verification':{'current_source_reconciliation':{'artifact':'changes/p99-source-review/review-records.json','scope_receipt':'changes/p99-source-review/scope-receipt.json','runtime_assertions':'changes/p99-source-review/runtime-assertions.json','runtime':'isolated normalized VM, pinned helpers, strict mocked APIs; not game settlement','full_chain':False,'ui':'not_verified'},'prior_review':'changes/p99-sz-review/ledger-records.json'},
 'proposal_sources':list({x['key']:x for x in prior['proposal_sources']+refs(skull)}.values())}
title="Guild Summons - Faydark's Champions"
guild={**base,'local_quest_keys':['gfaydark/Samatansyn_Flamecaller'],'p99_source':evidence(title),
 'notes':['Bounded source-disposition review only. The cached quest notes explicitly identify Samatansyn as not active on P99; this is positive NPC-specific evidence, not inference from an absent quest listing.','His standalone Trueshot newcomer-armor source is proposed disabled by row/header while its full historical body and NPC data are preserved. This does not disable Maesyn or the classic Ranger guild summons.'],
 'unresolved':['No claim that this supplementary source-disposition review verifies the full guild-summons chain, world NPC admission or UI.'],
 'verification':{'source':'whole Samatansyn event source and exact cached quest notes reviewed','runtime':'historical Lua compiles and returns unrelated offers under strict mocked APIs; disabled metadata checked separately','full_chain':False,'ui':'not_verified'},
 'proposal_sources':refs(['gfaydark/Samatansyn_Flamecaller'])}
(R/'changes/p99-source-review/ledger-records.json').write_text(json.dumps({'Shaman Skull Quests':record,title:guild},indent=2)+'\n')
print('2 exact cached quest titles supplemented; no NPC-only/public item-page full-quest promotion')
