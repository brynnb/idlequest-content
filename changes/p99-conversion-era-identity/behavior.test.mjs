import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {buildBidilsCases,buildRuntimeAssertions,setupExtra} from './runtime-cases.mjs';
const root=path.resolve(import.meta.dirname,'../..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const hash=s=>createHash('sha256').update(s).digest('hex');
const load=p=>JSON.parse(read(p));
const base='changes/p99-conversion-era-identity';
const report=load(base+'/closure-review.json');
const data=load(base+'/data-evidence.json');
const proposal=load('changes/p99-conversion-era-identity.json');
test('All 25 exact sources and complete evidence records are hash-bound, with no baseline overwrite',()=>{
 const assigned=load('changes/p99-conversion-closure/assignments.json').assignments.root_era_identity;
 assert.equal(assigned.length,25);assert.equal(report.records.length,25);
 assert.deepEqual(report.records.map(r=>r.key).sort(),assigned.map(r=>r.key).sort());
 assert.deepEqual(report.counts,{positively_later:21,true_runtime_block:2,event_scope_exclusion:1,converted_full:1});
 assert.equal(report.baselineManifestSha256,hash(read('manifest.json')));
 assert.equal(report.proposalSha256,hash(read('changes/p99-conversion-era-identity.json')));
 for(const a of assigned) assert.equal(hash(read(a.source)),a.sha256,a.key);
 for(const r of report.records){assert.equal(hash(read(r.sourcePerl)),r.sourcePerlSha256);assert.equal(r.fullSourceReviewed,true);for(const b of r.sourceDependencies)assert.equal(hash(read(b.path)),b.sha256);}
 for(const b of report.inputBindings)assert.equal(hash(read(b.path)),b.sha256);
 const evidence=load(base+'/external-evidence.json');
 for(const b of [...evidence.evidence,...evidence.runtimeEvidence]) if(b.path) assert.equal(hash(read(b.path)),b.sha256,b.path);
 const byFile=new Map();
 for(const category of Object.values(data)) if(Array.isArray(category))for(const r of category){
  if(!byFile.has(r.path))byFile.set(r.path,{hash:hash(read(r.path)),lines:read(r.path).trimEnd().split('\n')});
  const f=byFile.get(r.path);assert.equal(f.hash,r.fileSha256);assert.deepEqual(JSON.parse(f.lines[r.line-1]),r.row);
  // Python's lexical key order is replicated explicitly, not locale collation.
  const ordered={};for(const k of Object.keys(r.row).sort())ordered[k]=r.row[k];
  assert.equal(hash(JSON.stringify(ordered)),r.rowSha256,r.path+':'+r.line);
 }
 assert.equal(proposal.rows.length,1);assert.equal(proposal.sources.length,1);
 const q=proposal.rows[0];assert.deepEqual(q.before,data.quests.find(x=>x.row.id===14079).row);assert.equal(q.after.enabled,q.before.enabled);assert.equal(q.after.id,14079);
 for(const s of proposal.sources){assert.equal(hash(read(s.proposedFile)),s.afterSha256);assert.equal(q.after.lua_content,read(s.proposedFile));assert.equal(s.beforeSha256,null);assert.equal(fs.existsSync(path.join(root,s.target)),false);}
});
test('Era and event closures follow exact caller, loot, spell and scoped placement identities',()=>{
 const npc=id=>data.npcTypes.find(x=>x.row.id===id).row;
 assert.equal(npc(127105).name,'Flighty_Viridian_Wisp');assert.equal(npc(127105).loottable_id,89865);
 assert.ok(data.loottableEntries.some(x=>x.row.loottable_id===89865&&x.row.lootdrop_id===89869));assert.ok(data.lootdropEntries.some(x=>x.row.lootdrop_id===89869&&x.row.item_id===52361));
 assert.equal(npc(48209).loottable_id,14203);assert.ok(data.lootdropEntries.some(x=>x.row.lootdrop_id===22597&&x.row.item_id===8723));
 assert.deepEqual(data.lootdropEntries.filter(x=>x.row.lootdrop_id===22598).map(x=>x.row.item_id).sort((a,b)=>a-b),[27851,27853,27859,27874,27883,27888,27908,27913]);
 assert.equal(data.spells.find(x=>x.row.id===11658).row.name,'Blood Curse Antidote');
 const jack=report.records.find(r=>r.key==='kithicor/#a_jack_o_lantern');assert.equal(jack.status,'event_scope_exclusion');assert.equal(jack.spawnIds.length,19);
 for(const x of data.spawn2.filter(x=>jack.spawnIds.includes(x.row.id)))assert.equal(x.row.content_flags,'peq_halloween');
 assert.match(read('reference/p99-wiki/npc-pages/a-jack-o-lantern-7557ccf292.wiki'),/The Estate of Unrest/);
 const sharks=read('sources/projecteq/cobaltscar/Yoppa_Greenthumb.lua');assert.match(sharks,/Shaman Epic 1\.5/);for(const id of [117089,117090,117091])assert.ok(sharks.includes('eq.spawn2('+id+','));
 for(const r of report.records.filter(r=>r.status!=='converted_full'))assert.equal(r.proposedFile,null);
 // Verify dispositions and public identity rows only. This does not retest private runtime compatibility.
 assert.equal(npc(110115).name,'#_#_6');for(const key of ['iceclad/110115','nro/#_#_5'])assert.equal(report.records.find(r=>r.key===key).status,'true_runtime_block');
});
test('All Bidils dialogue branches, repeat/case/unknown speech and safe refunds: isolated Lua only',t=>{
 const source=read(proposal.sources[0].proposedFile), expected=load(base+'/dialogue-expectations.json');
 assert.equal(expected.length,14);assert.equal((read('sources/projecteq/misty/Bidils_the_Quickhand.pl').match(/if\(\$text=~\//g)||[]).length,14);
 const fixture=read('tools/p99-test-fixture.lua')+'\n'+setupExtra+'package.preload["items"]=function()\n'+read('sources/projecteq/lua_modules/items.lua')+'\nend\n';
 const manifest=load(base+'/runtime-assertions.json');
 assert.deepEqual(manifest,buildRuntimeAssertions({expected,proposedFile:proposal.sources[0].proposedFile,source}));
 assert.equal(manifest.length,17);
 const cases=buildBidilsCases(expected).map(c=>({...c,source,setup:fixture}));
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'p99-era-identity-'));t.after(()=>fs.rmSync(dir,{recursive:true,force:true}));const binary=path.join(dir,'runner');
 const go=process.env.P99_GO_BINARY || (fs.existsSync('/tmp/p99-go-toolchain/go/bin/go') ? '/tmp/p99-go-toolchain/go/bin/go' : 'go');
 execFileSync(go,['build','-o',binary,'../tools/p99-lua-runner.go'],{cwd:path.join(root,'validator'),env:{...process.env,GOCACHE:'/tmp/p99-go-cache',GOPATH:'/tmp/p99-go-path'},encoding:'utf8'});
 const log=execFileSync(binary,[],{input:JSON.stringify(cases),encoding:'utf8',maxBuffer:5*1024*1024});assert.equal(log.trim().split('\n').length,cases.length);
 fs.writeFileSync(path.join(root,base,'isolated-test.log'),log);
 // Match the central loader's full fixture plus setupExtra arrangement. Never embed
 // the standalone fixture in the manifest: its early race extension would be stripped.
 const centralSetup=read('tools/p99-test-fixture.lua')+'\npackage.preload["items"]=function()\n'+read('sources/projecteq/lua_modules/items.lua')+'\nend\n';
 const centralCases=manifest.map(r=>({name:r.name,source:read(r.proposedFile),setup:centralSetup+'\n'+r.setupExtra,assertions:r.assertions}));
 const centralLog=execFileSync(binary,[],{input:JSON.stringify(centralCases),encoding:'utf8',maxBuffer:5*1024*1024});
 assert.equal(centralLog.trim().split('\n').length,manifest.length);
 fs.writeFileSync(path.join(root,base,'central-integration-test.log'),centralLog);
 fs.writeFileSync(path.join(root,base,'test-receipt.json'),JSON.stringify({kind:'isolated-script-logic-not-game-settlement',scenarios:cases.length,centralIntegrationScenarios:centralCases.length,runtimeAssertionsSha256:hash(read(base+'/runtime-assertions.json')),caseBuilderSha256:hash(read(base+'/runtime-cases.mjs')),dialogueExpectationsSha256:hash(read(base+'/dialogue-expectations.json')),closureReviewSha256:hash(read(base+'/closure-review.json')),dataEvidenceSha256:hash(read(base+'/data-evidence.json')),externalEvidenceSha256:hash(read(base+'/external-evidence.json')),proposalSha256:hash(read('changes/p99-conversion-era-identity.json')),testSha256:hash(read(base+'/behavior.test.mjs')),sourceSha256:hash(source),passed:true,unverified:['live runtime transactions','natural NPC availability','GM-event reward progression','boat registration and transport','rendered UI']},null,2)+'\n');
});
