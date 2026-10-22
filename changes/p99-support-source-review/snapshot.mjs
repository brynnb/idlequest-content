import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import {findProposals,mergeProposals} from '../../tools/p99-merge-proposals.mjs';
const root=process.cwd(), hash=x=>crypto.createHash('sha256').update(x).digest('hex');
const coverage=JSON.parse(await fs.readFile('changes/p99-audit/source-coverage.json'));
const proposalEntries=await findProposals(root), manifest=JSON.parse(await fs.readFile('manifest.json'));
const overlay=mergeProposals(proposalEntries.map(x=>x.value),'p99-combined-audit',Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey])));
const rows=new Map();
for(const f of (await fs.readdir('data/quests')).filter(f=>f.endsWith('.ndjson'))) for(const line of (await fs.readFile('data/quests/'+f,'utf8')).trim().split('\n')) {const r=JSON.parse(line); rows.set(r.id,r)}
for(const r of overlay.rows.filter(r=>r.table==='quests')) if(r.after) rows.set(r.after.id,r.after); else rows.delete(r.before.id);
const selected=coverage.records.filter(r=>['world_dialogue_or_support_no_literal_reward_calls','name_mentioned_requires_mapping_not_proof_of_review'].includes(r.structuralDisposition)&&r.currentEnabled&&!r.questPolicy).map(r=>{
const row=rows.get(r.id),text=row.lua_content,sha256=hash(text); return {...r, currentEnabled:row.enabled, currentSourceSha256:sha256, coverageSnapshotSha256:r.currentSourceSha256, sourceHashChanged:sha256!==r.currentSourceSha256, text, proposalOwners:proposalEntries.filter(p=>p.value.rows.some(c=>c.table==='quests'&&(c.after??c.before).id===r.id)).map(p=>p.filename)};
}).sort((a,b)=>a.key.localeCompare(b.key));
const groups=new Map(); for(const r of selected) {if(!groups.has(r.currentSourceSha256))groups.set(r.currentSourceSha256,[]);groups.get(r.currentSourceSha256).push(r.key)}
const artifact={createdAt:new Date().toISOString(),scope:'Exact current enabled and no questPolicy original records in two lexical-only categories. Current proposal overlay can alter activation and hashes. No review inferred by selection.',coverageFileSha256:hash(await fs.readFile('changes/p99-audit/source-coverage.json')),proposalCount:proposalEntries.length,proposalFiles:proposalEntries.map(x=>({path:x.filename,sha256:hash(JSON.stringify(x.value))})),records:selected,duplicateGroups:[...groups].filter(([h,ks])=>ks.length>1).map(([sha256,keys])=>({sha256,representative:keys[0],keys}))};
await fs.writeFile('changes/p99-support-source-review/assignment.json',JSON.stringify(artifact,null,2)+'\n');
for(const kind of ['world','named']){const s=selected.filter(r=>(r.structuralDisposition.startsWith('world')?'world':'named')===kind); await fs.writeFile(`changes/p99-support-source-review/${kind}-sources.json`,JSON.stringify(s,null,2)+'\n')}
console.log(JSON.stringify({records:selected.length,uniqueHashes:groups.size,sourceHashChanges:selected.filter(x=>x.sourceHashChanged).map(x=>x.key),disabled:selected.filter(x=>!x.currentEnabled).map(x=>x.key),bytes:selected.reduce((n,r)=>n+r.text.length,0),groups:[...groups].filter(([h,ks])=>ks.length>5).map(([sha256,keys])=>({sha256,keys}))},null,2));
