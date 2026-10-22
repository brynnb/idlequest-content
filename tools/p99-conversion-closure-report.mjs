// Deterministic, fail-closed accounting of original empty rows, not quest families.
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const hash = x => crypto.createHash('sha256').update(x).digest('hex');
export const BUCKETS = ['positive_later_or_event_exclusion','empty_source_or_handler','proven_alias_or_superseded','retained_explicit_policy_or_unsupported_variant','genuine_quest_progress_runtime_or_policy_blocker','ambient_world_dungeon_contract_gap','unresolved_era_or_identity','placeholder_without_proven_quest'];
const later = new Set(['post-era-loy-freed-slave','post-era-task-system','post-era-shadowrest','post-era-ldon','post-era-loy-cultural','post-era-guktan-illusion','out-of-scope-ring-of-fear-revamp','out-of-scope-beastlord-epic','post-era-hole-revamp','excluded_later_epic','post-era-phylactery','excluded-holiday-gm-event','post-era-loy-pirate','post-era-novice-armor','post-era-charm-quest','post-era-epic','excluded_luclin_transport','excluded_post_velious_branch','excluded_eighth_shawl','excluded_later_class','out-of-scope-holiday-event','out-of-scope-holiday-task','later-era-epic-prequest','post-era-veksar','post-era-beastlord-guildmaster','post-era-loy','post-era-vp-revamp','excluded_luclin_sleeper_revamp','excluded_luclin_quest_no_conversion','excluded_post_velious']);
const empty = new Set(['no_conversion_empty_source','empty-event-no-conversion-needed','empty-handler-no-conversion','empty-reference']);
export function classifyNoLua(row, review) {
 const original=row.originalDisposition.record;
 const rec=row.currentDispositionFollowup ?? original;
 const label=rec.outcome ?? rec.reviewClassification ?? rec.disposition ?? rec.classification;
 const status=review?.status ?? review?.classification ?? review?.finalDisposition;
 if (review) {
  if (['positively_later','event_scope_exclusion','later-only'].includes(status)) return BUCKETS[0];
  if (['superseded_by_existing_adaptation','superseded_optional_flavor'].includes(status)) return BUCKETS[2];
  if (['uncertain_era_identity','era_uncertain_spawn_chain_not_enabled'].includes(status)) return BUCKETS[6];
  if (status==='true_runtime_block') return row.key==='kael/a_bag_of_supplies'?BUCKETS[4]:BUCKETS[5];
  if (['ambient/world behavior with unsupported runtime','blocked_current_runtime','blocked_conflicting_classic_spawn_contract','blocked_conflicting_classic_key_contract','blocked_missing_authored_classic_route','blocked_conflicting_classic_encounter'].includes(status)) return BUCKETS[5];
  throw new Error(`Review implies conversion or has unrecognized disposition for no-Lua row ${row.key}: ${status}; refresh resolution-report first`);
 }
 if (row.originalPolicy?.reason==='p99_replaced_spawn_cycle') return BUCKETS[2];
 if (row.key==='wakening/Shamus_Aghllsews') return BUCKETS[4];
 // A policy label alone is not independent positive era proof (e.g. Nelef/Iago).
 if (['explicit-npc-policy','explicit-quest-exclusion'].includes(label)) return BUCKETS[3];
 if (later.has(label)) return BUCKETS[0];
 if (empty.has(label)) return BUCKETS[1];
 if (['identity-alias-existing-lua','superseded_direct_neb_dialogue'].includes(label)) return BUCKETS[2];
 if (label==='placeholder-no-proven-quest') return BUCKETS[7];
 if (label==='later-revamp-encounter-reference') return BUCKETS[6];
 if (label==='p99-npc-roaming-only-not-quest') return BUCKETS[5];
 throw new Error(`Unclassified no-Lua row ${row.key}: ${label}`);
}
function tally(rows, field) {const result={};for(const row of rows) result[row[field]]=(result[row[field]]??0)+1;return result;}
function links(value, result=new Set()) {if(typeof value==='string' && /^https?:\/\//.test(value))result.add(value);else if(value&&typeof value==='object')for(const v of Object.values(value))links(v,result);return [...result].sort();}
export async function buildReport(root='.') {
 const bindings=[];
 async function read(p) {const raw=await fs.readFile(path.join(root,p));bindings.push({path:p,sha256:hash(raw)});return JSON.parse(raw);}
 const resolutionPath='changes/p99-audit/resolution-report.json';
 const resolution=await read(resolutionPath);
 const assignments=await read('changes/p99-conversion-closure/assignments.json');
 const reviews=new Map(), groups=[];
 for(const group of ['trades','ambient','world','era-identity']) {
  const artifact=`changes/p99-conversion-${group}/closure-review.json`, d=await read(artifact);
  for(const [section, records] of [['records',d.records],['additionalRecords',d.additionalRecords??[]]]) for(const [index,record] of records.entries()) {
   if(reviews.has(record.key)) throw new Error(`Duplicate review ${record.key}`);
   reviews.set(record.key,{group,artifact,section,index,record});
  }
  groups.push({group,originalAssignments:d.records.length,authorizedExtensions:(d.additionalRecords??[]).length,originalReviewStatuses:tally(d.records.map(r=>({status:r.status??r.classification??r.finalDisposition})),'status')});
 }
 for(const p of new Set(resolution.originalEmpty.map(r=>r.originalDisposition.artifact))) await read(p);
 await read('changes/p99-audit/triage-followups.json');
 const rows=resolution.originalEmpty.map(row=>{
  const review=reviews.get(row.key), record=review?.record;
  const hasLua=row.currentProposalState.startsWith('proposed_lua_row_');
  if(hasLua!==Boolean(row.proposedSourceSha256))throw new Error(`Lua state/hash disagreement ${row.key}`);
  if(record?.proposedSourceSha256 && record.proposedSourceSha256!==row.proposedSourceSha256)throw new Error(`Conversion review/resolution source hash disagreement ${row.key}`);
  const status=record?.status??record?.classification??record?.finalDisposition??null;
  const original=row.originalDisposition.record, current=row.currentDispositionFollowup??original;
  return {key:row.key,originalQuestId:row.originalQuestId,originalEnabled:row.originalEnabled,currentProposalState:row.currentProposalState,hasLua,
   noLuaBucket:hasLua?null:classifyNoLua(row,record),
   assignmentGroup:review?.section==='records'?review.group:null,authorizedExtension:review?.section==='additionalRecords',
   conversionScope:!hasLua?null:status==='converted_partial'?'partial_flavor_or_refund_only':status?.includes('cosmetic_runtime_limit')?'translated_with_cosmetic_runtime_limit':status?.includes('blocked')||status?.includes('disabled')?'translated_but_family_or_policy_blocked':status??'prior_conversion_see_bound_resolution',
   reviewStatus:status,reason:record?.reason??record?.currentRuntimeReason??current.reason??current.decision??row.originalPolicy?.note??'See bound original disposition.',
   originalPolicy:row.originalPolicy,originalDisposition:{artifact:row.originalDisposition.artifact,key:row.key,label:original.outcome??original.reviewClassification??original.disposition??original.classification},
   conversionReview:review?{artifact:review.artifact,jsonPointer:`/${review.section}/${review.index}`,key:row.key}:null,
   originalSource:record?.sourcePerl??record?.originalSource??original.source??original.file??null,
   originalSourceSha256:record?.sourcePerlSha256??record?.originalSourceSha256??original.source_sha256??original.sha256??null,
   proposedSourceSha256:row.proposedSourceSha256,proposedSourceFiles:row.proposedSourceFiles,
   evidenceUrls:links([original,current,record]),resolutionPointer:`/originalEmpty/${resolution.originalEmpty.indexOf(row)}`};
 });
 if(rows.length!==499||new Set(rows.map(r=>r.key)).size!==499)throw new Error('Original inventory must contain exactly 499 unique rows');
 const originalKeys=new Set(rows.map(r=>r.key));for(const key of reviews.keys())if(!originalKeys.has(key))throw new Error(`Review outside original inventory ${key}`);
 const assigned=Object.values(assignments.assignments).flat();if(assigned.length!==124||new Set(assigned.map(r=>r.key)).size!==124)throw new Error('Expected 124 disjoint initial assignments');
 for(const r of assigned)if(reviews.get(r.key)?.section!=='records')throw new Error(`Missing assignment review ${r.key}`);
 const noLua=rows.filter(r=>!r.hasLua),lua=rows.filter(r=>r.hasLua);
 const counts={originalEmptyP99Rows:rows.length,nowLua:lua.length,enabledLua:lua.filter(r=>r.currentProposalState==='proposed_lua_row_enabled_not_activation_verified').length,disabledLua:lua.filter(r=>r.currentProposalState==='proposed_lua_row_disabled').length,noLua:noLua.length,noLuaBuckets:Object.fromEntries(BUCKETS.map(b=>[b,noLua.filter(r=>r.noLuaBucket===b).length])),initialAssignments:124,assignedNowLua:lua.filter(r=>r.assignmentGroup).length,authorizedExtensionRows:rows.filter(r=>r.authorizedExtension).length,extensionNowLua:lua.filter(r=>r.authorizedExtension).length,priorNowLua:lua.filter(r=>!r.assignmentGroup&&!r.authorizedExtension).length,conversionScopes:tally(lua,'conversionScope')};
 for(const group of groups) {const scope=rows.filter(r=>r.assignmentGroup===group.group);group.nowLua=scope.filter(r=>r.hasLua).length;group.noLua=scope.filter(r=>!r.hasLua).length;}
 const retainedQuestFamilies=[
  {family:'Broodmother escort',keys:['thurgadina/Erdarf_Restil'],limitation:'Converted but retained disabled; escort choreography is not activation verified.'},
  {family:'Crest of the Fauns',keys:['kael/a_bag_of_supplies','wakening/Shamus_Aghllsews'],limitation:'Bag has no Lua: damaging explosion/ground rubble settlement blocker. Shamus remains disabled and unconverted.'},
  {family:'The Velium Focus',keys:['wakening/Phenocryst','wakening/Bloodpriest_Ioukond','wakening/accolyte_of_Zek'],limitation:'Assigned helpers translated; authorized caller translated but retained disabled; complete approach/procession parity not established.'},
  {family:'Reinforcements for The Tunarean Regiment',keys:['wakening/#Lieutenant_Krofer','wakening/Lieutenant_Krofer','wakening/Corporal_Hlash','wakening/Berzerker_Dolvad','wakening/Berzerker_Voldak','wakening/Disciple_Atharm','wakening/a_sifaye_defender'],limitation:'Five assigned helpers translated; two authorized caller/reward extensions translated but retained disabled; full choreography/policy activation not established.'}
 ].map(f=>({...f,rows:f.keys.map(key=>{const r=rows.find(r=>r.key===key);if(!r)throw new Error(`Missing family row ${key}`);return {key,hasLua:r.hasLua,currentProposalState:r.currentProposalState};})}));
 return {schemaVersion:1,baselineManifestSha256:resolution.baselineManifestSha256,inputBindings:bindings,counts,assignmentGroups:groups,retainedQuestFamilies,
  limits:['Rows are not quest families. Lua presence is not proof of playable quests, natural acquisition, runtime activation, numerical parity or UI settlement.',
   'No generic unresolved bucket: unmatched dispositions fail generation. Era/identity uncertainty remains explicitly named and is not a positive later-era finding.',
   'Explicit policy without independent positive era evidence is retained in its own bucket, including unsupported variants; not relabeled later merely from absence of documentation.',
   'The 12 world/encounter contract gaps plus 3 era-uncertain world rows are not direct quest-reward blockers. Kalayia is roaming parity only; Charasis conflicts with the P99 temporary wing-key contract, not the entrance-key reward quest.',
   'The 12 ambient contract gaps and two era-reviewed boat transport markers are not reward-quest blocks. Skeleton trooper adds one separately reviewed roaming contract gap.',
   'Partial flavor/refund translations omit unsupported or unverified branches and are not complete quest conversions. Cosmetic limitations and translated helpers in blocked families are separately labeled.',
   'The separate downstream container review retains 18 runtime gaps; existing-Lua uncertainty and broader page coverage are outside this 499-row inventory.',
   'Source/evidence hashes and links are retained through bound public artifacts. Only sanitized compatibility conclusions and public baseline references are used.'],rows};
}
export function renderMarkdown(report) {
 const c=report.counts;
 return `# Original empty P99-row conversion closure\n\nExactly **${c.originalEmptyP99Rows} original rows**: **${c.nowLua} now have proposed Lua** (${c.enabledLua} enabled, ${c.disabledLua} disabled); **${c.noLua} still have no Lua**. These are rows, not completed quests or quest families.\n\n## Remaining no-Lua rows\n\n${Object.entries(c.noLuaBuckets).map(([k,v])=>`- ${k}: **${v}**`).join('\n')}\n\n## Assignment accounting\n\n${report.assignmentGroups.map(g=>`- ${g.group}: ${g.originalAssignments} original assignments; ${g.nowLua} Lua, ${g.noLua} no Lua; ${g.authorizedExtensions} separately authorized extensions.`).join('\n')}\n\n${c.priorNowLua} prior Lua + ${c.assignedNowLua} newly assigned Lua + ${c.extensionNowLua} authorized extension Lua = ${c.nowLua}. Original assignment total remains 124; extensions are not silently folded into it.\n\n## Conversion scope\n\n${Object.entries(c.conversionScopes).map(([k,v])=>`- ${k}: ${v}`).join('\n')}\n\n## Retained genuine quest families\n\n${report.retainedQuestFamilies.map(f=>`- **${f.family}**: ${f.limitation} (${f.keys.join(', ')})`).join('\n')}\n\n## Limits and provenance\n\n${report.limits.map(s=>`- ${s}`).join('\n')}\n\n[Machine-readable row-by-row report](conversion-closure-report.json) includes exact keys, states, source hashes, evidence links, and hash-bound disposition/review pointers.\n`;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href) {
 const root=path.resolve(process.argv[2]??'.'),report=await buildReport(root);
 const base=path.join(root,'changes/p99-audit/conversion-closure-report');
 await fs.writeFile(base+'.json',JSON.stringify(report,null,2)+'\n');await fs.writeFile(base+'.md',renderMarkdown(report));console.log(JSON.stringify(report.counts,null,2));
}
