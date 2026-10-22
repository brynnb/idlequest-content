import {test} from 'node:test';
import assert from 'node:assert/strict';
import {checkReferenceRows,literalReferences} from './p99-reference-check.mjs';
const body='function event_trade(e)\n e.other:SummonItem(999999)\nend\n';
const make=(after=body,enabled=0,before=body)=>({table:'quests',before:{id:1,zone:'zone',name:'npc',enabled:1,lua_content:before},after:{id:1,zone:'zone',name:'npc',enabled,lua_content:after}});
const run=rows=>checkReferenceRows(rows,new Set(),new Set());
test('retained disabled references remain counted and source-keyed, not suppressed',()=>{
 const r=run([make('-- enabled: false\r\n-- reviewed exclusion\r\n'+body.replace(/\n/g,'\r\n'))]);
 assert.equal(r.passed,true);assert.equal(r.missingCount,1);assert.equal(r.retainedHistoricalCount,1);assert.deepEqual(r.retainedHistoricalSourceKeys,['zone/npc']);assert.equal(r.missing[0].originalCallbackBodyPreserved,true);
});
test('active unresolved references, newly added literals and modified bodies fail closed',()=>{
 for(const row of [make(body,1),make(body.replace('end',' e.other:SummonItem(999999)\nend')),make(body.replace('999999','888888')),make(body.replace('end',' e.other:AddEXP(10)\nend')),make(body,0,'')])assert.equal(run([row]).passed,false);
 const changed=make();changed.before.name='other';assert.equal(run([changed]).passed,false);
 const added=make();added.before=null;assert.equal(run([added]).passed,false);
});
test('known IDs resolve and each literal occurrence remains independently visible',()=>{
 const source='items.CheckHandin(e.other, {item1=42,item2=42})\ne.other:SummonItem(42)\neq.create_ground_object(42,0,0,0)\ne.other:Faction(7,1)';
 assert.equal(literalReferences(source).length,5);
 const r=checkReferenceRows([make(source)],new Set([42]),new Set([7]));assert.equal(r.checked,5);assert.equal(r.missingCount,0);assert.equal(r.passed,true);
});
test('module references participate and disabled status alone cannot excuse new code',()=>{
 const row={table:'quest_lua_modules',before:{module_name:'m',lua_content:body},after:{module_name:'m',enabled:0,lua_content:body}};
 assert.deepEqual(run([row]).retainedHistoricalSourceKeys,['module:m']);row.after.lua_content+='e.other:SummonItem(888888)\n';assert.equal(run([row]).failureCount,2);
});
