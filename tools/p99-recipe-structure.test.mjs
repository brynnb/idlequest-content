// Static regression expectations, not execution of a game crafting transaction.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {findProposals} from './p99-merge-proposals.mjs';
const expectations=JSON.parse(fs.readFileSync(new URL('./p99-recipe-expectations.json',import.meta.url),'utf8'));
const expected=Object.fromEntries(expectations.map(e=>[e.recipeId,[e.nofail,e.components,e.containers,e.outputs]]));
const rows=table=>fs.readdirSync(`data/${table}`).flatMap(file=>fs.readFileSync(`data/${table}/${file}`,'utf8').trim().split('\n').filter(Boolean).map(line=>JSON.parse(line)));
const sorted=values=>values.slice().sort((a,b)=>a[0]-b[0]);
test('Proposed and independently reviewed baseline recipes match explicit structures (static only)',async()=>{
 const recipes=new Map(rows('tradeskill_recipe').map(r=>[r.id,r]));
 const entries=new Map(rows('tradeskill_recipe_entries').map(r=>[r.id,r]));
 const changed=new Set();
 for(const {value:p} of await findProposals(process.cwd())) for(const r of p.rows) {
  if(r.table==='tradeskill_recipe') { assert.ok(r.after);recipes.set(r.after.id,r.after);changed.add(r.after.id); }
  if(r.table==='tradeskill_recipe_entries') { assert.ok(r.after);entries.set(r.after.id,r.after);changed.add(r.after.recipe_id); }
 }
 assert.equal(Object.keys(expected).length,expectations.length,'Recipe expectations must be unique');
 for(const id of changed) assert.ok(expected[id],`Changed recipe ${id} requires independent structural expectations`);
 for(const e of expectations) assert.equal(crypto.createHash('sha256').update(fs.readFileSync(e.evidence.cachePath)).digest('hex'),e.evidence.sha256,`Recipe ${e.recipeId} evidence drift`);
 for(const id of Object.keys(expected).map(Number)) {
  assert.ok(expected[id],`New recipe ${id} requires independent structural expectations`);
  const recipe=recipes.get(id), [nofail,components,containers,outputs]=expected[id];
  assert.equal(recipe.enabled,1,`${id}: enabled`);assert.equal(recipe.must_learn,expectations.find(e=>e.recipeId===id).mustLearn,`${id}: learning metadata`);assert.equal(recipe.nofail,nofail,`${id}: fail semantics`);
  const expectation=expectations.find(e=>e.recipeId===id);
  if(expectation.trivial!==undefined)assert.equal(recipe.trivial,expectation.trivial,`${id}: documented trivial`);
  assert.equal(recipe.replace_container,expectation.replaceContainer,`${id}: container replacement metadata`);
  const actual=[...entries.values()].filter(row=>row.recipe_id===id);
  for(const [field,want] of [['componentcount',components],['iscontainer',containers],['successcount',outputs],['failcount',expectation.failureOutputs]]) {
   assert.deepEqual(sorted(actual.filter(row=>row[field]>0).map(row=>[row.item_id,row[field]])),sorted(want),`${id}: ${field}`);
  }
 }
 assert.ok(changed.size>0);
});
