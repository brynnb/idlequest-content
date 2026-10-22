import fs from 'node:fs/promises';import crypto from 'node:crypto';import {findProposals,mergeProposals} from '../../tools/p99-merge-proposals.mjs';
const hash=x=>crypto.createHash('sha256').update(x).digest('hex');
const manifest=JSON.parse(await fs.readFile('manifest.json'));const ps=await findProposals(process.cwd());const overlay=mergeProposals(ps.map(x=>x.value),'p99-combined-audit',Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey])));
const names=['druid_1_5','ring_war','cloaked','Misty','vesthon','paladin_epic','trumpy','berserkerepic_1_5','motg'];const rows=new Map(); const modules=new Map();
for(const [dir,map,key] of [['quests',rows,'id'],['quest_lua_modules',modules,'module_name']])for(const p of await fs.readdir('data/'+dir))for(const line of (await fs.readFile('data/'+dir+'/'+p,'utf8')).trim().split('\n')){const r=JSON.parse(line);map.set(r[key],r);}
for(const r of overlay.rows){const m=r.table==='quests'?rows:r.table==='quest_lua_modules'?modules:null;if(m){const k=r.table==='quests'?'id':'module_name'; if(r.after)m.set(r.after[k],r.after);else m.delete(r.before[k]);}}
const relevant=[...rows.values()].filter(r=>r.zone==='encounters'&&names.includes(r.name)).map(r=>({key:r.zone+'/'+r.name,id:r.id,enabled:r.enabled,sha256:hash(r.lua_content),text:r.lua_content,proposalOwners:ps.filter(p=>p.value.rows.some(c=>c.table==='quests'&&(c.after??c.before).id===r.id)).map(p=>p.filename)}));
const mods=[...modules.values()].filter(r=>['zone_assistance','aa_box','thread_manager'].includes(r.module_name)).map(r=>({...r,sha256:hash(r.lua_content)}));
await fs.writeFile('changes/p99-support-source-review/lifecycle-review-dependencies.json',JSON.stringify({createdAt:new Date().toISOString(),proposalCount:ps.length,encounters:relevant,modules:mods},null,2)+'\n');
console.log(JSON.stringify(relevant.map(({text,...rest})=>rest),null,2));
