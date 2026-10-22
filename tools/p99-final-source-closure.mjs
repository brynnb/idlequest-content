import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import {findProposals,mergeProposals} from './p99-merge-proposals.mjs';
const read=async f=>JSON.parse(await fs.readFile(f,'utf8'));
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const files=['changes/p99-final-admission/review.json','changes/p99-final-chain-closure/review.json','changes/p99-final-uncertainty/review.json'];
const categories={
 disabled_sole_later_source_body_preserved:'new_later_or_event_source_disable',
 positively_later_exclusive_helper:'new_later_or_event_source_disable',
 positively_later_exclusive_controller:'new_later_or_event_source_disable',
 positive_later_or_custom_event_source_only_exclusion:'new_later_or_event_source_disable',
 removed_later_branch_preserved_mixed_source:'new_mixed_source_branch_exclusion',
 mixed_classic_later_controller:'new_mixed_source_branch_exclusion',
 mixed_classic_candidate_preserved_later_branch_excluded:'new_mixed_source_branch_exclusion',
 already_disabled_by_existing_owner:'previous_owner_exclusion_retained',
 unchanged_precise_admission_ambiguity:'unresolved_exact_scope_or_chain',
 unresolved_exact_event_era:'unresolved_exact_scope_or_chain',
 unresolved_after_full_source_and_bounded_evidence_review:'unresolved_exact_scope_or_chain',
 p99_missing_book_grant_unresolved_mapping:'unresolved_documented_p99_effect_mapping',
 p99_identity_corroborated_runtime_semantics_resolved:'documented_unchanged_service_with_limits',
 unchanged_exact_p99_service_documented:'documented_unchanged_service_with_limits',
};
const records=new Map(),artifacts=[];
for(const file of files){
 const bytes=await fs.readFile(file),doc=JSON.parse(bytes);artifacts.push({file,sha256:sha(bytes)});
 for(const [field,list]of [['records',doc.records],['additionalRecords',doc.additionalRecords??[]]])for(const [index,r]of list.entries()){
  const ref={file,sha256:sha(bytes),pointer:`/${field}/${index}`,disposition:r.disposition};
  if(records.has(r.key)){
   if(r.disposition!=='prior_owned_reference')throw Error(`Unexplained duplicate closure ${r.key}`);
   records.get(r.key).reviews.push(ref);continue;
  }
  const category=categories[r.disposition];if(!category)throw Error(`Unclassified closure ${r.key}: ${r.disposition}`);
  const baseline=await fs.readFile(r.baselineFile);
  if(sha(baseline)!==r.baselineSourceSha256)throw Error(`Stale baseline ${r.key}`);
  records.set(r.key,{key:r.key,category,baselineFile:r.baselineFile,baselineSourceSha256:r.baselineSourceSha256,reviews:[ref],fullP99ParityClaim:false});
 }
}
const manifest=await read('manifest.json');
const merged=mergeProposals((await findProposals(process.cwd())).map(p=>p.value),'final-source-closure',Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey])));
const changes=new Map(merged.rows.filter(r=>r.table==='quests'&&r.after).map(r=>[`${r.after.zone}/${r.after.name}`,r]));
const counts={};
for(const r of records.values()){
 const change=changes.get(r.key),body=change?.after.lua_content??await fs.readFile(r.baselineFile,'utf8');
 r.currentSourceSha256=sha(body);r.proposed=Boolean(change);r.currentEnabled=change?.after.enabled??1;
 r.currentSourceFiles=merged.sources.filter(s=>s.afterSha256===r.currentSourceSha256).map(s=>s.proposedFile);
 if(r.category==='new_later_or_event_source_disable'){
  if(!change||change.after.enabled!==0||!body.endsWith(change.before.lua_content))throw Error(`Invalid preserved disable ${r.key}`);
 }
 if(r.category==='new_mixed_source_branch_exclusion'&&(!change||change.after.enabled!==change.before.enabled))throw Error(`Invalid mixed closure ${r.key}`);
 counts[r.category]=(counts[r.category]??0)+1;
}
const report={schemaVersion:1,scope:'Three bounded final followups to earlier source classifications. Not a count of every undocumented numerical value, every source uncertainty, or completed quest families.',artifacts,counts:{uniqueSourceKeys:records.size,dispositions:counts},records:[...records.values()].sort((a,b)=>a.key.localeCompare(b.key)),limits:['Exact actor and chain uncertainty is distinct from absent numerical documentation. Existing values remain fallback evidence where P99 is silent.','A later-era source disable does not certify downstream runtime admission; full-body tests establish preservation, not active playability.','The missing-book grant is a known P99 effect-mapping candidate, not a proven complete quest failure.','Palious and Xantis service findings retain their stated limits; isolated behavior does not establish live settlement.']};
await fs.writeFile('changes/p99-audit/final-source-closure.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report.counts,null,2));
