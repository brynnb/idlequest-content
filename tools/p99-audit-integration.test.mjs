import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import {findProposals,mergeProposals} from './p99-merge-proposals.mjs';
const read=async p=>JSON.parse(await fs.readFile(p,'utf8'));
test('fresh page coverage reconciles all cached titles without claiming full parity',async()=>{
 const inventory=await read('changes/p99-audit/inventory.json');
 const coverage=await read('changes/p99-audit/review-coverage.json');
 assert.equal(coverage.pages.length,1135);
 assert.deepEqual(coverage.pages.map(x=>x.title).sort(),inventory.pages.map(x=>x.title).sort());
 assert.equal(new Set(coverage.pages.map(x=>x.title)).size,1135);
 const counts={};
 for(const page of coverage.pages){
  assert.ok(['unreviewed','screen_only','branch_facets_only','source_facets_reviewed','page_type_classified_only'].includes(page.disposition));
  counts[page.disposition]=(counts[page.disposition]??0)+1;
  assert.equal(page.evidence.sha256,inventory.pages.find(x=>x.title===page.title).sha256);
  assert.ok(page.reviewArtifacts.length>0,page.title);
 }
 assert.deepEqual(counts,coverage.counts);
 assert.equal(coverage.additionalReviewTitlesOutsideCachedCorpus.length,0);
 assert.match(coverage.limits.join(' '),/not full P99 parity/);
});
test('every original missing-Lua key has one explicit reviewed disposition',async()=>{
 const expected=await read('changes/p99-audit/missing-lua-triage.json');
 const groups=[(await read('changes/p99-classic-conversions/triage.json')).records,await read('changes/p99-audit/manual-event-dispositions.json'),await read('changes/p99-audit/manual-linked-dispositions.json'),(await read('changes/p99-conversions-velious/remaining-dispositions.json')).records];
 const records=groups.flat();assert.equal(records.length,452);assert.equal(new Set(records.map(x=>x.key)).size,452);
 assert.deepEqual(records.map(x=>x.key).sort(),expected.map(x=>x.key).sort());
 for(const record of records){
  const base=expected.find(x=>x.key===record.key);
  const source=record.source??record.source_path??base.file;
  const hash=record.sha256??record.source_sha256??record.sourceSha256??base.sha256;
  assert.equal(crypto.createHash('sha256').update(await fs.readFile(source)).digest('hex'),hash,record.key);
  assert.ok(record.disposition??record.outcome??record.reviewClassification,record.key);
 }
});
test('consolidated ledger preserves all existing exclusions and historical records',async()=>{
 const before=await read('reference/server/internal/quest/content_exclusions.json');
 const after=await read('changes/p99-audit-ledger/content_exclusions.json');
 assert.deepEqual(after.quests,before.quests);
 for(const [title,record]of Object.entries(before.p99_audit)){
  assert.ok(after.p99_audit[title],title);
  if(after.p99_audit[title].audit_evidence_files)assert.deepEqual(after.p99_audit[title].prior_audit.notes,record.notes??[],title);
  else assert.deepEqual(after.p99_audit[title],record,title);
 }
});
test('all 499 P99-zone empty quest rows reconcile to triage or explicit preserved policy',async()=>{
 const inventory=await read('changes/p99-audit/inventory.json');
 const policy=await read('changes/p99-audit/excluded-empty-rows.json');
 const empty=inventory.effective.filter(x=>x.p99Zone&&x.sourceStatus==='no-lua-body');
 assert.equal(empty.length,499);assert.equal(policy.length,47);
 const triage=await read('changes/p99-audit/missing-lua-triage.json');
 const keys=[...triage,...policy].map(x=>x.key);assert.equal(new Set(keys).size,499);
 assert.deepEqual(keys.sort(),empty.map(x=>x.key).sort());
});
test('current source and empty-row reports reconcile every proposed body without activation claims',async()=>{
 const inventory=await read('changes/p99-audit/inventory.json');
 const report=await read('changes/p99-audit/resolution-report.json');
 const coverage=await read('changes/p99-audit/source-coverage.json');
 const manifest=await read('manifest.json');
 const keys=Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey]));
 const merged=mergeProposals((await findProposals('.')).map(x=>x.value),'test-current-resolution',keys);
 const changes=new Map(merged.rows.filter(r=>r.table==='quests'&&r.after).map(r=>[`${r.after.zone}/${r.after.name}`,r]));
 const digest=s=>crypto.createHash('sha256').update(s).digest('hex');
 const base=inventory.effective.filter(r=>r.p99Zone);
 assert.deepEqual(coverage.records.map(r=>r.key).sort(),base.map(r=>r.key).sort());
 const counts={};
 for(const row of coverage.records){
  const original=base.find(r=>r.key===row.key),change=changes.get(row.key);
  assert.equal(row.currentEnabled,change?change.after.enabled:original.enabled,row.key);
  assert.equal(row.currentSourceSha256,change?digest(change.after.lua_content??''):original.sha256,row.key);
  counts[row.structuralDisposition]=(counts[row.structuralDisposition]??0)+1;
 }
 assert.deepEqual(counts,coverage.counts);
 const empty=base.filter(r=>r.sourceStatus==='no-lua-body');
 assert.equal(report.originalEmpty.length,499);
 assert.deepEqual(report.originalEmpty.map(r=>r.key).sort(),empty.map(r=>r.key).sort());
 for(const row of report.originalEmpty){
  const change=changes.get(row.key),body=change?.after.lua_content;
  assert.equal(row.proposedSourceSha256,body?.trim()?digest(body):null,row.key);
  if(body?.trim()&&change.after.enabled)assert.equal(row.currentProposalState,'proposed_lua_row_enabled_not_activation_verified');
 }
 assert.deepEqual(report.newRows.map(r=>r.key).sort(),[...changes].filter(([,r])=>r.before===null).map(([k])=>k).sort());
});

