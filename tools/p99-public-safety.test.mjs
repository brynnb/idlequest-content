import test from 'node:test';
import assert from 'node:assert/strict';
import {inspectPublicText,scanPublication} from './p99-public-safety.mjs';

test('public-safety guard rejects private repositories, copied source and embedded archives',()=>{
 const privateUrl='https://github.com/brynnb/'+'idlequest/blob/revision/example';
 assert.equal(inspectPublicText(privateUrl).length,1);
 assert.equal(inspectPublicText('https://github.com/brynnb/idlequest-content').length,0);
 assert.ok(inspectPublicText('package '+'world\n').length);
 assert.ok(inspectPublicText('{"'+'relevantDefinitions'+'":[]}').length);
 assert.ok(inspectPublicText('', 'changes/p99-audit/example.tar.gz').length);
 assert.equal(inspectPublicText('reference/server/internal/quest/lua_bridge.go').length,0);
});
test('all publication-bound authored files pass the public-safety gate',async()=>{
 const report=await scanPublication('.');
 assert.ok(report.filesScanned>100);
 assert.deepEqual(report.findings,[]);
 assert.equal(report.passed,true);
});
