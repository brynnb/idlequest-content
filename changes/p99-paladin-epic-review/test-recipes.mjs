import fs from 'node:fs';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {findProposals} from '../../tools/p99-merge-proposals.mjs';
const dir='changes/p99-paladin-epic-review';
const expectations=JSON.parse(fs.readFileSync(dir+'/recipe-expectations.json','utf8'));
const ids=new Set(expectations.map(e=>e.recipeId));
const rows=table=>fs.readdirSync('data/'+table).flatMap(f=>fs.readFileSync('data/'+table+'/'+f,'utf8').trim().split('\n').filter(Boolean).map(l=>JSON.parse(l))).filter(r=>ids.has(table==='tradeskill_recipe'?r.id:r.recipe_id));
const recipes=new Map(rows('tradeskill_recipe').map(r=>[r.id,r]));
const entries=new Map(rows('tradeskill_recipe_entries').map(r=>[r.id,r]));
const proposals=[];
for(const {file,value:p} of await findProposals(process.cwd())) for(const r of p.rows){
 if(r.table==='tradeskill_recipe'&&ids.has(r.after?.id)){recipes.set(r.after.id,r.after);proposals.push({id:p.id,file,recipeId:r.after.id});}
 if(r.table==='tradeskill_recipe_entries'&&ids.has(r.after?.recipe_id)){entries.set(r.after.id,r.after);proposals.push({id:p.id,file,recipeId:r.after.recipe_id});}
}
const sorted=v=>v.slice().sort((a,b)=>a[0]-b[0]);
for(const e of expectations){
 assert.equal(crypto.createHash('sha256').update(fs.readFileSync(e.evidence.cachePath)).digest('hex'),e.evidence.sha256);
 const r=recipes.get(e.recipeId);for(const [k,v] of [['enabled',e.enabled],['nofail',e.nofail],['must_learn',e.mustLearn],['replace_container',e.replaceContainer]])assert.equal(r[k],v,`${e.recipeId}: ${k}`);
 for(const [k,v] of [['componentcount',e.components],['iscontainer',e.containers],['successcount',e.outputs],['failcount',e.failureOutputs]])assert.deepEqual(sorted([...entries.values()].filter(r=>r.recipe_id===e.recipeId&&r[k]>0).map(r=>[r.item_id,r[k]])),sorted(v),`${e.recipeId}: ${k}`);
 console.log('PASS recipe '+e.recipeId+' exact current structure, static only');
}
fs.writeFileSync(dir+'/recipe-tests.json',JSON.stringify({status:'passed',recipeIds:[...ids],overlaidProposals:proposals,scope:'Exact current rows with all existing format1 proposal overlays; cached evidence hashes verified. No crafting, failure randomness, inventory settlement or rendered UI.'},null,2)+'\n');