test('enabled P99 scripts avoid the bridge\'s unsupported multi-item QuestReward table form',async()=>{
 const inventory=await read('changes/p99-audit/inventory.json');
 const manifest=await read('manifest.json');
 const keys=Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey]));
 const merged=mergeProposals((await findProposals('.')).map(x=>x.value),'test-reward-bridge',keys);
 const policies=(await read('reference/server/internal/quest/content_exclusions.json')).quests;
 const current=new Map();
 for(const row of inventory.effective.filter(r=>r.p99Zone))current.set(row.key,{enabled:row.enabled,source:row.sourceStatus==='no-lua-body'?'':await fs.readFile(row.file,'utf8')});
 for(const row of merged.rows.filter(r=>r.table==='quests'&&r.after))current.set(`${row.after.zone}/${row.after.name}`,{enabled:row.after.enabled,source:row.after.lua_content});
 // Pinned PlayerProxy.QuestReward only reads scalar itemid, not an items array.
 // This is a narrow regression guard, not a general Lua/API compatibility proof.
 const unsupported=[...current].filter(([key,row])=>row.enabled&&!policies[key]&&/:QuestReward\s*\(\s*[^,]+,\s*\{[^}]*\bitems\s*=/.test(row.source)).map(([key])=>key);
 assert.deepEqual(unsupported,[],'Use explicit SummonItem calls for verified multiple outputs');
});

test('focused existing-Lua review reconciles all assigned sources without promoting uncertain evidence',async()=>{
 const assignment=await read('changes/p99-source-review/assignment.json');
 const review=await read('changes/p99-source-review/review-records.json');
 assert.equal(review.records.length,213);assert.equal(new Set(review.records.map(r=>r.key)).size,213);
 assert.deepEqual(review.records.map(r=>r.key).sort(),assignment.records.map(r=>r.key).sort());
 const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
 assert.equal(review.assignmentSha256,hash(await fs.readFile('changes/p99-source-review/assignment.json')));
 for(const row of review.records){
  assert.equal(row.baselineSourceSha256,hash(await fs.readFile(row.baselineFile)),row.key);
  assert.ok(row.sourceSpecificReview.length>20,row.key);assert.ok(row.disposition,row.key);
  assert.ok(row.parityLimitations.length,row.key);
  if(row.proposedState)assert.equal(row.proposedState.sourceSha256,hash(await fs.readFile(row.proposedState.proposedFile)),row.key);
 }
});

