// Structural source reconciliation, deliberately not a claim of full semantic review.
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {findProposals,mergeProposals} from './p99-merge-proposals.mjs';
const root=path.resolve(process.argv[2]??'.');
const read=async p=>JSON.parse(await fs.readFile(path.join(root,p),'utf8'));
const inventory=await read('changes/p99-audit/inventory.json');
const questPolicies=(await read('reference/server/internal/quest/content_exclusions.json')).quests;
const npcPolicies=await read('reference/server/internal/contentscope/npc_exclusions.json');
const normalize=s=>s.replace(/^#+/,'').replaceAll('_',' ').trim().toLowerCase();
const mentions=new Map(),pageKeys=new Map();
for(const page of inventory.pages) {
 const source=await fs.readFile(path.join(root,page.cachePath),'utf8');
 for(const match of source.matchAll(/\[\[([^\]|#]+)/g)) {
  const key=normalize(match[1]);if(!mentions.has(key))mentions.set(key,new Set());mentions.get(key).add(page.title);
 }
 for(const key of page.localQuestKeys) {
  if(!pageKeys.has(key))pageKeys.set(key,[]);pageKeys.get(key).push(page.title);
 }
}
const manifest=await read('manifest.json');
const primaryKeys=Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey]));
const proposals=await findProposals(root);
const merged=mergeProposals(proposals.map(p=>p.value),'source-coverage',primaryKeys);
const changes=new Map(merged.rows.filter(r=>r.table==='quests'&&r.after).map(r=>[`${r.after.zone}/${r.after.name}`,r]));
const npcRows=[...(npcPolicies.npcs??[]),...(npcPolicies.additional_npcs??[]),...(npcPolicies.inactive_npcs??[])];
const patterns=npcPolicies.name_patterns.map(p=>({...p,regex:new RegExp(p.pattern)}));
const currentPageKeys=new Map();
const originalPageReviews=(await read('reference/server/internal/quest/content_exclusions.json')).p99_audit;
for(const [title,review] of Object.entries((await read('changes/p99-audit-ledger/content_exclusions.json')).p99_audit)){
 if(JSON.stringify(review)===JSON.stringify(originalPageReviews[title]))continue;
 for(const key of review.local_quest_keys??[]){if(!currentPageKeys.has(key))currentPageKeys.set(key,[]);currentPageKeys.get(key).push(title);}
}
const focusedFile='changes/p99-source-review/review-records.json';
const focusedRows=(await read(focusedFile)).records;
const focused=new Map(focusedRows.map(r=>[r.key,r]));
const tradeFile='changes/p99-trade-surface-review/review-records.json';
const tradeReviews=new Map((await read(tradeFile)).records.map(r=>[r.key,r]));
const tradeFollowups=new Map((await read('changes/p99-trade-surface-review/followup-disables.json')).map(r=>[r.key,r]));
const supportFile='changes/p99-support-source-review/review-records.json';
const supportReviews=new Map((await read(supportFile)).records.map(r=>[r.key,r]));
const finalClosures=new Map();
for(const file of ['changes/p99-final-chain-closure/review.json','changes/p99-final-admission/review.json','changes/p99-final-uncertainty/review.json']) {
 try { const data=await read(file);for(const record of [...(data.records??[]),...(data.additionalRecords??[])]){
  if(finalClosures.has(record.key)){
   if(record.key==='befallen/#Sir_Ariam_Arcanum')continue;
   throw new Error(`Duplicate final source closure: ${record.key}`);
  }
  finalClosures.set(record.key,{artifact:file,record});
 }} catch(error){if(error.code!=='ENOENT')throw error;}
}
const records=[];
for(const row of inventory.effective.filter(r=>r.p99Zone)) {
 const [zone,name]=row.key.split('/');
 const change=changes.get(row.key);
 const source=change?.after.lua_content??(row.sourceStatus==='no-lua-body'?'':await fs.readFile(path.join(root,row.file),'utf8'));
 const enabled=change?change.after.enabled:row.enabled;
 const handlers=[...new Set([...source.matchAll(/function\s+(event_\w+)\s*\(/g)].map(m=>m[1]))].sort();
 const rewardCalls=[...new Set([...source.matchAll(/:(SummonItem|QuestReward|AddEXP|GiveCash|Faction)\s*\(/g)].map(m=>m[1]))].sort();
 const policy=questPolicies[row.key]??null;
 const npcPolicyCandidates=npcRows.filter(n=>(!n.zone||n.zone===zone)&&(n.name===name||String(n.id)===name));
 const namePatterns=patterns.filter(p=>p.regex.test(name)).map(({regex,...p})=>p);
 const pageReferences=pageKeys.get(row.key)??[];
 const currentPageReviewReferences=currentPageKeys.get(row.key)??[];
 const nameMentionPages=[...(mentions.get(normalize(name))??[])].sort();
 let structuralDisposition;
 if(!source.trim())structuralDisposition='empty_row_see_resolution_report';
 else if(!enabled)structuralDisposition='disabled_lua_retained_not_activated';
 else if(policy||namePatterns.length)structuralDisposition='explicit_policy_retained';
 else if(row.sourceStatus==='no-lua-body')structuralDisposition='new_lua_source_see_resolution_report';
 else if(finalClosures.has(row.key))structuralDisposition='final_source_closure_see_disposition_and_limits';
 else if(supportReviews.has(row.key))structuralDisposition='complete_support_source_review_see_disposition_and_limits';
 else if(pageReferences.length)structuralDisposition='historically_page_linked_see_current_page_review';
 else if(currentPageReviewReferences.length)structuralDisposition='current_page_linked_see_review_limits';
 else if(nameMentionPages.length)structuralDisposition='name_mentioned_requires_mapping_not_proof_of_review';
 else if(handlers.includes('event_trade')&&rewardCalls.length)structuralDisposition='unmapped_trade_with_reward_calls_requires_disposition';
 else if(handlers.includes('event_trade'))structuralDisposition='unmapped_trade_no_literal_reward_calls_requires_inspection';
 else if(rewardCalls.length)structuralDisposition='unmapped_reward_without_trade_requires_disposition';
 else structuralDisposition='world_dialogue_or_support_no_literal_reward_calls';
 const focusedReview=focused.get(row.key),tradeReview=tradeReviews.get(row.key);
 if(tradeReview&&structuralDisposition.startsWith('unmapped_'))structuralDisposition='reviewed_refund_only_trade_see_other_handler_limits';
 if(focusedReview&&structuralDisposition.startsWith('unmapped_'))structuralDisposition='reviewed_unmapped_source_see_explicit_disposition';
 records.push({key:row.key,id:row.id,baselineEnabled:row.enabled,currentEnabled:enabled,proposed:Boolean(change),
  baselineFile:row.file,currentSourceSha256:crypto.createHash('sha256').update(source).digest('hex'),handlers,rewardCalls,questPolicy:policy,npcPolicyCandidates,namePatterns,
  historicalPageReferences:pageReferences,currentPageReviewReferences,nameMentionPages,structuralDisposition,
  supportSourceReview:supportReviews.has(row.key)?{artifact:supportFile,reviewedSourceSha256:supportReviews.get(row.key).reviewedSourceSha256,reviewSnapshotSourceSha256:supportReviews.get(row.key).currentSourceSha256,disposition:supportReviews.get(row.key).disposition,fullAssignedSourceBodyRead:supportReviews.get(row.key).fullAssignedSourceBodyRead,summary:supportReviews.get(row.key).summary,fullP99ParityClaim:false}:null,
  tradeSurfaceReview:tradeReview?{artifact:tradeFile,reviewedSourceSha256:tradeReview.currentSourceSha256,disposition:tradeReview.disposition,otherHandlerCategory:tradeReview.otherHandlerCategory,followup:tradeFollowups.get(row.key)??null}:null,
  latestSourceClosure:finalClosures.get(row.key)??null,
  focusedSourceReview:focusedReview?{artifact:focusedFile,disposition:focusedReview.disposition,action:focusedReview.action}:null});
}
const counts={};for(const r of records)counts[r.structuralDisposition]=(counts[r.structuralDisposition]??0)+1;
const report={schemaVersion:1,counts,records,limits:[
 'Covers every original P99-zone quest row, including unchanged existing Lua; newly introduced actors are listed separately in resolution-report.json.',
 'Handler and reward detection is lexical only. Absence of these literal calls is not proof that a script has no quest behavior.',
 'Historical page links and same-name wiki mentions are navigation aids, not source-review or runtime-identity proof.',
 'NPC policy candidates include global inactive names; exact actor-ID admission must be checked before treating a candidate as a definitive runtime exclusion.',
 'Disabled Lua is retained without activation; no undocumented later-era quest is enabled solely because its zone is in scope.',
 'Specific full source reviews and unresolved facets remain in the linked coverage artifacts. This report does not certify parity or live execution.'
]};
await fs.writeFile(path.join(root,'changes/p99-audit/source-coverage.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(counts,null,2));
