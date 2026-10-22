import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
const root=path.resolve(process.argv[2]??'.');
const read=async p=>JSON.parse(await fs.readFile(path.join(root,p),'utf8'));
const target='reference/server/internal/quest/content_exclusions.json';
const baseline=await read(target), ledger=structuredClone(baseline), changed=new Set();
const evidenceIndex=await read('reference/p99-evidence-index.json');
function apply(title,entry,artifact){
 const previous=ledger.p99_audit[title]??{};
 const original=baseline.p99_audit[title];
 const evidence=evidenceIndex.find(x=>x.title===title);
 const merged={...previous,...entry};
 merged.notes=[...new Set([...(entry.notes??[]),...(changed.has(title)?previous.notes??[]:[])])];
 if(entry.unresolved||previous.unresolved) merged.unresolved=[...new Set([...(previous.unresolved??[]),...(entry.unresolved??[])])];
 if(original) merged.prior_audit={review_status:original.review_status,match_status:original.match_status,reviewed_at:original.reviewed_at,notes:original.notes??[]};
 merged.audit_evidence_files=[...new Set([...(previous.audit_evidence_files??[]),artifact])];
 if(!merged.p99_source && evidence) merged.p99_source={title,url:evidence.url,raw_cache:evidence.cachePath,sha256:evidence.sha256};
 ledger.p99_audit[title]=merged;changed.add(title);
}
for(const file of ['changes/p99-am-review/ledger-records.json','changes/p99-classic-conversions/ledger-additions.json','changes/p99-conversions-velious/ledger-updates.json','changes/p99-af-review/ledger-records.json','changes/p99-sz-review/ledger-records.json','changes/p99-tz-review/ledger-records.json','changes/p99-guild-review/ledger-records.json','changes/p99-il-review/ledger-records.json','changes/p99-source-review/ledger-records.json','changes/p99-armor-review/ledger-records.json','changes/p99-trade-surface-review/ledger-records.json','changes/p99-ranger-epic-review/ledger-records.json','changes/p99-paladin-epic-review/ledger-records.json']){
 try {for(const [title,entry]of Object.entries(await read(file))) apply(title,entry,file);}catch(e){if(e.code!=='ENOENT')throw e;}
}
for(const dir of (await fs.readdir(path.join(root,'changes'))).filter(x=>x.startsWith('p99-nz-'))){
 const file=`changes/${dir}/review-evidence.json`;
 let update;try{update=await read(file);}catch(e){if(e.code==='ENOENT'||e.code==='ENOTDIR')continue;throw e;}
 for(const title of update.titles??[]) apply(title,{reviewed_at:update.reviewed_at,review_status:update.review_status,match_status:update.match_status,local_quest_keys:update.local_quest_keys,notes:[...(update.notes??[]),...(update.unresolved??[])],verification:update.verification},file);
}
for(const file of ['changes/p99-tz-review/manual-facet-review.json','changes/p99-nz-coverage/manual-facet-review.json']) {
 for(const row of await read(file)) {
  const facets=row.verified_facets??row.reviewed_facets??{};
  const notes=Object.entries(facets).map(([key,value])=>`${key}: ${typeof value==='string'?value:JSON.stringify(value)}`);
  const source=row.evidence;
  apply(row.title,{reviewed_at:'2026-10-22',review_status:'partial',match_status:'source_facets_reviewed_with_open_limits',
   local_quest_keys:(row.sources??row.scripts??[]).map(s=>s.key).filter(Boolean),
   p99_source:{title:row.title,url:source.url,raw_cache:source.cachePath,sha256:source.sha256},
   notes:[...notes,...(row.unresolved??[])],unresolved:row.unresolved??[],
   verification:row.verification??{source:'Static cached-page/source review only',runtime:'not_verified',ui:'not_verified'},
  },file);
 }
}
// This explicitly retracts an earlier fresh-review item-identity mistake.
// Keep its audit trail separate instead of publishing contradictory live notes.
{
 const file='changes/p99-am-review/storm-kcor-ledger-correction.json';
 for(const [title,entry] of Object.entries(await read(file))) {
  const superseded=ledger.p99_audit[title];
  apply(title,entry,file);
  ledger.p99_audit[title].superseded_current_review={reason:'Wrong item29124/29624 comparison retracted by the correction artifact',notes:superseded?.notes??[]};
  ledger.p99_audit[title].notes=entry.notes??[];
  ledger.p99_audit[title].unresolved=entry.unresolved??[];
 }
}
// Correct a stale handoff label and distinguish page scope from actual quest policy.
{
 const file='changes/p99-audit/triage-ledger-followups.json';
 for(const [title,entry] of Object.entries(await read(file))){
  const previous=structuredClone(ledger.p99_audit[title]);apply(title,entry,file);
  ledger.p99_audit[title].superseded_current_review={reason:'Parallel conversion handoff resolved; page scope is not an actual runtime exclusion',local_enabled:previous?.local_enabled,notes:previous?.notes??[]};
  ledger.p99_audit[title].notes=entry.notes;
 }
}
const neb=await read('changes/p99-neb-lua/review.json');apply("Key to Jaled Dar's Lair (Neb)",neb.ledgerUpdate,'changes/p99-neb-lua/review.json');
const jaled=await read('changes/p99-jaled-lua/review.json');apply(jaled.title,{review_status:'partial',match_status:'converted_lua_static_handin_parity_runtime_unverified',reviewed_at:'2026-10-22',local_quest_keys:['necropolis/Jaled_Dar-s_shade'],notes:[jaled.implemented,...jaled.uncertainty]},'changes/p99-jaled-lua/review.json');
const wooly=await read('changes/p99-wooly-recipe/review.json');
apply(wooly.title,{review_status:'partial',match_status:'partial',reviewed_at:'2026-10-22',notes:['Enable existing recipe9835: eight Wooly Fungus13967 in Empty Jar17946 produce Jar of Fungus13966, matching cached P99 counts and container slots.',wooly.verification]},'changes/p99-wooly-recipe/review.json');
const containerReview=await read('changes/p99-audit/container-compatibility.json');
const recipeEvidence=await read('tools/p99-recipe-expectations.json');
const inventory=await read('changes/p99-audit/inventory.json');
for(const row of containerReview.records.filter(r=>r.staticBlocks.length)) {
 const spec=recipeEvidence.find(r=>r.recipeId===row.recipeId);
 const page=inventory.pages.find(p=>p.cachePath===spec.evidence.cachePath);
 if(!page)throw new Error(`Cannot map blocked recipe ${row.recipeId} to cached quest page`);
 const note=`Recipe ${row.recipeId} (${row.name}) has downstream static blocks in the compatibility review: ${row.staticBlocks.join(', ')}. Enabling its content row does not make it craftable. See changes/p99-audit/container-compatibility.json; the game registry was not modified.`;
 apply(page.title,{review_status:'partial',match_status:'partial_downstream_runtime_block',notes:[note],unresolved:[note]},'changes/p99-audit/container-compatibility.json');
}
const file='changes/p99-audit-ledger/content_exclusions.json';await fs.mkdir(path.dirname(path.join(root,file)),{recursive:true});
const content=JSON.stringify(ledger,null,2)+'\n';await fs.writeFile(path.join(root,file),content);
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const proposal={format:1,id:'p99-audit-ledger',summary:'Record evidence-backed partial reviews and conversions while preserving historical audit notes separately; no exclusion removals.',baseManifestSha256:sha(await fs.readFile(path.join(root,'manifest.json'))),evidence:[{url:'https://wiki.project1999.com/Category:Quests',note:'Per-title exact cached evidence and hashes are linked from audit_evidence_files; historical reviewed status is not a fresh full-playability claim.'}],rows:[],sources:[{target,beforeSha256:sha(await fs.readFile(path.join(root,target))),proposedFile:file,afterSha256:sha(content)}]};
await fs.writeFile(path.join(root,'changes/p99-audit-ledger/proposal.json'),JSON.stringify(proposal,null,2)+'\n');
console.log(JSON.stringify({updatedTitles:changed.size,titles:[...changed].sort()}));
