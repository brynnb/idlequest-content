import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {findProposals} from '../../tools/p99-merge-proposals.mjs';
const sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const read=p=>fs.readFileSync(p,'utf8');
const rows=fs.readdirSync('data/quests').filter(f=>f.endsWith('.ndjson')).flatMap(f=>read('data/quests/'+f).trim().split('\n').filter(Boolean).map(JSON.parse));
const index=JSON.parse(read('reference/effective-quests-index.json'));
const edits=[
{key:'lfaydark/Grynnaf_Einoom',target:'maintained/lua/converted-perl/lfaydark/Grynnaf_Einoom.lua',transform:s=>s.replace('if e.message:findi("Who is the scalekeeper?") then','if e.message:findi("hail") then\n\t\te.self:Emote("looks at " .. e.other:GetName() .. " and wonders if he is looking for the Scalekeeper?")\n\telseif e.message:findi("Who is the scalekeeper?") then'),evidence:['reference/p99-wiki/npc-pages/grynnaf-einoom-7ebd33467c.wiki'],note:'Restore only the NPC page documented hail emote. Existing Nortlav and rusty-weapon directions remain byte-preserved after inserted branch. Page spells display name Grynnaf Einoo but also names Grynnaf Einoom and Lesser Faydark identity; both exported same-name NPC identities are documented, not silently interchanged.'},
{key:'cabwest/Jaxxtz',target:'maintained/lua/modified-upstream/cabwest/Jaxxtz.lua',transform:s=>s.replace(/\telseif\(e.message:findi\("Vagnar"\)[\s\S]*?(?=\tend\nend\n$)/,''),evidence:['reference/p99-wiki/npc-pages/jaxxtz-f966d40991.wiki','reference/p99-wiki/raw-pages/shaman-skull-quests-b63ed30880.wiki'],note:'Preserve documented Kunark merchant hail; remove only Vagnar and Dragon kin directions. NPC page maps these to Shaman Skull Quest No.6; primary quest page explicitly excludes quests beyond five as Luclin. No merchant row, inventory, faction value or NPC availability changed.'}
];
const proposals=(await findProposals(process.cwd())).filter(p=>p.filename!=='changes/p99-support-dialogue-fixes.json');
const output={format:1,id:'p99-support-dialogue-fixes',summary:'Restore Grynnaf discovery hail; remove Jaxxtz Skull6 hints; suppress only later troll cultural guide and exact Beastlord epic helper/controller scripts, preserving NPCs and source bodies.',baseManifestSha256:sha(read('manifest.json')),evidence:[],rows:[],sources:[]};
const provenance=[];
for(const e of edits){
 const i=index.find(i=>i.key===e.key), row=rows.find(r=>r.id===i.id), source=read(i.file);
 if(source!==row.lua_content)throw Error('Source/row mismatch '+e.key);
 if(proposals.some(p=>p.value.rows.some(r=>r.table==='quests'&&(r.before??r.after).id===row.id)||p.value.sources.some(s=>[i.preferredSource,e.target].includes(s.target)))) throw Error('Overlapping owner '+e.key);
 const after=e.transform(source);if(source===after)throw Error('No edit '+e.key);
 const out='changes/p99-support-dialogue-fixes/'+e.key.replace('/','--')+'.lua';fs.writeFileSync(out,after);
 output.rows.push({table:'quests',before:row,after:{...row,lua_content:after}});
 output.sources.push({target:e.target,beforeSha256:fs.existsSync(e.target)?sha(read(e.target)):null,proposedFile:out,afterSha256:sha(after)});
 const evid=e.evidence.map(p=>{const m=JSON.parse(read(p.replace('.wiki','.json')));if(sha(read(p))!==m.sha256)throw Error('Evidence hash mismatch '+p);return {...m,path:p};});
 for(const m of evid)output.evidence.push({url:m.url,note:`Cached ${m.fetchedAt}; revision unavailable; SHA256 ${m.sha256}. ${e.note}`});
 provenance.push({key:e.key,questId:row.id,beforeFile:i.file,beforeSha256:sha(source),preferredSource:i.preferredSource,preferredSourceSha256:sha(read(i.preferredSource)),afterFile:out,afterSha256:sha(after),currentProposalOwners:[],facts:e.note,evidence:evid,limits:['Source/body and isolated mocked Lua tests only; no live game bridge, rendered UI, pathing, spawned actor or merchant inventory test.','No numeric rewards, prices, XP, faction deltas or encounter values changed.','npc_types.exclude=1 is not interpreted as a quest ban.']});
}

const suppressions=[
 {key:'grobb/Kragia',scope:'original dialogue assignment',reason:'Complete source only teaches troll cultural acrylia weapons. Primary P99 Skill Blacksmithing explicitly says troll cultural smithing is not in game due to timeline; classic warrior trainer NPC is preserved.',evidence:['reference/p99-wiki/crafting-restoration-2026-10-09/Skill_Blacksmithing.wiki','reference/p99-wiki/npc-pages/kragia-c945028d43.wiki']},
 {key:'emeraldjungle/The_Spirit_of_Rage',scope:'original dialogue assignment',reason:'Death-only Omakin farewell helper. Scout Vyrak takes9031 and spawns NPC94126, whose exact exported name is #The_Spirit_of_Rage. Helper key lacks # and inspected runtime does not prove alias dispatch; preventive later-only helper suppression, not a claim this body currently executes. Not a Druid1.0 spirit.',evidence:[]},
 {key:'permafrost/The_Icebound_Spirit',scope:'original dialogue assignment',reason:'Death-only Zehkes farewell helper. Scout Janomin takes9031 and spawns exact NPC73107 The_Icebound_Spirit. Not a Druid1.0 spirit.',evidence:[]},
 {key:'emeraldjungle/Scout_Vyrak',scope:'explicitly authorized EXTRA controller outside original312',reason:'Full source has only Shar Vahl greeting, seal9031 encounter94126 spawn, and gorilla totem9038 to9031+9039 wrapping. No independent classic branch.',evidence:[]},
 {key:'permafrost/Scout_Janomin',scope:'explicitly authorized EXTRA controller outside original312',reason:'Full source has only Shar Vahl greeting, seal9031 encounter73107 spawn/return9031, and ice bear totem9036 to9037 wrapping. No independent classic branch.',evidence:[]}
];
const beastEvidence=['effective/quests/emeraldjungle/Scout_Vyrak.lua','effective/quests/permafrost/Scout_Janomin.lua','sources/projecteq/sharvahl/Elder_Animist_Dumul.pl','sources/projecteq/stonebrunt/Scout_Malom.pl','reference/server/internal/contentscope/npc_exclusions.json','changes/p99-support-source-review/dialogue-review-additional-evidence.json'];
for(const e of suppressions){
 const i=index.find(i=>i.key===e.key),row=rows.find(r=>r.id===i.id),source=read(i.file);
 if(source!==row.lua_content||row.enabled!==1)throw Error('Unexpected baseline '+e.key);
 if(proposals.some(p=>p.value.rows.some(r=>r.table==='quests'&&(r.before??r.after).id===row.id)))throw Error('Overlapping owner '+e.key);
 const evid=(e.key==='grobb/Kragia'?e.evidence:beastEvidence).map(path=>({path,sha256:sha(read(path))}));
 const target=i.preferredSource.startsWith('maintained/')?i.preferredSource:'maintained/lua/modified-upstream/'+e.key+'.lua';
 if(proposals.some(p=>p.value.sources.some(s=>s.target===target)))throw Error('Overlapping source owner '+e.key);
 const after='-- enabled: false\n-- P99 scope: exclusive later-era guide or Beastlord epic hook. Complete callbacks retained below.\n'+source;
 const out='changes/p99-support-dialogue-fixes/'+e.key.replace('/','--')+'.lua';fs.writeFileSync(out,after);
 output.rows.push({table:'quests',before:row,after:{...row,enabled:0,lua_content:after}});
 output.sources.push({target,beforeSha256:fs.existsSync(target)?sha(read(target)):null,proposedFile:out,afterSha256:sha(after)});
 output.evidence.push({url:e.key==='grobb/Kragia'?'https://wiki.project1999.com/Skill_Blacksmithing':'https://github.com/brynnb/idlequest-content',note:e.reason+' Exact local hashes, numeric NPC mapping and controller source provenance in changes/p99-support-dialogue-fixes/provenance.json. For Beastlord: Dumul explicitly says beastlord, creates9031, sets bstepic, directs Luclin zones; existing exact Scout Malom100171/Spirit of Torment100220 policy calls same9031 family Luclin Beastlord epic. No claim current Vyrak/Janomin were already excluded.'});
 provenance.push({key:e.key,questId:row.id,assignmentScope:e.scope,beforeFile:i.file,beforeSha256:sha(source),afterFile:out,afterSha256:sha(after),preferredSource:i.preferredSource,preferredSourceSha256:sha(read(i.preferredSource)),change:'quests.enabled 1->0 plus source-persistent disable header; complete callbacks byte-identical',facts:e.reason,currentProposalOwners:[],evidence:evid,limits:['Quest-source activation flag only; no NPC row, exclusion bit, spawn, loot, merchant or training data changed.','Prior enabled controllers are deliberately corrected here; no claim that historical policy already excluded them.','Positive exact chain dependency, not class/name resemblance or absence from a wiki list.','Isolated package/VM validation, not a live-engine test.']});
}

fs.writeFileSync('changes/p99-support-dialogue-fixes.json',JSON.stringify(output,null,2)+'\n');
fs.writeFileSync('changes/p99-support-dialogue-fixes/provenance.json',JSON.stringify(provenance,null,2)+'\n');
console.log(JSON.stringify({rows:output.rows.length,sources:output.sources.length,provenance:provenance.map(p=>({key:p.key,before:p.beforeSha256,after:p.afterSha256}))}));
