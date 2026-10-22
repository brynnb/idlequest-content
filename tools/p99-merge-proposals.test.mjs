import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mergeProposals} from './p99-merge-proposals.mjs';
const p=(id,row,sources=[])=>({format:1,id,baseManifestSha256:'a'.repeat(64),evidence:[{url:'https://wiki.project1999.com/Test',note:id}],rows:row?[{table:'quests',before:{id:1,name:'x'},after:{id:1,name:row}}]:[],sources});
test('P99 proposal merge preserves preimages and rejects conflicts',()=>{
 const a=p('a','fixed'), b=p('b','fixed');
 assert.equal(mergeProposals([a,b]).rows.length,1);
 assert.equal(mergeProposals([a,b]).evidence.length,2);
 assert.throws(()=>mergeProposals([a,p('c','other')]),/Conflicting row/);
 assert.throws(()=>mergeProposals([a,{...b,baseManifestSha256:'b'.repeat(64)}]),/Baseline mismatch/);
 assert.throws(()=>mergeProposals([]),/No proposals/);
 assert.throws(()=>mergeProposals([p('a',null,[{target:'same',afterSha256:'a'}]),p('b',null,[{target:'same',afterSha256:'b'}])]),/Conflicting source/);
});
