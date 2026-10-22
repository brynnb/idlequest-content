// Isolated strict mock tests only. Does not execute the game bridge or inventory settlement.
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import assert from 'node:assert/strict';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const sha=s=>createHash('sha256').update(s).digest('hex');
const manifest='changes/p99-armor-review/runtime-assertions.json';
const records=JSON.parse(read(manifest));
const setup=read('tools/p99-test-fixture.lua')+'\npackage.preload["items"]=function()\n'+read('sources/projecteq/lua_modules/items.lua')+'\nend\n';
assert.equal(read('effective/modules/items.lua'),read('sources/projecteq/lua_modules/items.lua'));
const cases=records.map(r=>{const file=r.proposedFile??r.file;const source=read(file);assert.equal(sha(source),r.sourceSha256,r.name);return {name:r.name,source,setup:setup+'\n'+(r.setupExtra??''),assertions:r.assertions};});
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'p99-armor-test-'));
try {
 const runner=path.join(tmp,'runner');
 const go=process.env.P99_GO??'/tmp/p99-go-toolchain/go/bin/go';
 const env={...process.env,GOCACHE:process.env.GOCACHE??'/tmp/p99-go-cache',GOPATH:process.env.GOPATH??'/tmp/p99-go-path'};
 execFileSync(go,['build','-o',runner,'../tools/p99-lua-runner.go'],{cwd:path.join(root,'validator'),env,encoding:'utf8'});
 const output=execFileSync(runner,[],{input:JSON.stringify(cases),encoding:'utf8',maxBuffer:4*1024*1024});
 assert.equal(output.trim().split('\n').length,cases.length);
 fs.writeFileSync(path.join(root,'changes/p99-armor-review/runtime-receipt.log'),output);
 const inputs=['tools/p99-lua-runner.go','tools/p99-test-fixture.lua','sources/projecteq/lua_modules/items.lua','effective/modules/items.lua','validator/go.mod','validator/go.sum',...fs.readdirSync(path.join(root,'validator/questluasource')).filter(p=>p.endsWith('.go')).map(p=>'validator/questluasource/'+p),manifest];
 fs.writeFileSync(path.join(root,'changes/p99-armor-review/runtime-receipt.json'),JSON.stringify({kind:'isolated-script-behavior-not-game-runtime',completedAt:new Date().toISOString(),command:'node changes/p99-armor-review/run-tests.mjs',goVersion:execFileSync(go,['version'],{encoding:'utf8'}).trim(),scenarios:records.length,passed:records.length,baselineVerificationCases:records.filter(r=>r.coverageKind==='baseline_verification').length,proposedSourceCases:records.filter(r=>r.coverageKind==='proposed_source').length,inputHashes:inputs.map(file=>({file,sha256:sha(read(file))})),cases:records.map(r=>({name:r.name,file:r.proposedFile??r.file,sourceSha256:r.sourceSha256,coverageKind:r.coverageKind})),limits:['Uses pinned Normalize and real unchanged items.lua with strict capture mocks, not the actual game bridge.','No inventory settlement, rollback, world activation, acquisition, persistent multiquest, rendered UI or full-chain proof.','Retained numeric XP/faction values are regression expectations, not documented P99 measurements.']},null,2)+'\n');
 console.log(JSON.stringify({passed:records.length,receipt:'changes/p99-armor-review/runtime-receipt.json'}));
} finally {fs.rmSync(tmp,{recursive:true,force:true});}
