import test from 'node:test';import assert from 'node:assert/strict';import fs from 'node:fs';import os from 'node:os';import path from 'node:path';import crypto from 'node:crypto';import {execFileSync} from 'node:child_process';import {findProposals,mergeProposals} from '../../tools/p99-merge-proposals.mjs';
const read=p=>fs.readFileSync(p,'utf8'),sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const p=JSON.parse(read('changes/p99-support-dialogue-fixes.json'));const provenance=JSON.parse(read('changes/p99-support-dialogue-fixes/provenance.json'));
test('dialogue fixes are source/hash bound, preserve baseline and merge without conflicts',async()=>{
 for(const s of p.sources){assert.equal(sha(read(s.proposedFile)),s.afterSha256);assert.equal(fs.existsSync(s.target)?sha(read(s.target)):null,s.beforeSha256);}
 for(const v of provenance){assert.equal(sha(read(v.beforeFile)),v.beforeSha256);for(const e of v.evidence)assert.equal(sha(read(e.path)),e.sha256);}
 assert.equal(p.rows.length,7);assert.equal(p.sources.length,7);for(const r of p.rows){assert.equal(r.table,'quests');if(r.after.enabled===0){assert.equal(r.before.enabled,1);assert.equal(r.after.lua_content,'-- enabled: false\n-- P99 scope: exclusive later-era guide or Beastlord epic hook. Complete callbacks retained below.\n'+r.before.lua_content);assert.deepEqual({...r.after,lua_content:r.before.lua_content},{...r.before,enabled:0});}}
 const proposals=await findProposals(process.cwd());const m=JSON.parse(read('manifest.json'));mergeProposals(proposals.map(x=>x.value),'p99-combined-audit',Object.fromEntries(Object.entries(m.tables).map(([k,v])=>[k,v.primaryKey])));
 const g=p.rows.find(r=>r.after.name==='Grynnaf_Einoom');assert.equal(g.after.lua_content.replace('if e.message:findi("hail") then\n\t\te.self:Emote("looks at " .. e.other:GetName() .. " and wonders if he is looking for the Scalekeeper?")\n\telseif','if'),g.before.lua_content);
 const j=p.rows.find(r=>r.after.name==='Jaxxtz');assert.equal(j.after.lua_content,j.before.lua_content.replace(/\telseif\(e.message:findi\("Vagnar"\)[\s\S]*?(?=\tend\nend\n$)/,''));assert.equal(j.after.enabled,1);
});
test('isolated pinned Lua VM: added hail, retained clues, removed later hints, no effects',t=>{
 const setup=read('tools/p99-test-fixture.lua')+'\neq.say_link=function(s) return s end -- test-only rendering stub, not live link/UI validation\n';const cases=[];
 const noEffects='equal(next(calls.rewards),nil);equal(calls.exp,0);equal(next(calls.factions),nil);equal(#calls.cash,0);equal(#calls.spells,0);equal(#calls.signals,0);equal(calls.depops,0);';
 for(const [key,msg,expected] of [
 ['lfaydark/Grynnaf_Einoom','Hail, Grynnaf_Einoom',['looks at Reviewer and wonders if he is looking for the Scalekeeper?']],
 ['lfaydark/Grynnaf_Einoom','HAIL',['looks at Reviewer and wonders if he is looking for the Scalekeeper?']],
 ['lfaydark/Grynnaf_Einoom','Who is the scalekeeper?',null],
 ['lfaydark/Grynnaf_Einoom','What rusty weapon?',null],
 ['lfaydark/Grynnaf_Einoom','irrelevant',[]],
 ['cabwest/Jaxxtz','Hail',null],
 ['cabwest/Jaxxtz','HAIL',null],
 ['cabwest/Jaxxtz','Vagnar',[]],
 ['cabwest/Jaxxtz','Dragon kin',[]],
 ['cabwest/Jaxxtz','irrelevant',[]]]){
 const row=p.rows.find(r=>r.after.zone+'/'+r.after.name===key);let assertion;
 if(expected===null){
  // Compare exact baseline speech for the existing supported prompts in the same VM.
  assertion='say('+JSON.stringify(msg)+');expected=calls.speech;calls.speech={};'+row.after.lua_content+'\nsay('+JSON.stringify(msg)+');equal(#calls.speech,#expected);for i,v in ipairs(expected) do equal(calls.speech[i],v) end;equal(#calls.speech,1);'+noEffects;
  cases.push({name:key+' retained '+msg,setup,source:row.before.lua_content,assertions:assertion});
 }else{
  assertion='say('+JSON.stringify(msg)+');equal(#calls.speech,'+expected.length+');'+expected.map((v,i)=>'equal(calls.speech['+(i+1)+'],'+JSON.stringify(v)+');').join('')+noEffects;
  cases.push({name:key+' '+msg,setup,source:row.after.lua_content,assertions:assertion});
 }
 }
 for(const row of p.rows.filter(r=>r.after.enabled===0)){const handler=row.after.lua_content.includes('function event_death_complete')?'event_death_complete':'event_say';const assertion=handler==='event_death_complete'?'event_death_complete({self=npc,other=other});equal(#calls.speech,1);':'say("hail");equal(#calls.speech,1);';cases.push({name:row.after.zone+'/'+row.after.name+' retained disabled-source callback (not enabled by loader)',setup,source:row.after.lua_content,assertions:assertion+noEffects});}
 const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'p99-support-dialogue-'));t.after(()=>fs.rmSync(tmp,{recursive:true,force:true}));const binary=path.join(tmp,'runner');execFileSync(process.env.GO_BINARY || 'go',['build','-o',binary,'../tools/p99-lua-runner.go'],{cwd:'validator'});const output=execFileSync(binary,[],{input:JSON.stringify(cases),encoding:'utf8',maxBuffer:1024*1024});assert.equal(output.trim().split('\n').length,cases.length);console.log(output.trim());
});
