import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
test('452 missing-Lua inventory keys have exactly one owned disposition',()=>{
 const expected=read('changes/p99-audit/missing-lua-triage.json').map(x=>x.key);
 const groups=[
 ['classic',read('changes/p99-classic-conversions/triage.json').records],
 ['special-events',read('changes/p99-audit/manual-event-dispositions.json')],
 ['linked',read('changes/p99-audit/manual-linked-dispositions.json')],
 ['velious',read('changes/p99-conversions-velious/remaining-dispositions.json').records]];
 const seen=new Map();
 for(const [group,rows] of groups) for(const row of rows) {assert(!seen.has(row.key),`overlap ${row.key}: ${seen.get(row.key)} / ${group}`);seen.set(row.key,group);}
 assert.equal(expected.length,452);assert.equal(seen.size,452);
 assert.deepEqual([...seen.keys()].sort(),[...expected].sort());
 assert.equal(groups[3][1].length,200);
 console.log(groups.map(([name,rows])=>name+': '+rows.length).join(', '));
});
