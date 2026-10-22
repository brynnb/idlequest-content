// Regression values independently supported by the linked reviewed NPC/quest pages.
// This verifies static rows, not actual hand-in/depop scheduling or live admission.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const expected=[
 ['changes/p99-af-nekexin-respawn.json',17803,7200,0],
 ['changes/p99-nz-eldreth-respawn.json',7119,28800,0],
 ['changes/p99-nz-necromancer-timers.json',7152,7200,0],
 // The page documents six hours; imported64-second variance is deliberately retained as unknown.
 ['changes/p99-nz-necromancer-timers.json',2666,21600,64],
 ['changes/p99-nz-regal-respawn.json',20769,86400,0],
 // Exact documented3d through3d7h12m bounds, represented by the engine's uniform integer seconds.
 ['changes/p99-nz-regal-respawn.json',3265320,272160,12960],
];
test('six reviewed non-starter quest spawn timers preserve all unrelated row fields',()=>{
 for(const [file,id,time,variance] of expected){
  const proposal=read(file),row=proposal.rows.find(r=>r.table==='spawn2'&&r.after?.id===id);
  assert.ok(row,`${file}:${id}`);assert.equal(row.after.respawntime,time);assert.equal(row.after.variance,variance);
  const {respawntime:bt,variance:bv,...before}=row.before,{respawntime:at,variance:av,...after}=row.after;
  assert.deepEqual(after,before,`${id}: timer-only change`);assert.ok(proposal.evidence.length);
 }
});
