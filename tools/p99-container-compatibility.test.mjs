import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import {buildContainerReview} from './p99-container-compatibility.mjs';

test('recipe audit explicitly reconciles downstream container blocks',async()=>{
 const expected=JSON.parse(await fs.readFile('changes/p99-audit/container-compatibility.json','utf8'));
 const actual=await buildContainerReview('.');assert.deepEqual(actual,expected);
 const evidence=JSON.parse(await fs.readFile('changes/p99-audit/runtime-container-evidence.json','utf8'));
 assert.ok(evidence.blockedRecipeIds.every(id=>evidence.reviewedRecipeIds.includes(id)));
 assert.equal(evidence.schemaVersion,2);
 assert.match(actual.evidenceBasis,/not independently reproducible/);
 assert.ok(!('relevantDefinitions' in evidence));
 assert.ok(actual.records.every(r=>!('paths' in r)));
 assert.equal(actual.records.length,actual.counts.recipes);
 assert.equal(actual.counts.downstreamStaticBlocks+actual.counts.registeredPathsOnly,actual.counts.recipes);
 assert.ok(actual.records.every(r=>r.disposition!=='verified_playable'));
 assert.match(actual.limits.join(' '),/separate authorized change/);
});
