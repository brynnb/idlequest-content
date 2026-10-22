import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {sourceEnabled} from '../../tools/source-policy.mjs';
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const p=JSON.parse(fs.readFileSync(new URL('../p99-support-world-scope.json',import.meta.url)));
const assignment=JSON.parse(fs.readFileSync(new URL('./assignment.json',import.meta.url))).records;
const byKey=new Map(assignment.map(r=>[r.key,r]));
const facts=JSON.parse(fs.readFileSync(new URL('./world-scope-dispositions.json',import.meta.url))).records;
const sourceByTarget=new Map(p.sources.map(s=>[s.target,s]));
test('source-only later scope: all36 exact historical bodies retained; row/header admission agree',()=>{
 assert.equal(p.rows.length,36);assert.equal(p.sources.length,36);assert.equal(facts.length,36);
 for(const c of p.rows){
  assert.equal(c.table,'quests');assert.equal(c.before.enabled,1);assert.equal(c.after.enabled,0);
  const k=c.before.zone+'/'+c.before.name,r=byKey.get(k),f=facts.find(r=>r.key===k),source=sourceByTarget.get(f.target);
  assert.ok(r,k);assert.equal(sha(c.before.lua_content),r.currentSourceSha256,k);
  assert.deepEqual({...c.after,enabled:1,lua_content:c.before.lua_content},c.before,k);
  assert.equal(c.after.lua_content.split('\n')[0],'-- enabled: false');
  assert.equal(c.after.lua_content.split('\n').slice(2).join('\n'),c.before.lua_content,k);
  assert.equal(sourceEnabled(c.after.lua_content),false,k);
  assert.equal(sha(c.after.lua_content),source.afterSha256,k);
  assert.equal(fs.readFileSync(source.proposedFile,'utf8'),c.after.lua_content,k);
  assert.equal(f.currentSourceSha256,source.afterSha256,k);assert.equal(f.baselineSourceSha256,r.currentSourceSha256,k);
 }
});
test('all314 effect support keys covered once;217 full-body representatives, no name-only parity',()=>{
 const report=JSON.parse(fs.readFileSync(new URL('./world-effect-review.json',import.meta.url)));
 assert.equal(report.records.length,314);assert.equal(new Set(report.records.map(r=>r.key)).size,314);
 assert.equal(new Set(report.records.map(r=>r.reviewedSourceSha256)).size,217);
 for(const r of report.records){assert.ok(r.behaviorSummary);assert.ok(r.disposition);assert.ok(r.limitations.length);assert.equal(r.reviewMethod,'complete_body_human_read_of_exact_hash_representative');assert.equal(byKey.get(r.key).currentSourceSha256,r.reviewedSourceSha256)}
});
test('two mixed classic guards retain full combat bodies and validated four-case fixture hashes',()=>{
 const mixed=JSON.parse(fs.readFileSync(new URL('../p99-support-mixed-hints.json',import.meta.url)));
 const result=JSON.parse(fs.readFileSync(new URL('./mixed-hint-tests.json',import.meta.url)));
 assert.equal(mixed.rows.length,2);assert.equal(result.passed,true);assert.equal(result.cases.length,4);
 for(const c of mixed.rows){
  assert.deepEqual({...c.after,lua_content:c.before.lua_content,has_say_event:c.before.has_say_event},c.before);assert.equal(c.after.has_say_event,0);
  const originalCombat=c.before.lua_content.slice(c.before.lua_content.indexOf('function event_combat(e)'));
  assert.equal(c.after.lua_content.split('\n').slice(1).join('\n'),originalCombat);
  assert.equal(sourceEnabled(c.after.lua_content),true);assert.equal(c.after.enabled,1);
  assert.equal(result.cases.filter(t=>t.Name.startsWith(c.after.name+' ')&&t.Source===c.after.lua_content).length,2);
  assert.equal(c.after.lua_content.includes('function event_say'),false);
 }
});
test('mixed ocean correction preserves all classic strongbox bytes and four-case source bindings',()=>{
 const p=JSON.parse(fs.readFileSync(new URL('../p99-support-ocean-fishing-scope.json',import.meta.url)));
 const result=JSON.parse(fs.readFileSync(new URL('./ocean-fishing-tests.json',import.meta.url)));
 const r=p.rows[0];assert.equal(p.rows.length,1);assert.equal(p.sources.length,1);
 assert.deepEqual({...r.after,lua_content:r.before.lua_content},r.before);
 assert.equal(r.after.lua_content.split('\n').slice(1).join('\n'),r.before.lua_content.split('function event_fish_success(e)')[0]);
 assert.equal(sourceEnabled(r.after.lua_content),true);assert.equal(r.after.enabled,1);
 assert.equal(result.cases.length,4);assert.equal(result.passed,true);
 for(const c of result.cases)assert.equal(c.Source,r.after.lua_content);
 assert.equal(r.after.lua_content.includes('function event_fish_success'),false);
});
