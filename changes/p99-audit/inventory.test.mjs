import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {upstreamIdentity,resolveCacheMember,verifyPage,inventory} from '../../tools/p99-quest-inventory.mjs';
import {fileURLToPath} from 'node:url';
import fs from 'node:fs/promises';

test('root/v0 retain exact zone and hash/numeric identity; later versions are not imported',()=>{
 assert.deepEqual(upstreamIdentity('droga/v0/#a_goblin.pl'),{key:'droga/#a_goblin',zone:'droga',version:'v0',eligible:true});
 assert.equal(upstreamIdentity('droga/v1/123.lua').eligible,false);
 assert.equal(upstreamIdentity('thurgadinb/2000965.lua').key,'thurgadinb/2000965');
 assert.equal(upstreamIdentity('lua_modules/items.lua'),null);
});
test('historical absolute cache paths resolve safely under preserved cache',()=>{
 assert.equal(resolveCacheMember('/removed/worktree/raw-pages/example.wiki','wiki'),'raw-pages/example.wiki');
 assert.throws(()=>resolveCacheMember('../secrets.json','json'));
 assert.throws(()=>resolveCacheMember('raw-pages/../secrets.json','json'));
});
test('all page integrity dimensions fail closed; fetched candidates are valid cache records',()=>{
 const bytes=Buffer.from('sample'),meta={title:'Example',bytes:6,sha256:createHash('sha256').update(bytes).digest('hex')};
 for(const status of ['cached','fetched']) assert.doesNotThrow(()=>verifyPage('Example',{status},meta,bytes));
 assert.throws(()=>verifyPage('Wrong',{status:'cached'},meta,bytes),/title mismatch/);
 assert.throws(()=>verifyPage('Example',{status:'error'},meta,bytes),/not cached/);
 assert.throws(()=>verifyPage('Example',{status:'cached'},{...meta,bytes:1},bytes),/byte mismatch/);
 assert.throws(()=>verifyPage('Example',{status:'cached'},{...meta,sha256:'bad'},bytes),/hash mismatch/);
});
test('complete exported inventory accounts for corpus, source files and precise identity',async()=>{
 const root=fileURLToPath(new URL('../../',import.meta.url));
 const r=await inventory(root);
 assert.equal(r.pages.length,1135);assert.equal(r.pages.filter(p=>p.corpus==='high-confidence').length,918);
 assert.equal(r.pages.filter(p=>p.corpus==='title-review').length,217);
 assert.equal(r.perl.length,Object.values(r.summary.perlClassifications).reduce((a,b)=>a+b,0));
 assert.equal(r.pageLedger.length,r.summary.ledgerEntries);
 assert.equal(r.provenance.baselineManifest,'manifest.json');
 assert(r.zones.includes('warrens'));assert(r.zones.includes('stonebrunt'));assert(!r.zones.includes('dawnshroud'));
 assert(r.perl.every(p=>p.key&&p.sha256&&p.classification));
 assert.equal(r.summary.allPerlFiles,3753);
 assert.equal(r.missingLuaTriage.length,452);
 assert.equal(r.manualEventDispositions.length,59);
 assert.equal(new Set(r.manualEventDispositions.map(p=>p.key)).size,59);
 const saved=JSON.parse(await fs.readFile(new URL('./inventory.json',import.meta.url),'utf8'));
 assert.deepEqual(r,saved,'Committed report must exactly reproduce from baseline inputs');
});

test('declared audit scope is bound only to public exported zone rows',async()=>{
 const proof=JSON.parse(await fs.readFile('changes/p99-audit/scope-provenance.json'));
 const bytes=await fs.readFile(proof.scopeFile),zones=JSON.parse(bytes);
 assert.equal(createHash('sha256').update(bytes).digest('hex'),proof.scopeSha256);
 assert.equal(proof.zones,121);assert.deepEqual(zones,[...new Set(zones)].sort());
 assert.deepEqual([...new Set(proof.publicZoneRows.map(r=>r.zone))].sort(),zones);
 const shards=new Map();
 for(const record of proof.publicZoneRows){
  assert.match(record.file,/^data\/zone\/[0-9a-f]\.ndjson$/);
  if(!shards.has(record.file))shards.set(record.file,(await fs.readFile(record.file,'utf8')).trimEnd().split('\n'));
  const line=shards.get(record.file)[record.line-1],row=JSON.parse(line);
  assert.equal(createHash('sha256').update(line).digest('hex'),record.rowSha256);
  assert.equal(row.short_name,record.zone);assert.equal(row.id,record.rowId);
  assert.equal(row.zoneidnumber,record.zoneId);assert.equal(row.version,record.version);
 }
});
