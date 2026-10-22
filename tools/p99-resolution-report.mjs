// Reconcile immutable inventory against all current proposals, not old triage labels.
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {findProposals,mergeProposals} from './p99-merge-proposals.mjs';
const root=path.resolve(process.argv[2]??'.');
const read=async p=>JSON.parse(await fs.readFile(path.join(root,p),'utf8'));
const inventory=await read('changes/p99-audit/inventory.json');
const manifest=await read('manifest.json');
const zones=new Set(await read('changes/p99-audit/p99_zones.json'));
const keys=Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey]));
const inputs=await findProposals(root),proposal=mergeProposals(inputs.map(x=>x.value),'resolution-report',keys);
const changes=new Map(proposal.rows.filter(r=>r.table==='quests'&&r.after).map(r=>[`${r.after.zone}/${r.after.name}`,r]));
const dispositions=new Map();
for(const file of ['changes/p99-classic-conversions/triage.json','changes/p99-conversions-velious/remaining-dispositions.json','changes/p99-audit/manual-event-dispositions.json','changes/p99-audit/manual-linked-dispositions.json','changes/p99-audit/excluded-empty-rows.json']) {
 const value=await read(file);
 for(const record of Array.isArray(value)?value:value.records) {
  if(dispositions.has(record.key))throw new Error(`Duplicate original disposition ${record.key}`);
  dispositions.set(record.key,{artifact:file,record});
 }
}
const followups=new Map((await read('changes/p99-audit/triage-followups.json')).map(r=>[r.key,r]));
const conversionFollowups=new Map();
for(const file of ['changes/p99-conversion-trades/closure-review.json','changes/p99-conversion-ambient/closure-review.json','changes/p99-conversion-world/closure-review.json','changes/p99-conversion-era-identity/closure-review.json']) {
 try { const value=await read(file);for(const record of [...value.records,...(value.additionalRecords??[])]){if(conversionFollowups.has(record.key))throw new Error(`Duplicate conversion followup ${record.key}`);conversionFollowups.set(record.key,{artifact:file,record});}} catch(error){if(error.code!=='ENOENT')throw error;}
}
const digest=x=>crypto.createHash('sha256').update(x).digest('hex');
const originalEmpty=inventory.effective.filter(r=>r.p99Zone&&r.sourceStatus==='no-lua-body').map(base=>{
 const change=changes.get(base.key),after=change?.after;
 const hasLua=Boolean(after?.lua_content?.trim());
 const disposition=dispositions.get(base.key);
 if(!disposition)throw new Error(`Missing original disposition ${base.key}`);
 return {key:base.key,originalQuestId:base.id,originalEnabled:base.enabled,
  originalPolicy:base.questExclusion,originalDisposition:disposition,currentDispositionFollowup:followups.get(base.key)??null,currentConversionReview:conversionFollowups.get(base.key)??null,
  currentProposalState:hasLua?(after.enabled?'proposed_lua_row_enabled_not_activation_verified':'proposed_lua_row_disabled')
   :disposition.artifact.endsWith('excluded-empty-rows.json')?'no_proposed_lua_explicit_policy':'no_proposed_lua_see_reviewed_disposition',
  proposedSourceSha256:hasLua?digest(after.lua_content):null,
  proposedSourceFiles:hasLua?proposal.sources.filter(s=>s.afterSha256===digest(after.lua_content)).map(s=>s.proposedFile):[],
 };
});
const newRows=[...changes.values()].filter(r=>r.before===null).map(r=>({key:`${r.after.zone}/${r.after.name}`,id:r.after.id,p99Zone:zones.has(r.after.zone),enabled:r.after.enabled,sourceSha256:digest(r.after.lua_content??'')}));
const counts={};for(const r of originalEmpty)counts[r.currentProposalState]=(counts[r.currentProposalState]??0)+1;
const report={schemaVersion:1,baselineManifestSha256:digest(await fs.readFile(path.join(root,'manifest.json'))),
 counts:{originalEmptyP99Rows:originalEmpty.length,states:counts,newQuestRows:newRows.length,newP99ZoneQuestRows:newRows.filter(r=>r.p99Zone).length},
 originalEmpty,newRows,
 limits:['This reconciles original empty-row inventory with current proposals; original triage remains preserved as historical input.','An enabled row is not proof of runtime activation, natural acquisition, connected-world completion or P99 numerical parity.','Unconverted rows retain their exact reviewed exclusions, later-era evidence, unsupported mechanics or uncertainty; they are not silently counted as Lua conversions.','Existing Lua and broader cached-page review are tracked separately in inventory.json and review-coverage.json.']};
await fs.writeFile(path.join(root,'changes/p99-audit/resolution-report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report.counts,null,2));
