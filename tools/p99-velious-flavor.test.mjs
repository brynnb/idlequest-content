// Isolated pinned-VM flavor tests, not live game bridge or lifecycle verification.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {execFileSync} from 'node:child_process';
const root=process.cwd();
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const setup=read('tools/p99-test-fixture.lua')+'\nother.GetRaceName=function() return "Human" end\nnpc.Shout=npc.Say\npackage.preload["items"]=function()\n'+read('sources/projecteq/lua_modules/items.lua')+'\nend\n';
const review={reviewed_candidates:[]};
for(const dir of ['p99-conversions-velious-flavor','p99-conversions-velious-flavor-extra']) for(const row of JSON.parse(read('changes/'+dir+'/review.json')).reviewed_candidates) review.reviewed_candidates.push({...row,proposalDir:dir});
const cases=[];
for(const row of review.reviewed_candidates.filter(x=>x.outcome==='converted_proposal')) {
 const source=read('changes/'+row.proposalDir+'/'+row.key+'.lua');
 for(const [i,branch] of row.tests.entries()) {
  const fields=['self=npc','other=other'];
  if(branch.message!==undefined) fields.push('message='+JSON.stringify(branch.message));
  if(branch.signal!==undefined) fields.push('signal='+branch.signal);
  if(branch.joined!==undefined) fields.push('joined='+branch.joined);
  let assertions=branch.event+'({'+fields.join(',')+'});equal(#calls.speech,'+branch.expected+');';
  for(const [idx,message] of (branch.messages??[]).entries()) assertions+='equal(calls.speech['+(idx+1)+'],'+JSON.stringify(message)+');';
  assertions+='equal(#calls.signals,'+(branch.signals??[]).length+');';
  for(const [si,signal] of (branch.signals??[]).entries()) for(const [vi,v] of signal.entries()) assertions+='equal(calls.signals['+(si+1)+']['+(vi+1)+'],'+v+');';
  assertions+='equal(next(calls.rewards),nil);equal(calls.exp,0);equal(next(calls.factions),nil)';
  cases.push({name:row.key+' branch '+i,source,setup,assertions});
 }
 if(source.includes('function event_say')) cases.push({name:row.key+' unrelated speech',source,setup,assertions:'say("zzzz unrelated");equal(#calls.speech,0)'});
 cases.push({name:row.key+' return all and repeat',source,setup,assertions:'trade({99999,99999},{platinum=5,gold=7});equal(remaining[99999],2);equal(remaining.platinum,5);equal(remaining.gold,7);equal(calls.returns,1);equal(next(calls.rewards),nil);trade({99999});equal(remaining[99999],1);equal(calls.returns,2)'});
}
test('Velious flavor full source event branches and return-all (isolated mocks)',t=>{
 const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'p99-velious-flavor-'));t.after(()=>fs.rmSync(tmp,{recursive:true,force:true}));
 const binary=path.join(tmp,'runner');
 execFileSync('go',['build','-o',binary,'../tools/p99-lua-runner.go'],{cwd:path.join(root,'validator'),encoding:'utf8'});
 const output=execFileSync(binary,[],{input:JSON.stringify(cases),encoding:'utf8',maxBuffer:4*1024*1024});
 assert.equal(output.trim().split('\n').length,cases.length);console.log(output.trim());
});
