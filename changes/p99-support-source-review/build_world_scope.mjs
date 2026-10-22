import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import path from 'node:path';
import {findProposals,mergeProposals} from '../../tools/p99-merge-proposals.mjs';
const hash=x=>crypto.createHash('sha256').update(x).digest('hex');
const root=process.cwd(), id='p99-support-world-scope', out='changes/'+id;
const assigned=JSON.parse(await fs.readFile('changes/p99-support-source-review/assignment.json')).records;
const byKey=new Map(assigned.map(r=>[r.key,r]));
const index=new Map(JSON.parse(await fs.readFile('reference/effective-quests-index.json')).map(r=>[r.key,r]));
const rows=new Map();for(const f of (await fs.readdir('data/quests')).filter(f=>f.endsWith('.ndjson')))for(const l of(await fs.readFile('data/quests/'+f,'utf8')).trim().split('\n')){const r=JSON.parse(l);rows.set(`${r.zone}/${r.name}`,r)}
const specifications=[];
for(const r of assigned.filter(r=>r.text.includes('UpdateTaskActivity') && r.text.includes('impression book'))){
 specifications.push({key:r.key,kind:'exclusive_later_task_hook',reason:'Entire source only advances later impression-book tasks. The official EverQuest guide dates the task system to Omens of War, outside Classic through Velious; ordinary NPC and loot data remain unchanged.',proof:[{file:r.baselineFile,sha256:r.currentSourceSha256,detail:'Full source contains only event_killed_merit, IsTaskActive, randomized impression-book HasItem check, UpdateTaskActivity and failure message.'}],evidenceRefs:['official-task-system','repository-era-scope']});
}
const extra={
 'freportn/#Elder_Spirit_of_Perseverance':['exclusive_later_epic_hook','Entire source is the sole signal1 Ruchu ceremony response. Excluded Elder_Spirit_of_Enlightenment explicitly Shaman1.5/2.0 summons8119 and sends this exact signal.'],
 'burningwood/#a_crippled_wurm':['exclusive_later_epic_hook','Only combat kick ability of87155 spawned at druid_epic12. Exact abysmal/Reyfin_Malakwa.pl advances this state from Synched Leather Bag62885, part of later2.0 chain.'],
 'westwastes/Disciple_of_Moon':['exclusive_later_epic_hook','Only combat expiry of120138 created by disciple_of_moon_trap at monk_epic5. Exact potranquility/Vortix.pl labels Monk Epic1.5 and sets this state after two Kaiaren diary halves.'],
 'lfaydark/Reanimated_Minion':['exclusive_later_epic_hook','Only combat assist links57151/57154/57155. Exact spawning Taskmaster_Mirot source explicitly identifies Cleric1.5 and summons these minions under cleric_epic4.'],
 'freportn/#Elder_Spirit_of_Might':['exclusive_later_epic_hook','Only one-second pose and ceremony signal reply. Excluded Elder_Spirit_of_Enlightenment explicitly Shaman1.5/2.0 summons8124 and signals this ceremony helper.'],
 'freportn/#Elder_Spirit_of_Wisdom':['exclusive_later_epic_hook','Only one-second pose and ceremony signal reply. Excluded Elder_Spirit_of_Enlightenment explicitly Shaman1.5/2.0 summons8125 and signals this ceremony helper.'],
 'freportn/#Elder_Spirit_of_Patience':['exclusive_later_epic_hook','Only one-second pose. Excluded Elder_Spirit_of_Enlightenment explicitly Shaman1.5/2.0 summons8126 as the returned spirit.'],
 'eastwastes/#warr_trap':['exclusive_later_epic_hook','Full source explicitly labels Warrior Epic 2.0 and only triggers Larnik through Fazzle map60324 at night.'],
 'eastwastes/Larnik_the_Recluse':['exclusive_later_epic_hook','Full source explicitly labels Warrior Epic 2.0; all dialogue/combat/lifetime branches serve warrior_epic18.'],
 'eastwastes/player':['exclusive_later_epic_hook','Full body only starts the commented druid1.5 Ulthork raid at druid_epic1 with Waterproof Collection Bag62812.'],
 'fieldofbone/#Berserker-s_Image':['exclusive_later_class_epic_hook','Full source explicitly labels Berserker1.0 and only maintains bersolo/death signal and encounter speech. Berserker is introduced by Gates of Discord, not the original14 P99 classes.'],
 'necropolis/player':['exclusive_later_epic_hook','Both complete handlers explicitly bard1.5: flagged Hsagra/Vesthon spawns and item77613 chest progression, no classic hook.'],
 'timorous/player':['exclusive_later_epic_hook','Only handler gates item56014/corpse96368 on cleric20>=3 and creates epic2.0 chest893.'],
 'northkarana/#a_plains_dragon':['exclusive_later_epic_hook','Full source explicitly bard1.5 and only repairs the associated dire spawn after its combat/expiry lifecycle.'],
 'swampofnohope/#a_swamp_dragon':['exclusive_later_epic_hook','Full source explicitly bard1.5 and only repairs the associated dire spawn after its combat/expiry lifecycle.'],
 'misty/Crysta_Tagglefoot':['exclusive_later_event_hook','Full source explicitly Halloween2018; all states, dialogue and spawn chain belong to Halloween2018 globals, not a classic delivery quest.'],
 'lakeofillomen/#_':['exclusive_later_epic_hook','Full body only creates Cursed Talisman16675 scorpion contest under wiz_epic_pre2. Exact consumer v1/Talwyn_Flamecaller labels this pre1.5 and moves16675 to stage3.'],
 'lakerathe/Vortix':['exclusive_later_epic_hook','Only diary dialogue advances monk_epic4 and directs the player to the Plane of Tranquility; no classic Celestial Fists trade or reward branch.'],
 'tox/#Fleshless_Servant':['exclusive_excluded_chain_hook','Only death callback sets grisk1. The exact consumer freportw/Taxonomist_Darwin_Grisk is explicitly excluded in current quest policy as later Luggald/Nadox content.'],
 'dreadlands/#mage_trap':['exclusive_later_epic_hook','Full body only triggers Chaos Elemental86174 at mage_epic10. Exact consumer poknowledge/202328 identifies earlier reward19092 as epic1.5 and next stage reward19839 as epic2.0.'],
 'crushbone/player':['exclusive_later_epic_hook','Only zone entry callback creates Orc Messenger58060 for paladin_epic9. Exact felwithea/#Galrun_Starforge source labels this same Vampire investigation flag Paladin Epic2.0.'],
 'crushbone/#Orc_Messenger':['exclusive_later_epic_hook','Only fifteen-minute lifecycle callback belongs to source-created Orc Messenger58060, explicitly summoned by the later paladin_epic9 player hook.']
};
for(const [key,[kind,detail]]of Object.entries(extra)){
 const r=byKey.get(key);if(!r)throw Error('Not assigned '+key);
 specifications.push({key,kind,reason:detail+' Disable only this quest source and retain the complete historical body; no NPC/world exclusion is inferred.',proof:[{file:r.baselineFile,sha256:r.currentSourceSha256,detail}],evidenceRefs:['repository-era-scope',...(kind==='exclusive_later_class_epic_hook'?['official-berserker-announcement']:kind==='exclusive_later_epic_hook'?['official-epic-two']:[])]});
}
const links={
 'burningwood/#a_crippled_wurm':['effective/quests/burningwood/player.lua','sources/projecteq/abysmal/Reyfin_Malakwa.pl'],
 'westwastes/Disciple_of_Moon':['effective/quests/westwastes/disciple_of_moon_trap.lua','sources/projecteq/potranquility/Vortix.pl'],
 'lfaydark/Reanimated_Minion':['effective/quests/lfaydark/Taskmaster_Mirot.lua'],
 ...Object.fromEntries(['Might','Wisdom','Patience','Perseverance'].map(n=>['freportn/#Elder_Spirit_of_'+n,['effective/quests/freportn/%23Elder_Spirit_of_Enlightenment.lua','reference/server/internal/quest/content_exclusions.json']])),
 'lakeofillomen/#_': ['effective/quests/v1/Talwyn_Flamecaller.lua'],
 'tox/#Fleshless_Servant':['effective/quests/freportw/Taxonomist_Darwin_Grisk.lua','reference/server/internal/quest/content_exclusions.json'],
 'dreadlands/#mage_trap':['effective/quests/poknowledge/202328.lua'],
 'crushbone/player':['effective/quests/felwithea/%23Galrun_Starforge.lua','effective/quests/hohonora/%23Irak_Altil.lua'],
 'crushbone/#Orc_Messenger':['effective/quests/crushbone/player.lua','effective/quests/felwithea/%23Galrun_Starforge.lua'],
};
for(const s of specifications)for(const f of links[s.key]??[])s.proof.push({file:f,sha256:hash(await fs.readFile(f)),scope:'Exact state/item/target dependency, not whole quest parity'});
const proposals=(await findProposals(root)).filter(p=>p.value.id!==id), schema=JSON.parse(await fs.readFile('manifest.json'));
mergeProposals(proposals.map(p=>p.value),'p99-combined-audit',Object.fromEntries(Object.entries(schema.tables).map(([k,v])=>[k,v.primaryKey])));
const proposal={format:1,id,summary:'Disable29 exclusively later-era task, epic or event quest sources missed by lexical support classification. Preserve all historical callback bytes and all NPC/world rows; no blanket era inference by NPC exclusion or item IDs.',baseManifestSha256:hash(await fs.readFile('manifest.json')),evidence:[
 {url:'https://www.everquest.com/news/imported-eq-enus-50720',note:'Official EverQuest guide dated2007-12-11 states that the Task System was introduced with Omens of War. Retrieved2026-10-22 via web tool. Applied only to complete imported task-only impression-book callbacks, not every source containing a word task.'},
 {url:'https://www.everquest.com/news/imported-eq-enus-62693',note:'Official EverQuest character-art update dated2004-06-30 discusses new Epic2.0 weapons as part of Omens of War. Retrieved2026-10-22. Later1.5 exclusions also explicitly preserved in repository quest scope policy; exact source/body dependency proof is recorded separately.'},
 {url:'https://sony.mediaroom.com/2003-12-17-Sony-Online-Entertainment-Unlocks-the-Gates-of-Discord-for-EverQuest',note:'Official Sony2003-12-17 announcement introduces Berserker in Gates of Discord, plannedFebruary2004. Retrieved2026-10-22; only explicitly Berserker-exclusive source is disabled here.'},
 {url:'https://github.com/brynnb/idlequest-content',note:'Pinned local CONTRIBUTING.md and reference/docs/p99-quest-audit-workflow.md define Classic-through-Velious scope and retain actual later-era/event exclusions. See changes/p99-support-source-review/world-scope-dispositions.json for exact proof and limitations.'}
],rows:[],sources:[]};
await fs.mkdir(out,{recursive:true});
for(const s of specifications.sort((a,b)=>a.key.localeCompare(b.key))){
 const before=rows.get(s.key),r=byKey.get(s.key);if(!before||!before.enabled)throw Error('Unexpected baseline '+s.key);
 const owned=proposals.filter(p=>p.value.rows.some(c=>c.table==='quests'&&(c.after??c.before).id===before.id));if(owned.length)throw Error('Already owned '+s.key+' '+owned.map(x=>x.filename));
 if(hash(before.lua_content)!==r.currentSourceSha256)throw Error('Overlay changed '+s.key);
 const text='-- enabled: false\n-- P99 scope: '+s.kind.replaceAll('_',' ')+'. Historical callbacks retained below; see p99-support-source-review/world-scope-dispositions.json.\n'+before.lua_content;
 const after={...before,lua_content:text,enabled:0};
 const i=index.get(s.key);const target=i.preferredSource?.startsWith('maintained/')?i.preferredSource:`maintained/lua/modified-upstream/${s.key}.lua`;
 if(proposals.some(p=>p.value.sources.some(x=>x.target===target)))throw Error('Target already owned '+target);
 let beforeSha256=null;try{beforeSha256=hash(await fs.readFile(target))}catch(e){if(e.code!=='ENOENT')throw e}
 const proposedFile=out+'/'+s.key.replace('/','--')+'.lua';await fs.writeFile(proposedFile,text);
 proposal.rows.push({table:'quests',before,after});proposal.sources.push({target,beforeSha256,proposedFile,afterSha256:hash(text)});
 Object.assign(s,{questId:before.id,baselineSourceSha256:hash(before.lua_content),currentSourceSha256:hash(text),proposedFile,target,enabledBefore:1,enabledAfter:0,bodyPreservedByteForByte:text.endsWith(before.lua_content),limitations:['Only Lua row/import admission changed. No claim that the prior hook was executable or naturally reachable in the live runtime.','No NPC spawn, faction, loot, item, ordinary combat or other quest rows modified.','Source classification and static admission checks are not gameplay/UI validation.']});
}
proposal.summary=proposal.summary.replace('Disable29','Disable'+proposal.rows.length);
await fs.writeFile('changes/'+id+'.json',JSON.stringify(proposal,null,2)+'\n');
await fs.writeFile('changes/p99-support-source-review/world-scope-dispositions.json',JSON.stringify({reviewedAt:new Date().toISOString(),records:specifications},null,2)+'\n');
console.log(JSON.stringify({proposal:'changes/'+id+'.json',sources:proposal.sources.length,rows:proposal.rows.length,ownedKeys:specifications.map(s=>s.key)}));
