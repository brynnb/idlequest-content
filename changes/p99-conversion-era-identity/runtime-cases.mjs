import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';

// Keep the standalone and central suites on exactly the same 17 assertions.
export const setupExtra='other.GetRaceName=function() return "Halfling" end\n';

export function buildBidilsCases(expected) {
 const lua=s=>JSON.stringify(s);
 const cases=expected.map(b=>({name:'Bidils '+b.phrase+' exact, repeated and case-insensitive',assertions:[...['original','uppercase'].map(kind=>'calls.speech={}\nsay('+lua(kind==='original'?b.phrase:b.phrase.toUpperCase())+')\nequal(#calls.speech,'+b.responses.length+')\n'+b.responses.map((s,i)=>'equal(calls.speech['+(i+1)+'],'+lua(s)+')').join('\n')),'equal(calls.exp,0)\nassert(next(calls.rewards)==nil)\nassert(next(calls.factions)==nil)'].join('\n')}));
 cases.push({name:'Bidils unknown/coin text invents no missing reward branch',assertions:'say("coin")\nsay("unrelated")\nequal(#calls.speech,0)\nequal(calls.exp,0)\nassert(next(calls.rewards)==nil)'});
 cases.push({name:'Bidils preserves independent if branches on multiple keywords',assertions:'say("hail my tale")\nequal(#calls.speech,2)\nequal(calls.speech[1],'+lua(expected[0].responses[0])+')\nequal(calls.speech[2],'+lua(expected[1].responses[0])+')'});
 cases.push({name:'Bidils unrelated extra/partial/repeat offers are returned without reward',assertions:'trade({1001,1001,1002},{platinum=7})\nequal(remaining[1001],2)\nequal(remaining[1002],1)\nequal(remaining.platinum,7)\ntrade({1001})\nequal(remaining[1001],1)\ntrade({})\nequal(calls.returns,3)\nequal(calls.exp,0)\nequal(#calls.cash,0)\nassert(next(calls.rewards)==nil)\nassert(next(calls.factions)==nil)'});
 return cases;
}

export function buildRuntimeAssertions({expected,proposedFile,source}) {
 const sourceSha256=createHash('sha256').update(source).digest('hex');
 return buildBidilsCases(expected).map(({name,assertions})=>({name,proposedFile,sourceSha256,setupExtra,assertions}));
}

// Explicit regeneration only. Imports have no filesystem side effects.
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
 const base=path.dirname(fileURLToPath(import.meta.url));
 const root=path.resolve(base,'../..');
 const proposal=JSON.parse(fs.readFileSync(path.join(root,'changes/p99-conversion-era-identity.json'),'utf8'));
 const proposedFile=proposal.sources[0].proposedFile;
 const expected=JSON.parse(fs.readFileSync(path.join(base,'dialogue-expectations.json'),'utf8'));
 const source=fs.readFileSync(path.join(root,proposedFile),'utf8');
 fs.writeFileSync(path.join(base,'runtime-assertions.json'),JSON.stringify(buildRuntimeAssertions({expected,proposedFile,source}),null,2)+'\n');
}
