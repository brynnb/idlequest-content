import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
test('Classic triage covers every assigned unlinked exact key and immutable source',()=>{
 const inventory=read('changes/p99-audit/inventory.json');
 const zones=read('changes/p99-audit/p99_zones.json');
 const assignment=read('changes/p99-classic-conversions/assigned-keys.json');
 assert.equal(crypto.createHash('sha256').update(fs.readFileSync('changes/p99-classic-conversions/assigned-keys.json')).digest('hex'),'95a08ff78204e1adc5164563d4ff5c4ab65b83eb8182584bea6abcd7a7c63652');
 const report=read('changes/p99-classic-conversions/triage.json');
 assert.equal(crypto.createHash('sha256').update(fs.readFileSync(assignment.originalReviewFile)).digest('hex'),assignment.originalReviewSha256);
 checkAssignments(assignment.assignments,report.records,inventory.perl,zones);
 checkAssignments(assignment.assignments,report.records,inventory.perl,[...zones].reverse());
 for(const r of report.records){
  assert.ok(r.reviewClassification&&!r.reviewClassification.startsWith('needs-manual'));
  assert.ok(r.decision&&r.verification);
  assert.equal(crypto.createHash('sha256').update(fs.readFileSync(r.file)).digest('hex'),r.sha256);
  if(r.reviewClassification==='identity-alias-existing-lua'){
   assert.equal(r.maintainedAliasSources.length,1);
   assert.ok(fs.readFileSync(r.maintainedAliasSources[0],'utf8').includes('-- name: '+r.canonicalKey.split('/')[1]));
  }
 }
});
test('Six exact missing-Lua keys retain original enabled state and new source preimages',()=>{
 const p=read('changes/p99-classic-conversions/proposal.json');
 assert.equal(p.rows.length,6);assert.equal(p.sources.length,6);
 for(const row of p.rows){assert.equal(row.before.lua_content,null);assert.equal(row.before.enabled,row.after.enabled);assert.equal(row.before.name,row.after.name);}
 for(const s of p.sources){assert.equal(s.beforeSha256,null);assert.equal(fs.existsSync(s.target),false);assert.equal(crypto.createHash('sha256').update(fs.readFileSync(s.proposedFile)).digest('hex'),s.afterSha256);}
});

function checkAssignments(assignments,records,inventory,zones) {
 assert.equal(assignments.length,181);assert.equal(records.length,181);
 const unique=list=>{const keys=list.map(r=>r.key);assert.equal(new Set(keys).size,keys.length,'Duplicate assignment/review keys');return new Map(list.map(r=>[r.key,r]));};
 const expected=unique(assignments),actual=unique(records);assert.deepEqual([...actual.keys()].sort(),[...expected.keys()].sort());
 const zoneSet=new Set(zones),baseline=new Map(inventory.map(r=>[r.key,r]));
 for(const [key,assignment]of expected){
  const original=baseline.get(key),review=actual.get(key);assert.ok(original,`Unknown original key: ${key}`);
  assert.equal(original.classification,'unlinked-missing-lua-review');assert.ok(zoneSet.has(assignment.zone));
  for(const field of ['zone','file','sha256']){assert.equal(assignment[field],original[field],`Stale original ${field}: ${key}`);assert.equal(review[field],assignment[field],`Stale reviewed ${field}: ${key}`);}
 }
}
test('Classic explicit assignments fail unknown, duplicate, omitted and stale bindings',()=>{
 const a=read('changes/p99-classic-conversions/assigned-keys.json').assignments,r=read('changes/p99-classic-conversions/triage.json').records,i=read('changes/p99-audit/inventory.json').perl,z=read('changes/p99-audit/p99_zones.json');
 for(const mutate of [x=>x.pop(),x=>x[1]=x[0],x=>x[0].key='unknown/actor',x=>x[0].sha256='0'.repeat(64)]){
  const changed=structuredClone(a);mutate(changed);assert.throws(()=>checkAssignments(changed,r,i,z));
 }
 const omitted=structuredClone(r);omitted.pop();assert.throws(()=>checkAssignments(a,omitted,i,z));
 const duplicated=structuredClone(r);duplicated[1]=duplicated[0];assert.throws(()=>checkAssignments(a,duplicated,i,z));
 const unknownA=structuredClone(a),unknownR=structuredClone(r);unknownA[0].key=unknownR[0].key='unknown/actor';assert.throws(()=>checkAssignments(unknownA,unknownR,i,z));
 const stale=structuredClone(r);stale[0].sha256='0'.repeat(64);assert.throws(()=>checkAssignments(a,stale,i,z));
});
