// Focused source-bound mocked VM tests. Does not modify baseline or central suite.
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const digest=s=>createHash('sha256').update(s).digest('hex');
const setup=read('tools/p99-test-fixture.lua')+'\npackage.preload["items"]=function()\n'+read('sources/projecteq/lua_modules/items.lua')+'\nend\n';
const manifest=JSON.parse(read('changes/p99-conversion-trades/runtime-assertions.json'));
const cases=manifest.map(c=>{const source=read(c.proposedFile);assert.equal(digest(source),c.sourceSha256);return {name:c.name,source,setup:setup+'\n'+(c.setupExtra||''),assertions:c.assertions}});
const proposal=JSON.parse(read('changes/p99-conversion-trades.json'));
const review=JSON.parse(read('changes/p99-conversion-trades/closure-review.json'));
assert.equal(review.records.length,16);assert.equal(proposal.rows.length,8);assert.equal(proposal.sources.length,8);
for(const r of review.records){assert.equal(digest(read(r.sourcePerl)),r.sourcePerlSha256);for(const e of r.evidence)if(e.path)assert.equal(digest(read(e.path)),e.sha256);for(const a of r.staticIdentityExpectations){assert.equal(digest(read(a.path)),a.fileSha256);const row=read(a.path).trim().split('\n').map(JSON.parse).find(x=>x.id===a.npcId);assert.equal(row.name,a.name);assert.equal(row.exclude,a.exclude);}}
for(const r of proposal.rows){assert.equal(r.table,'quests');assert.equal(r.before.enabled,r.after.enabled);assert.ok(!r.before.lua_content);const target=r.after.zone+'/'+r.after.name;const original=JSON.parse(JSON.stringify(r.after));original.lua_content=r.before.lua_content;original.has_say_event=r.before.has_say_event;assert.deepEqual(original,r.before);const s=proposal.sources.find(s=>s.target==='maintained/lua/converted-perl/'+target+'.lua');assert.equal(s.beforeSha256,null);assert.equal(r.after.lua_content,read(s.proposedFile));assert.equal(digest(read(s.proposedFile)),s.afterSha256);}
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'p99-trades-test-'));
let output;
try{const binary=path.join(tmp,'runner');execFileSync('go',['build','-o',binary,'../tools/p99-lua-runner.go'],{cwd:path.join(root,'validator'),encoding:'utf8'});output=execFileSync(binary,[],{input:JSON.stringify(cases),encoding:'utf8',maxBuffer:4*1024*1024});}finally{fs.rmSync(tmp,{recursive:true,force:true})}
assert.equal(output.trim().split('\n').length,cases.length);process.stdout.write(output);
fs.writeFileSync(path.join(root,'changes/p99-conversion-trades/behavior-receipt.json'),JSON.stringify({kind:'isolated-script-behavior-not-game-runtime',completedAt:new Date().toISOString(),scenarios:cases.length,staticChecks:'16 original SHA bindings; cached evidence; exact actor IDs/names/exclusion; eight full before/after rows, flags and source hashes',proposalSha256:digest(read('changes/p99-conversion-trades.json')),cases:manifest.map(({name,proposedFile,sourceSha256})=>({name,file:proposedFile,sourceSha256}))},null,2)+'\n');