test('refund-only trade review is complete for its assigned129 sources without erasing other-handler limits',async()=>{
 const review=await read('changes/p99-trade-surface-review/review-records.json');
 const pairs=review.assignment.keyHashPairs;
 assert.equal(review.records.length,129);assert.equal(new Set(review.records.map(r=>r.key)).size,129);
 assert.deepEqual(review.records.map(r=>r.key).sort(),pairs.map(r=>r.key).sort());
 const digest=b=>crypto.createHash('sha256').update(b).digest('hex');
 for(const row of review.records){
  assert.equal(row.currentSourceSha256,pairs.find(r=>r.key===row.key).currentSourceSha256,row.key);
  assert.equal(row.currentSourceSha256,digest(await fs.readFile(row.baselineFile)),row.key);
  assert.equal(row.verification.fullDialogueWikiParity,'not_claimed');
  assert.equal(row.tradeInspection.acceptsOrConsumesInputs,false,row.key);
  assert.equal(row.tradeInspection.dispatchesOtherCallbacks,false,row.key);
  assert.ok(row.sourceSpecificReview.length>30,row.key);assert.ok(row.retainedUncertainties.length,row.key);
  for(const page of row.cachedEvidence??[])assert.equal(page.sha256,digest(await fs.readFile(page.cachePath)),row.key);
 }
});

test('twelve positively evidenced later-only source disables preserve every callback and unrelated row field',async()=>{
 let count=0;
 for(const file of ['changes/p99-source-scope-disables.json','changes/p99-trade-scope-disables.json']){
  const proposal=await read(file);assert.equal(proposal.rows.length,proposal.sources.length);
  for(const row of proposal.rows){
   assert.equal(row.table,'quests');assert.equal(row.before.enabled,1);assert.equal(row.after.enabled,0);
   const {enabled:be,lua_content:bl,...before}=row.before,{enabled:ae,lua_content:al,...after}=row.after;
   assert.deepEqual(after,before);assert.ok(al.startsWith('-- enabled: false\n'));
   assert.equal(al.split('\n').slice(2).join('\n'),bl);
   const hash=crypto.createHash('sha256').update(al).digest('hex');
   const source=proposal.sources.find(s=>s.afterSha256===hash);assert.ok(source);
   assert.equal(await fs.readFile(source.proposedFile,'utf8'),al);count++;
  }
 }
 assert.equal(count,12);
});

test('old parallel-conversion placeholders have an actual proposal or explicit final evidence disposition',async()=>{
 const report=await read('changes/p99-audit/resolution-report.json');
 for(const row of report.originalEmpty){
  if(row.originalDisposition.record.outcome!=='assigned_parallel_conversion')continue;
  if(row.proposedSourceSha256)assert.ok(row.proposedSourceFiles.length,row.key);
  else {
   const followup=row.currentDispositionFollowup;assert.ok(followup,row.key);
   assert.notEqual(followup.outcome,'assigned_parallel_conversion');
   assert.equal(crypto.createHash('sha256').update(await fs.readFile(followup.evidence.cachePath)).digest('hex'),followup.evidence.sha256);
  }
 }
});

test('all1079 support sources have byte-bound full-body reviews and explicit current dispositions',async()=>{
 const file='changes/p99-support-source-review/review-records.json';
 const review=await read(file),assignment=await read('changes/p99-support-source-review/assignment.json');
 const digest=b=>crypto.createHash('sha256').update(b).digest('hex');
 assert.equal(review.assignmentSha256,digest(await fs.readFile('changes/p99-support-source-review/assignment.json')));
 assert.equal(review.records.length,1079);assert.equal(new Set(review.records.map(r=>r.key)).size,1079);
 assert.deepEqual(review.records.map(r=>r.key).sort(),assignment.records.map(r=>r.key).sort());
 const assigned=new Map(assignment.records.map(r=>[r.key,r]));
 const manifest=await read('manifest.json'),keys=Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey]));
 const merged=mergeProposals((await findProposals(process.cwd())).map(p=>p.value),'review-integrity',keys);
 const current=new Map(merged.rows.filter(r=>r.table==='quests'&&r.after).map(r=>[`${r.after.zone}/${r.after.name}`,r.after]));
 for(const row of review.records){
  const original=assigned.get(row.key);assert.equal(row.assignmentSourceSha256,digest(original.text),row.key);
  assert.equal(row.fullAssignedSourceBodyRead,true,row.key);assert.equal(row.fullP99ParityClaim,false,row.key);
  assert.ok(JSON.stringify(row.summary).length>20,row.key);assert.ok(row.disposition,row.key);assert.ok(row.limitations.length,row.key);
  const body=current.get(row.key)?.lua_content??await fs.readFile(original.baselineFile,'utf8');
  if(row.currentSourceSha256!==digest(body)){
   const followup=merged.rows.find(r=>r.table==='quests'&&r.after&&`${r.after.zone}/${r.after.name}`===row.key);
   assert.ok(followup,`Unexplained support drift: ${row.key}`);
   assert.equal(digest(followup.before.lua_content),row.currentSourceSha256,`Followup preimage mismatch: ${row.key}`);
   const closure=await read('changes/p99-final-chain-closure/review.json');
   assert.ok([...(closure.records??[]),...(closure.additionalRecords??[])].some(r=>r.key===row.key),`Missing exact final closure: ${row.key}`);
  }
 }
 for(const artifact of review.splitArtifacts)assert.equal(artifact.sha256,digest(await fs.readFile(artifact.file)),artifact.file);
 const cases=await read('changes/p99-support-source-review/runtime-assertions.json');
 assert.equal(new Set(cases.cases.map(r=>r.proposedFile)).size,92);
});

