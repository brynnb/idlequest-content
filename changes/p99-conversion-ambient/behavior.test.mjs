import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'../..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const hash=s=>createHash('sha256').update(s).digest('hex');
test('Ambient original hashes, exact named identities and untouched source policy',()=>{
 const a=JSON.parse(read('changes/p99-conversion-ambient/assignment.json'));
 assert.equal(a.rows.length,34);
 for(const row of a.rows) assert.equal(hash(read(row.sourceFile)),row.sourceSha256,row.key);
 const p=JSON.parse(read('changes/p99-conversion-ambient.json'));
 const evidence=JSON.parse(read('changes/p99-conversion-ambient/identity-and-path-evidence.json'));
 assert.equal(p.rows.length,21);assert.equal(p.sources.length,21);
 for(const row of p.rows){
  assert.equal(row.table,'quests');assert.equal(row.before.enabled,row.after.enabled);assert.equal(row.before.id,row.after.id);assert.equal(row.before.name,row.after.name);
  if(row.after.name.startsWith('Councilor_')) {
   const ids=evidence.npcTypes.filter(n=>n.name===row.after.name).map(n=>n.id);assert.ok(ids.length);
   const groups=evidence.spawnentry.filter(s=>ids.includes(s.npcID)).map(s=>s.spawngroupID);
   const spawns=evidence.spawn2.filter(s=>groups.includes(s.spawngroupID)&&s.zone==='thurgadinb');
   assert.ok(spawns.length);for(const spawn of spawns)assert.equal(spawn.pathgrid,0);
   assert.match(row.after.lua_content,/-- actors: world/);
  }
 }
 for(const s of p.sources){assert.equal(hash(read(s.proposedFile)),s.afterSha256);assert.ok(!fs.existsSync(path.join(root,s.target)));}
 // The similarly spelled actor is not silently remapped to the imported script.
 assert.ok(!evidence.npcTypes.some(n=>n.name==='Initiate_Sirchthain'));
 const captive=evidence.npcTypes.find(n=>n.name==='gnomish_captive');assert.equal(captive.id,118154);
 assert.match(read('effective/quests/greatdivide/Bloodmaw.lua'),/eq\.spawn2\(118026,/);
});
test('Ambient focused isolated Lua captures, not live persistence/rendering',t=>{
 const manifest=JSON.parse(read('changes/p99-conversion-ambient/runtime-assertions.json'));
 const fixture=read('tools/p99-test-fixture.lua')+'\npackage.preload["items"]=function()\n'+read('sources/projecteq/lua_modules/items.lua')+'\nend\n';
 const cases=manifest.cases.map(c=>{for(const dep of c.dependencySources??[])assert.equal(hash(read(dep.path)),dep.sha256);const source=read(c.proposedFile);assert.equal(hash(source),c.sourceSha256);return {...c,source,setup:fixture+'\n'+c.setupExtra};});
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'p99-ambient-'));t.after(()=>fs.rmSync(dir,{recursive:true,force:true}));
 const binary=path.join(dir,'runner');
 execFileSync(process.env.P99_GO ?? 'go',['build','-o',binary,'../tools/p99-lua-runner.go'],{cwd:path.join(root,'validator'),env:process.env,encoding:'utf8'});
 const log=execFileSync(binary,[],{input:JSON.stringify(cases),encoding:'utf8',maxBuffer:5*1024*1024});assert.equal(log.trim().split('\n').length,cases.length);
 fs.writeFileSync(path.join(root,'changes/p99-conversion-ambient/isolated-test.log'),log);
 fs.writeFileSync(path.join(root,'changes/p99-conversion-ambient/test-receipt.json'),JSON.stringify({kind:'isolated-script-logic-not-live-runtime',scenarios:cases.length,proposalSha256:hash(read('changes/p99-conversion-ambient.json')),manifestSha256:hash(read('changes/p99-conversion-ambient/runtime-assertions.json')),passed:true},null,2)+'\n');
});
test('Pinned evidence, composed receivers and exact patrol adaptation stay bound',()=>{
 for(const e of JSON.parse(read('changes/p99-conversion-ambient/runtime-evidence.json')))assert.equal(hash(read(e.path)),e.sha256,e.path);
 for(const e of JSON.parse(read('changes/p99-conversion-ambient/wiki-evidence.json')))assert.equal(hash(read(e.cachePath)),e.sha256,e.cachePath);
 const extensions=JSON.parse(read('changes/p99-conversion-ambient/authorized-extensions.json')).rows;
 assert.equal(extensions.length,7);
 for(const e of extensions){assert.equal(hash(read(e.sourceFile)),e.sourceSha256);assert.equal(e.originalReview.originalEnabled,1);assert.match(read(e.sourceFile),/sub EVENT_SIGNAL/);}
 const p=JSON.parse(read('changes/p99-conversion-ambient.json'));
 assert.ok(!p.rows.some(r=>r.after.name.startsWith('Guard_')),'Receivers already belong to existing flavor proposal');
 const updates=JSON.parse(read('changes/p99-conversion-ambient/guard-scope-updates.json'));
 const owner=JSON.parse(read('changes/p99-conversions-velious-flavor.json'));
 for(const u of updates){const body=read(u.existingSource);assert.equal(hash(body),u.updatedProposedSha256);assert.equal(hash(body.replace(/^-- actors: world\n/,'')),u.previousProposedSha256);assert.equal(owner.rows.find(r=>r.after.zone+'/'+r.after.name===u.key).after.lua_content,body);assert.equal(owner.sources.find(s=>s.proposedFile===u.existingSource).afterSha256,u.updatedProposedSha256);}
 const evidence=JSON.parse(read('changes/p99-conversion-ambient/identity-and-path-evidence.json'));
 const grid=evidence.grid.find(r=>r.zoneid===115&&r.id===30);assert.equal(grid.type,0);assert.equal(grid.type2,1);
 const points=evidence.gridEntries.filter(r=>r.zoneid===115&&r.gridid===30).sort((a,b)=>a.number-b.number);
 assert.deepEqual(points.map(p=>p.number),Array.from({length:24},(_,i)=>i+1));assert.equal(points[14].pause,270);
 assert.equal(evidence.spawn2.find(r=>r.id===25629).pathgrid,30);
 const source=read('sources/projecteq/thurgadina/Lieutenant_Ulfur.pl');const lua=read('changes/p99-conversion-ambient/thurgadina/Lieutenant_Ulfur.lua');
 assert.deepEqual([...lua.matchAll(/eq\.signal\((\d+), 0\)/g)].map(x=>x[1]),[...source.matchAll(/quest::signal\((\d+)\)/g)].map(x=>x[1]));
 const review=JSON.parse(read('changes/p99-conversion-ambient/closure-review.json'));assert.equal(review.proposalSha256,hash(read(review.proposal)));assert.equal(review.records.length,34);
});
