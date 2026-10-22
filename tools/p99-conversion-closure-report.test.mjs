import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import {inspectPublicText} from './p99-public-safety.mjs';
import {buildReport, classifyNoLua, BUCKETS, renderMarkdown} from './p99-conversion-closure-report.mjs';
const root=new URL('../',import.meta.url).pathname;
const row=(key,label,policy=null)=>({key,originalDisposition:{record:{classification:label}},originalPolicy:policy});
test('policy is not automatically positive era evidence; aliases and genuine quest blockers remain distinct',()=>{
 assert.equal(classifyNoLua(row('eastwastes/Nelef_the_Trader','explicit-quest-exclusion',{reason:'post_kunark_later_era'})),BUCKETS[3]);
 assert.equal(classifyNoLua(row('templeveeshan/#Vulak-Aerr','explicit-quest-exclusion',{reason:'p99_replaced_spawn_cycle'})),BUCKETS[2]);
 assert.equal(classifyNoLua(row('wakening/Shamus_Aghllsews','explicit-quest-exclusion')),BUCKETS[4]);
 assert.equal(classifyNoLua(row('cazicthule/#Avatar_of_Dread','later-revamp-encounter-reference')),BUCKETS[6]);
});
test('transport and world contracts are not relabeled reward quest blockers',()=>{
 assert.equal(classifyNoLua(row('iceclad/110115','x'),{status:'true_runtime_block'}),BUCKETS[5]);
 assert.equal(classifyNoLua(row('kael/a_bag_of_supplies','x'),{status:'true_runtime_block'}),BUCKETS[4]);
 assert.equal(classifyNoLua(row('charasis/player','x'),{finalDisposition:'blocked_conflicting_classic_key_contract'}),BUCKETS[5]);
 assert.equal(classifyNoLua(row('lfaydark/Kalayia_Woodwhisper','x'),{finalDisposition:'blocked_missing_authored_classic_route'}),BUCKETS[5]);
});
test('unknown or stale conversion state fails closed rather than becoming generic unresolved',()=>{
 assert.throws(()=>classifyNoLua(row('zone/test','unknown')),/Unclassified/);
 assert.throws(()=>classifyNoLua(row('zone/test','x'),{status:'converted_full'}),/refresh resolution-report/);
});
test('499 rows reconcile with 124 original assignments plus 3 authorized extensions',async()=>{
 const r=await buildReport(root),c=r.counts;
 assert.equal(r.rows.length,499);assert.equal(new Set(r.rows.map(x=>x.key)).size,499);
 assert.equal(c.nowLua+c.noLua,499);assert.equal(c.enabledLua+c.disabledLua,c.nowLua);
 assert.equal(Object.values(c.noLuaBuckets).reduce((a,b)=>a+b,0),c.noLua);
 assert.equal(c.initialAssignments,124);assert.equal(c.authorizedExtensionRows,3);
 assert.equal(c.priorNowLua,73);assert.equal(c.assignedNowLua,51);assert.equal(c.extensionNowLua,3);
 assert.equal(c.nowLua,127);assert.equal(c.enabledLua,123);assert.equal(c.disabledLua,4);assert.equal(c.noLua,372);
 assert.deepEqual(r.assignmentGroups.map(g=>g.originalAssignments),[16,34,49,25]);
 assert.equal(r.rows.filter(x=>x.conversionScope==='partial_flavor_or_refund_only').length,6);
 assert.equal(r.rows.filter(x=>x.assignmentGroup==='world'&&x.noLuaBucket===BUCKETS[5]).length,12);
 assert.equal(r.rows.filter(x=>x.assignmentGroup==='world'&&x.noLuaBucket===BUCKETS[6]).length,3);
 assert.equal(r.rows.filter(x=>x.assignmentGroup==='ambient'&&x.noLuaBucket===BUCKETS[5]).length,12);
 assert.equal(r.retainedQuestFamilies.length,4);
 assert.ok(r.rows.every(x=>x.originalSourceSha256&&x.originalDisposition.artifact));
 for(const x of r.rows.filter(x=>!x.hasLua))assert.ok(BUCKETS.includes(x.noLuaBucket));
 const saved=JSON.parse(await fs.readFile(new URL('../changes/p99-audit/conversion-closure-report.json',import.meta.url)));
 assert.deepEqual(saved,r,'Regenerate closure after changing bound inputs');
 assert.equal(await fs.readFile(new URL('../changes/p99-audit/conversion-closure-report.md',import.meta.url),'utf8'),renderMarkdown(r));
});

test('authored report and generator have no known publication safety violations',async()=>{
 for(const p of ['tools/p99-conversion-closure-report.mjs','tools/p99-conversion-closure-report.test.mjs','changes/p99-audit/conversion-closure-report.json','changes/p99-audit/conversion-closure-report.md'])assert.deepEqual(inspectPublicText(await fs.readFile(new URL('../'+p,import.meta.url),'utf8'),p),[]);
});