test('all124 feasibility assignments are closed against original Perl and current Lua bytes',async()=>{
 const assignment=await read('changes/p99-conversion-closure/assignments.json');
 const groups={trade:'trades',ambient:'ambient',world:'world',root_era_identity:'era-identity'};
 const seen=new Set();let converted=0;
 const digest=b=>crypto.createHash('sha256').update(b).digest('hex');
 const manifest=await read('manifest.json');
 const merged=mergeProposals((await findProposals(process.cwd())).map(p=>p.value),'closure-integrity',Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey])));
 const current=new Map(merged.rows.filter(r=>r.table==='quests'&&r.after).map(r=>[`${r.after.zone}/${r.after.name}`,r.after]));
 for(const [group,folder]of Object.entries(groups)){
  const expected=assignment.assignments[group],review=await read(`changes/p99-conversion-${folder}/closure-review.json`);
  assert.deepEqual(review.records.map(r=>r.key).sort(),expected.map(r=>r.key).sort(),group);
  for(const record of review.records){
   assert.ok(!seen.has(record.key),record.key);seen.add(record.key);
   const original=expected.find(r=>r.key===record.key);
   const source=record.sourcePerl??record.originalSource;
   const sourceHash=record.sourcePerlSha256??record.originalSourceSha256;
   assert.equal(source,original.source,record.key);assert.equal(sourceHash,original.sha256,record.key);
   assert.equal(digest(await fs.readFile(source)),original.sha256,record.key);
   assert.ok(record.status??record.classification??record.finalDisposition,record.key);
   const proposedFile=record.proposedFile??record.proposedSource;
   if(proposedFile){
    converted++;const bytes=await fs.readFile(proposedFile,'utf8');
    if(record.proposedSourceSha256)assert.equal(digest(bytes),record.proposedSourceSha256,record.key);
    assert.equal(bytes,current.get(record.key)?.lua_content,record.key);
   }
  }
 }
 assert.equal(seen.size,124);assert.equal(converted,51);
 const world=await read('changes/p99-conversion-world/closure-review.json');
 assert.equal(world.additionalRecords.length,3);
 for(const r of world.additionalRecords){assert.equal(current.get(r.key).enabled,0,r.key);assert.equal(digest(await fs.readFile(r.proposedSource)),r.proposedSourceSha256,r.key);}
});

test('final source followups reconcile exact dispositions without hiding remaining uncertainty',async()=>{
 const report=await read('changes/p99-audit/final-source-closure.json');
 assert.equal(report.records.length,194);assert.equal(new Set(report.records.map(r=>r.key)).size,194);
 assert.deepEqual(report.counts.dispositions,{
  new_later_or_event_source_disable:151,
  new_mixed_source_branch_exclusion:10,
  previous_owner_exclusion_retained:2,
  unresolved_exact_scope_or_chain:28,
  documented_unchanged_service_with_limits:2,
  unresolved_documented_p99_effect_mapping:1,
 });
 const digest=b=>crypto.createHash('sha256').update(b).digest('hex');
 for(const artifact of report.artifacts)assert.equal(digest(await fs.readFile(artifact.file)),artifact.sha256,artifact.file);
 for(const r of report.records){
  assert.equal(digest(await fs.readFile(r.baselineFile)),r.baselineSourceSha256,r.key);
  for(const f of r.currentSourceFiles)assert.equal(digest(await fs.readFile(f)),r.currentSourceSha256,r.key);
  assert.equal(r.fullP99ParityClaim,false,r.key);
 }
});
