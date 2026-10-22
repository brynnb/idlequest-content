import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const dir = 'changes/p99-final-admission/';
const read = file => fs.readFileSync(path.join(root, file));
const json = file => JSON.parse(read(file));
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
const assignment = json(dir + 'assignment.json');
const review = json(dir + 'review.json');
const proposal = json('changes/p99-final-admission.json');
const local = json(dir + 'local-evidence.json');
const cases = json(dir + 'runtime-assertions.json').cases;
const old = json('changes/p99-source-review/review-records.json').records.filter(r => r.disposition === 'later_era_family_or_source_context_preserved_pending_admission_review');
const byKey = new Map(review.records.map(r => [r.key,r]));
const key = row => row.zone + '/' + row.name;

test('exact original 121-row closure, with no hidden extension', () => {
  assert.equal(review.originalCount,121);
  for (const xs of [assignment.records,review.records,local.records]) {
    assert.equal(xs.length,121);assert.equal(new Set(xs.map(r=>r.key)).size,121);
    assert.deepEqual(xs.map(r=>r.key).sort(),old.map(r=>r.key).sort());
  }
  assert.deepEqual(review.additionalRecords,[]);
  assert.equal(sha(read(dir+'assignment.json')),review.assignmentSha256);
  assert.equal(sha(read('changes/p99-source-review/review-records.json')),assignment.sourceReviewSha256);
  assert.deepEqual(review.dispositionCounts,{
    disabled_sole_later_source_body_preserved:110,
    removed_later_branch_preserved_mixed_source:8,
    already_disabled_by_existing_owner:2,
    unchanged_precise_admission_ambiguity:1,
  });
});
test('every reviewed baseline and item/caller evidence stays byte-bound',()=>{
  const itemRefs = local.records.flatMap(r=>r.explicitItemSyntaxReferences);
  const itemFiles = new Map();
  for(const f of new Set(itemRefs.map(i=>i.file)))itemFiles.set(f,new Map(read(f).toString().trim().split('\n').map(line=>{const row=JSON.parse(line);return[row.id,{row,sha256:sha(line)}]})));
  for(const i of itemRefs){const x=itemFiles.get(i.file).get(i.id);assert.equal(x.sha256,i.rowSha256);assert.equal(x.row.Name,i.name);assert.equal(x.row.classes,i.classes);assert.equal(x.row.races,i.races);}
  for(const r of review.records) assert.equal(sha(read(r.baselineFile)),r.baselineSourceSha256,r.key);
  for(const r of local.records) {
    for(const s of [r.source,...r.sourceCallerTraces]) assert.equal(sha(read(s.file)),s.sha256,r.key+': '+s.file);
    for(const l of r.source.matchingLines) assert.equal(read(r.source.file).toString().split(/\r?\n/)[l.line-1].trim(),l.text);
  }
});
test('118 proposal rows have matching hash-bound Lua sources and honest flags',()=>{
  assert.equal(proposal.rows.length,118);assert.equal(proposal.sources.length,118);
  assert.equal(proposal.baseManifestSha256,sha(read('manifest.json')));
  const sourceMap=new Map(proposal.sources.map(s=>[s.proposedFile,s]));
  for(const edit of proposal.rows) {
    assert.equal(edit.table,'quests');assert.equal(key(edit.before),key(edit.after));
    const r=byKey.get(key(edit.after));const src=sourceMap.get(r.proposedFile);
    assert.ok(src);assert.equal(edit.before.lua_content,read(r.baselineFile).toString());
    assert.equal(edit.after.lua_content,read(r.proposedFile).toString());
    assert.equal(sha(read(r.proposedFile)),src.afterSha256);assert.equal(src.afterSha256,r.proposedSourceSha256);
    assert.equal(edit.after.enabled,r.enabled);
    assert.equal(src.beforeSha256,fs.existsSync(path.join(root,src.target))?sha(read(src.target)):null);
    assert.equal(cases.some(c=>c.proposedFile===r.proposedFile&&c.sourceSha256===r.proposedSourceSha256),true,r.key);
    for(const field of Object.keys(edit.before)) if(!['lua_content','enabled','has_say_event'].includes(field))assert.deepEqual(edit.after[field],edit.before[field],r.key+': '+field);
  }
});
test('110 later-only exclusions preserve the entire historical body, not activation proof',()=>{
  const disabled=review.records.filter(r=>r.disposition==='disabled_sole_later_source_body_preserved');
  assert.equal(disabled.length,110);
  for(const r of disabled){
    const bytes=read(r.proposedFile),s=bytes.toString();
    assert.match(s,/^-- enabled: false\n-- P99 source-only scope exclusion: /);assert.equal(r.enabled,0);
    const offset=bytes.indexOf(10,bytes.indexOf(10)+1)+1;
    assert.deepEqual(bytes.subarray(offset),read(r.baselineFile));
    const cs=cases.filter(c=>c.proposedFile===r.proposedFile);
    assert.ok(cs.length);assert.ok(cs.every(c=>c.coverageKind==='disabled_historical_body_load_not_runtime_admission'));
  }
});
test('eight mixed sources remove later state/items but preserve distinct ambient or legacy behavior',()=>{
  const mixed=review.records.filter(r=>r.disposition==='removed_later_branch_preserved_mixed_source');assert.equal(mixed.length,8);
  for(const r of mixed){
    const s=read(r.proposedFile).toString();assert.equal(r.enabled,1);
    assert.doesNotMatch(s,/eq\.(?:set_global|set_timer|task_selector)|IsTaskActive|UpdateTaskActivity|eq\.get_qglobals/);
    assert.match(s,/item_lib\.return_items/);
    assert.ok(cases.filter(c=>c.proposedFile===r.proposedFile).length>=2,r.key);
  }
  for(const [k,note,reward]of[['freportn/Edwardian_Holyblade',18737,13554],['neriakc/Ulraz_S-Lon',18757,13586]]){
    const s=read(byKey.get(k).proposedFile).toString();assert.match(s,new RegExp('item1 = '+note));assert.match(s,new RegExp('SummonItem\\('+reward+'\\)'));assert.match(s,/AddEXP\(100\)/);assert.doesNotMatch(s,/Faction\(/);
  }
  const medron=byKey.get('neriakc/Medron_Y-Lask');const before=read(medron.baselineFile).toString();const original=before.slice(before.indexOf('function event_say(e)'),before.indexOf('function event_trade(e)'));
  assert.ok(read(medron.proposedFile).toString().includes(original),'Medron whole existing event_say retained');
});
test('existing two owners are referenced, never duplicated; ambiguity is explicit and unedited',()=>{
  const edits=new Set(proposal.rows.map(e=>key(e.after)));
  for(const r of review.records.filter(r=>r.disposition==='already_disabled_by_existing_owner')){
    assert.ok(!edits.has(r.key));assert.equal(sha(read(r.proposal)),r.proposalSha256);assert.equal(sha(read(r.proposedFile)),r.proposedSourceSha256);assert.equal(r.enabled,0);
  }
  const r=byKey.get('gfaydark/Mazziana_Ridgerunner');assert.equal(r.disposition,'unchanged_precise_admission_ambiguity');assert.ok(!edits.has(r.key));assert.match(r.reason,/no task ID/);assert.match(r.reason,/actor quest-date\/caller evidence/);
  for(const file of fs.readdirSync(path.join(root,'changes')).filter(f=>f.endsWith('.json')&&f!=='p99-final-admission.json')){
    const p=json('changes/'+file);if(p.format!==1||p.id==='p99-combined-audit')continue;
    for(const row of p.rows??[])if(row.table==='quests')assert.ok(!edits.has(key(row.after??row.before)),'Conflicting owner '+file+': '+key(row.after??row.before));
  }
});
test('runtime manifest is exact-current-source bound with all proposed files covered',()=>{
  assert.equal(cases.length,137);
  assert.equal(new Set(cases.filter(c=>c.proposedFile).map(c=>c.proposedFile)).size,118);
  for(const c of cases){assert.equal(sha(read(c.proposedFile??c.file)),c.sourceSha256,c.name);if(c.file)assert.equal(c.coverageKind,'baseline_verification');}
});
