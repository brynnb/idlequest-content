// Behavioral simulation using the pinned VM and actual items.lua module.
// Mocked API calls do not prove real settlement, rollback, lifecycle or UI.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const setup=read('tools/p99-test-fixture.lua')+'\npackage.preload["items"]=function()\n'+read('sources/projecteq/lua_modules/items.lua')+'\nend\n';
const cases=[];
const add=(name,file,assertions)=>cases.push({name,source:read(file),setup,assertions});

const sindl='changes/p99-classic-conversions/gfaydark--Sindl_Talonstrike.lua';
for(const phrase of ['hail','soldiers of tunare','what soldiers of tunare','harvesters','what harvesters']) add('Sindl '+phrase,sindl,`say('${phrase}');equal(#calls.speech,1);equal(next(calls.rewards),nil)`);
add('Sindl clickable topics',sindl,`say('hail');local initial=calls.speech[1];local n=0;for phrase in initial:gmatch('%[(.-)%]') do n=n+1;local before=#calls.speech;say(phrase);equal(#calls.speech,before+1) end;equal(n,2)`);
const zaen='changes/p99-classic-conversions/qcat--Zaen_Kalystir.lua';
add('Zaen hail',zaen,`say('hail');equal(#calls.speech,1);assert(string.find(calls.speech[1],'Shrine of the Diseased',1,true))`);
for(const f of [sindl,zaen]) {
 add(f+' no unknown response',f,`say('unrelated');equal(#calls.speech,0)`);
 add(f+' rejects all trade including later tomes, repeated',f,`trade({99999,51121},{platinum=8});equal(remaining[99999],1);equal(remaining[51121],1);equal(remaining.platinum,8);equal(calls.returns,1);equal(next(calls.rewards),nil);equal(calls.exp,0);trade({99999});equal(remaining[99999],1);equal(calls.returns,2)`);
}
for(const [zone,name,api,id] of [['emeraldjungle','gorilla','spawn2',94140],['lakerathe','aquagoblin','unique_spawn',51149],['lakeofillomen','barracuda','spawn2',85224]]) {
 const f=`changes/p99-classic-conversions/${zone}--hash-tainted_${name}.lua`;
 for(const pos of [[1,2,3,4],[-100,0,123.5,0]]) add(name+' exact death spawn '+pos,f,`local captures={};eq.${api}=function(...) table.insert(captures,{...}) end; local actor={GetX=function() return ${pos[0]} end,GetY=function() return ${pos[1]} end,GetZ=function() return ${pos[2]} end,GetHeading=function() return ${pos[3]} end}; event_death_complete({self=actor});equal(#captures,1);equal(#captures[1],7);equal(captures[1][1],${id});equal(captures[1][2],0);equal(captures[1][3],0);equal(captures[1][4],${pos[0]});equal(captures[1][5],${pos[1]});equal(captures[1][6],${pos[2]});equal(captures[1][7],${pos[3]});equal(next(calls.rewards),nil)`);
}
const lord='changes/p99-classic-conversions/steamfont--Minotaur_Lord.lua';
add('Minotaur aggro quoted speech',lord,`event_aggro({self=npc});equal(#calls.speech,1);equal(calls.speech[1],'I survived the gladiator pens of Qeynos!! What can you do to one such as I?!!')`);
add('Minotaur death speech no invented spawn',lord,`event_death_complete({self=npc});equal(#calls.speech,1);equal(calls.speech[1],'I die soon! Meldrath, help me!')`);
test('Classic missing Lua handlers: isolated Lua behavior (not game runtime)',t=>{
 const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'p99-behavior-'));t.after(()=>fs.rmSync(tmp,{recursive:true,force:true}));
 const binary=path.join(tmp,'runner');
 execFileSync('go',['build','-o',binary,'../tools/p99-lua-runner.go'],{cwd:path.join(root,'validator'),encoding:'utf8'});
 const output=execFileSync(binary,[],{input:JSON.stringify(cases),encoding:'utf8',maxBuffer:4*1024*1024});
 assert.equal(output.trim().split('\n').length,cases.length);console.log(output.trim());
});
