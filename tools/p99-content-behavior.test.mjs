// Behavioral simulation using the pinned VM and actual items.lua module.
// Mocked API calls do not prove real settlement, rollback, lifecycle or UI.
import test from 'node:test';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const setup=read('tools/p99-test-fixture.lua')+'\npackage.preload["items"]=function()\n'+read('sources/projecteq/lua_modules/items.lua')+'\nend\n';
const cases=[];
const exercisedFiles=new Set();
const add=(name,file,assertions)=>{
 const baselineVerification=!file.startsWith('changes/');
 if(baselineVerification)assert.match(file,/^(effective|maintained|sources)\//);
 else exercisedFiles.add(file);
 cases.push({name:(baselineVerification?'BASELINE VERIFICATION: ':'')+name,file,source:read(file),setup,assertions,baselineVerification});
};
const devin='changes/p99-am-call-of-flame/gfaydark-Devin_Ashwood.lua';
for(const cls of [1,4]) for(const lvl of [1,49,50,60]) add(`Devin no duplicate letter class ${cls} level ${lvl}`,devin,`character.class=${cls};character.level=${lvl};say('I want to learn');reward(20876,0)`);
const kith='changes/p99-am-call-of-flame/kithicor-Kithicor.lua';
add('Kithicor eggs reward and signed factions; extra and repeat',kith,`trade({20877,99999});reward(20878,1);faction(324,-50);faction(269,50);faction(302,50);faction(272,50);equal(remaining[99999],1);equal(remaining[20877],0);equal(calls.returns,1);trade({20877});reward(20878,2);faction(324,-100)`);
add('Kithicor invalid offer unchanged',kith,`trade({99999});equal(remaining[99999],1);equal(next(calls.rewards),nil);equal(next(calls.factions),nil);equal(calls.returns,1)`);
const faren='changes/p99-am-faren-faction/qeynos-Faren.lua';
add('Faren merchant faction, tunic, cash and extra',faren,`trade({13702,99999});reward(13129,1);faction(291,4);faction(221,0);faction(262,4);faction(219,4);faction(230,-5);faction(223,-5);equal(calls.cash[1][1],9);equal(remaining[99999],1);equal(remaining[13702],0);equal(calls.returns,1)`);
add('Faren invalid offer unchanged',faren,`trade({99999});equal(next(calls.rewards),nil);equal(next(calls.factions),nil);equal(remaining[99999],1)`);
for(const zone of ['freportn','freeportwest']) {
 const theron=`changes/p99-nz-shark-hunting-dialogue/${zone}--Theron_Rolius.lua`;
 for(const phrase of ['reef shark','reef sharks']) add(`${zone} information does not issue sack: ${phrase}`,theron,`say('${phrase}');reward(17937,0);assert(string.find(calls.speech[1],'smallest',1,true))`);
 for(const phrase of ['hunt','I will hunt the reef sharks.']) add(`${zone} accepts hunt: ${phrase}`,theron,`say('${phrase}');reward(17937,1);assert(string.find(calls.speech[1],'Take this large sack',1,true))`);
 add(`${zone} sharkskin shield no EXP or coin, extra retained`,theron,`trade({13873,99999});reward(13868,1);equal(calls.exp,0);equal(#calls.cash,0);equal(remaining[99999],1);equal(remaining[13873],0);equal(calls.returns,1)`);
 add(`${zone} existing helm reward retained`,theron,`trade({13921,99999});equal(calls.exp,1000);equal(calls.cash[1][4],3);faction(281,10);equal(remaining[99999],1)`);
}
const waltor='changes/p99-nz-wooly-fungus-faction/halas--Waltor_Felligan.lua';
add('Waltor jar factions and reward',waltor,`trade({13966,99999});reward(15203,1);faction(336,-30);faction(229,0);faction(327,10);faction(328,10);faction(223,-30);faction(244,-30);equal(calls.cash[1][3],9);equal(calls.exp,50);equal(remaining[99999],1)`);
add('Waltor partial fungus is returned without cure',waltor,`trade({13967,99999});equal(#calls.spells,0);equal(remaining[13967],1);equal(remaining[99999],1);equal(calls.returns,1)`);
add('Waltor paired fungus cure and extra',waltor,`trade({13967,13967,99999});equal(calls.spells[1][1],213);equal(calls.spells[1][2],42);equal(remaining[13967],0);equal(remaining[99999],1);equal(next(calls.factions),nil)`);
add('Waltor steak poison cure',waltor,`trade({13445,99999});equal(calls.spells[1][1],203);equal(remaining[13445],0);equal(remaining[99999],1)`);
add('Waltor healing accepts ten gold and keeps excess',waltor,`trade({99999},{gold=11});equal(calls.spells[1][1],17);equal(remaining.gold,1);equal(remaining[99999],1)`);
add('Waltor insufficient healing payment unchanged',waltor,`trade({99999},{gold=9});equal(#calls.spells,0);equal(remaining.gold,9);equal(remaining[99999],1)`);
const lily='effective/quests/gfaydark/Lily_Ashwood.lua';
for(const cls of [1,4]) for(const lvl of [1,49,50,60]) add(`Lily letter gate class ${cls} level ${lvl}`,lily,`character.class=${cls};character.level=${lvl};say('I will take him the letter');reward(20876,${cls===4&&lvl>=50?1:0})`);
const gallin='changes/p99-nz-shark-meat/gfaydark--Gallin_Woodwind.lua';
for(const phrase of ['hunt for meat','I will hunt for meat','I want to hunt for meat']) add(`Gallin sack: ${phrase}`,gallin,`say('${phrase}');reward(17953,1)`);
add('Gallin intended denominations and retained extras',gallin,`trade({12121,99999});reward(7032,1);equal(calls.cash[1][1],23);equal(calls.cash[1][2],0);equal(calls.cash[1][3],7);equal(calls.cash[1][4],0);equal(calls.exp,150);equal(remaining[99999],1)`);
const neb='changes/p99-neb-lua/Neb.lua';
for(const topic of ['hail','paebala','chetari','goo','vaniki','zlandicar','help']) add(`Neb dialogue ${topic}`,neb,`say('${topic}');equal(#calls.speech,1);equal(next(calls.rewards),nil)`);
add('Neb two hearts low-level reward extras and repeat',neb,`character.level=1;trade({26033,26009,99999});reward(26040,1);reward(28060,1);faction(463,100);faction(462,-10);faction(464,-10);equal(calls.exp,250000);equal(remaining[26033],0);equal(remaining[26009],0);equal(remaining[99999],1);equal(calls.returns,1);trade({26009,26033});reward(26040,2);reward(28060,2)`);
for(const item of [26033,26009,69341,99999]) add(`Neb incomplete/out-of-era item ${item}`,neb,`trade({${item}});equal(next(calls.rewards),nil);equal(next(calls.factions),nil);equal(calls.exp,0);equal(remaining[${item}],1);equal(calls.returns,1)`);
for(const [name,currency,cost,rewardId] of [['Tobart_Dirkins','platinum',1,30146],['Loremaster_Fronden','platinum',1,30146],['Doogle_McBanick','gold',3,30147]]) {
 const f=`changes/p99-conversions-velious/thurgadina/${name}.lua`;
 if(name!=='Loremaster_Fronden') add(`${name} hail`,f,`say('hail');assert(#calls.speech>0)`);
 add(`${name} exact payment and repeat low level`,f,`character.level=1;trade({99999},{${currency}=${cost}});reward(${rewardId},1);equal(remaining.${currency},0);equal(remaining[99999],1);equal(calls.exp,0);equal(next(calls.factions),nil);equal(#calls.cash,0);trade({},{${currency}=${cost}});reward(${rewardId},2)`);
 add(`${name} excess payment buys one and retains excess`,f,`trade({99999},{${currency}=${cost*2}});reward(${rewardId},1);equal(remaining.${currency},${cost});equal(remaining[99999],1);equal(calls.returns,1)`);
 add(`${name} underpayment retains all`,f,`trade({99999},{${currency}=${cost-1}});reward(${rewardId},0);equal(remaining.${currency},${cost-1});equal(remaining[99999],1);equal(calls.returns,1)`);
 add(`${name} wrong denomination remains`,f,`trade({99999},{copper=10000});reward(${rewardId},0);equal(remaining.copper,10000)`);
}
const errgriz='changes/p99-conversions-velious/iceclad/Errgriz.lua';
for(const topic of ['hail','learning','clean the furs','makes things']) add(`Errgriz dialogue ${topic}`,errgriz,`say('${topic}');assert(#calls.speech>0)`);
add('Errgriz correct fur repeats, extras and no invented bonus',errgriz,`character.level=1;trade({30023,30023,99999});reward(30037,1);equal(remaining[30023],1);equal(remaining[99999],1);equal(calls.exp,0);equal(next(calls.factions),nil);equal(#calls.cash,0);trade({30023});reward(30037,2)`);
add('Errgriz wrong fur unchanged',errgriz,`trade({99999});reward(30037,0);equal(remaining[99999],1);equal(calls.returns,1)`);
for(const name of ['Royal_Scribe_Kaavin','Grand_Huntsman_Darral']) {
 const f=`changes/p99-conversions-velious/thurgadinb/${name}.lua`;
 add(`${name} hail and no invented hand-in`,f,`say('hail');assert(#calls.speech>0);trade({99999},{platinum=10});equal(remaining[99999],1);equal(remaining.platinum,10);equal(next(calls.rewards),nil);equal(calls.returns,1)`);
}
const wolten='changes/p99-am-qeynos-dialogue/qeynos-Wolten_Grafe.lua';
for(const phrase of ['wish to join our cause','join the cause']) add(`Wolten cause phrase ${phrase}`,wolten,`say('${phrase}');assert(string.find(calls.speech[1],'dangerous mission',1,true))`);
add('Wolten box bread water and exactly two silver',wolten,`trade({13882,99999});reward(13006,1);reward(13015,1);equal(calls.cash[1][1],0);equal(calls.cash[1][2],2);equal(calls.cash[1][3],0);equal(calls.cash[1][4],0);equal(remaining[99999],1);equal(calls.returns,1)`);
const phin='changes/p99-am-qeynos-dialogue/qeynos2-Phin_Esrinap.lua';
add('Phin headband choices individually clickable',phin,`say('headbands');local text=calls.speech[1];local count=0;for phrase in text:gmatch('%[(.-)%]') do count=count+1;local before=#calls.speech;say(phrase);equal(#calls.speech,before+1) end;equal(count,3)`);
add('Phin training headband alias',phin,`say('training headband');assert(string.find(calls.speech[1],'four',1,true))`);
add('Phin partial handin retains scalps and extras',phin,`trade({13789,13789,99999});equal(next(calls.rewards),nil);equal(remaining[13789],2);equal(remaining[99999],1);equal(calls.returns,1)`);
for(const [name,signals] of [
 ['Loremaster_Fronden',[[[115013,2,11000]],[[115011,5,8000],[115187,5,8000]],[[115011,6,0],[115187,6,0]],[[115011,7,0],[115187,7,0]],[[115011,8,8000],[115187,8,8000]],[[115011,9,8000],[115187,9,8000]],[[115011,10,8000],[115187,10,8000]]]],
 ['Doogle_McBanick',[[[115013,3,8000]],[[115013,4,0]],[[115013,5,7000]],[]]]]) {
 const f=`changes/p99-conversions-velious/thurgadina/${name}.lua`;
 signals.forEach((expected,i)=>add(`${name} signal ${i+1} capture`,f,`event_signal({self=npc,signal=${i+1}});equal(#calls.signals,${expected.length});`+expected.map((entry,j)=>entry.map((v,k)=>`equal(calls.signals[${j+1}][${k+1}],${v});`).join('')).join('')));
 add(`${name} unknown signal no-op`,f,`event_signal({self=npc,signal=999});equal(#calls.signals,0);equal(#calls.speech,0)`);
}
for(const [item,silver] of [[13369,7],[13370,1]]) add(`Glib denomination item ${item}`,'changes/p99-nz-emissary-currency/oggok--Emissary_Glib.lua',`trade({${item},99999});equal(calls.cash[1][1],0);equal(calls.cash[1][2],${silver});equal(calls.cash[1][3],0);equal(calls.cash[1][4],0);equal(calls.exp,200);equal(remaining[99999],1);equal(calls.returns,1)`);
for(const phrase of ['make use of your pathetic cowardice','make use of my pathetic cowardice']) add(`Davorre phrase ${phrase}`,'changes/p99-nz-neonate-dialogue/paineel--Davorre_Bloodthorn.lua',`say('${phrase}');reward(14041,1)`);
add('Auhrik correct neonate completion speech','changes/p99-nz-neonate-dialogue/paineel--Auhrik_Siet-ka.lua',`trade({12993,99999});assert(string.find(calls.speech[1],"Well, that wasn't so hard",1,true));equal(calls.exp,2000);equal(calls.cash[1][1],5);equal(calls.cash[1][2],3);equal(remaining[99999],1);equal(calls.returns,1)`);
// Explicit expected changed hand-ins, not expectations inferred from the script.
const branchSpecs=[
 ['Adia','changes/p99-conversions-velious/thurgadina/Adia_Coldbeard.lua',[],{gold:5},30145,[0,0,0,0],0],
 ['Vesteri','changes/p99-nz-nesiff-statue-currency/qrg--Vesteri_Nomanoi.lua',[13864],{},null,[0,1,0,0],250],
 ['Reebo','changes/p99-nz-nillipuss-currency/rivervale--Reebo_Leafsway.lua',[13974,13974,13974,13974],{},10308,[0,15,0,0],27440],
 ['Crow','changes/p99-nz-tattered-pouch-currency/qeynos2--Crow.lua',[17600],{},13901,[0,0,3,0],250],
 ['Manik','changes/p99-nz-series-c-currency/akanon--Manik_Compolten.lua',[13212,13211,13213,13214],{},13209,[6,0,0,0],5000],
 ['Antus','changes/p99-nz-fisherman-reward/paineel--Antus_Shelbra.lua',[9969],{},13697,[9,0,4,0],0],
 ['Lucan original','changes/p99-am-message-intercept/freportw-Sir_Lucan_D-Lere.lua',[18822],{},null,[0,10,0,0],5000],
 ['Lucan alias','changes/p99-am-message-intercept/freeporteast-Sir_Lucan_D-Lere.lua',[18822],{},null,[0,10,0,0],5000],
 ['Bvellos head','changes/p99-am-bvellos-bounties/kael-Captain_Bvellos.lua',[30081],{},null,[0,0,0,8],0],
 ['Bvellos paws','changes/p99-am-bvellos-bounties/kael-Captain_Bvellos.lua',[25301,25301,25301,25301],{},25077,null,20000],
 ['Bvellos mask unchanged','changes/p99-am-bvellos-bounties/kael-Captain_Bvellos.lua',[1718],{},25024,null,20000],
 ['Bvellos cloak unchanged','changes/p99-am-bvellos-bounties/kael-Captain_Bvellos.lua',[1717],{},25019,null,20000],
 ['Warden','changes/p99-nz-tunare-warden/felwithea--Yeolarn_Bronzeleaf.lua',[1571,1599],{},1572,null,5000],
];
for(const [ids,rewardId] of [[[31262,31261,31263,31260],31463],[[31267,31266,31265,31264],31464],[[31259,31270,31253,31250],31460],[[31251,31269,31252,31254],31461],[[31257,31268,31256,31255],31462]]) branchSpecs.push([`Lendiniara ${rewardId}`,'changes/p99-nz-lendiniara-tests/Lendiniara_the_Keeper.lua',ids,{},rewardId,null,200000]);
for(const [name,ids,rewardId,xp] of [
 ['iceclad-Sojan_the_Sleepless',[30037],30038,0],['iceclad-Sojan_the_Sleepless',[30038,30057],30040,0],
 ['iceclad-Captain_Nalot',[30047],30008,50000],['iceclad-Captain_Nalot',[30040,30039],30034,0],['thurgadina-Pythic_Urson',[30058,30060],30061,0],['greatdivide-gnomish_deserter',[30061],30039,0],['wakening-mist_panther',[30066,30066,30066,30066],30057,0],['iceclad-Nelet_Durzit',[30034],30033,0]]) branchSpecs.push([`${name} ${rewardId}`,'changes/p99-am-nalot-rum/'+name+'.lua',ids,{},rewardId,null,xp]);
branchSpecs.push(
 ['Kithicor','changes/p99-am-call-of-flame/kithicor-Kithicor.lua',[20877],{},20878,null,1000],
 ['Faren','changes/p99-am-faren-faction/qeynos-Faren.lua',[13702],{},13129,[9,0,0,0],200],
 ['Waltor full jar','changes/p99-nz-wooly-fungus-faction/halas--Waltor_Felligan.lua',[13966],{},15203,[0,0,9,0],50],
 ['Gallin','changes/p99-nz-shark-meat/gfaydark--Gallin_Woodwind.lua',[12121],{},7032,[23,0,7,0],150],
 ['Glib regular','changes/p99-nz-emissary-currency/oggok--Emissary_Glib.lua',[13369],{},null,[0,7,0,0],200],
 ['Glib captain','changes/p99-nz-emissary-currency/oggok--Emissary_Glib.lua',[13370],{},17928,[0,1,0,0],200],
 ['Auhrik supplies','changes/p99-nz-neonate-dialogue/paineel--Auhrik_Siet-ka.lua',[12993],{},null,[5,3,0,0],2000],
 ['Wolten bones','changes/p99-am-qeynos-dialogue/qeynos-Wolten_Grafe.lua',[13882],{},13015,[0,2,0,0],100],
 ['Theron original','changes/p99-nz-shark-hunting-dialogue/freportn--Theron_Rolius.lua',[13873],{},13868,null,0],
 ['Theron alias','changes/p99-nz-shark-hunting-dialogue/freeportwest--Theron_Rolius.lua',[13873],{},13868,null,0]
);
for(const id of [27255,27256,27258,27259,27266]) branchSpecs.push([`Jaled talisman ${id}`,'changes/p99-jaled-lua/Jaled_Dar-s_shade.lua',[id],{},27265,null,500000]);
for(const [label,ids,rewardId] of [['regular',[30067,30067],10036],['pristine',[30068],22817],['ulthork unchanged',[24874,24874,24874,24874],10036]]) branchSpecs.push([`Chief Kalan ${label}`,'changes/p99-am-bulthar-reward/cobaltscar-Chief_Kalan.lua',ids,{},rewardId,null,0]);
for(const zone of ['freeporteast','freporte']) branchSpecs.push([`Nestral ${zone}`,`changes/p99-nz-rebby-factions/${zone}--Nestral_TGaza.lua`,[13158],{},null,[7,0,0,0],62]);
branchSpecs.push(['Collier treatment','changes/p99-am-collier-reward/erudnext-Collier.lua',[31828,22570,6949,6950],{},22571,null,500]);
branchSpecs.push(
 ['Kaglari faction','changes/p99-am-innoruuk-faction/grobb-Kaglari.lua',[13916],{},15272,null,150],
 ['Baxok Gearheart','changes/p99-am-gearheart-reward/akanon-Baxok_Curhunter.lua',[13344],{},9002,[0,4,0,0],1000],
 ['Deputy Budo','changes/p99-nz-orc-belts-reward/misty--Deputy_Budo.lua',[13916],{},13024,[0,0,9,0],1000]);
const lt=obj=>'{'+Object.entries(obj).map(([k,v])=>`${k}=${v}`).join(',')+'}';
for(const [name,file,ids,coins,item,cash,xp] of branchSpecs) {
 const offer='{'+ids.join(',')+'}', coin=lt(coins);
 const check=(n)=>`${item?`reward(${item},${n});`:''}equal(calls.exp,${xp*n});`+(cash&&cash.some(x=>x)?cash.map((v,i)=>`equal(calls.cash[${n}][${i+1}],${v});`).join(''):'equal(#calls.cash,0);');
 add(`${name} exact low-level repeat`,file,`character.level=1;character.class=1;trade(${offer},${coin});${check(1)}equal(calls.returns,1);trade(${offer},${coin});${check(2)}equal(calls.returns,2)`);
 const extras=ids.length<4?[...ids,99999]:ids;
 add(`${name} extra item/currency retention`,file,`trade({${extras.join(',')}},${lt({...coins,copper:123})});${check(1)}equal(remaining.copper,123);${ids.length<4?'equal(remaining[99999],1);':''}`);
 add(`${name} unrelated later item returned`,file,`trade({69333,99999});equal(next(calls.rewards),nil);equal(calls.exp,0);equal(#calls.cash,0);equal(remaining[69333],1);equal(remaining[99999],1)`);
 if(ids.length) for(let missing=0;missing<ids.length;missing++) {
  const partial=ids.filter((_,i)=>i!==missing);
  add(`${name} missing component ${missing+1}`,file,`trade({${partial.join(',')}});equal(next(calls.rewards),nil);equal(#calls.cash,0);equal(calls.exp,0);`+(name==='Reebo'?'':partial.map(id=>`assert(remaining[${id}]>0);`).join('')));
 } else add(`${name} underpay retains gold`,file,'trade({99999},{gold=4});reward(30145,0);equal(remaining.gold,4);equal(remaining[99999],1)');
}
const lend='changes/p99-nz-lendiniara-tests/Lendiniara_the_Keeper.lua';
for(const phrase of ['hail','rewards','tasks','request of the arcane','request of the strong','request of the three','test of the ruby tear','test of the platinum tear','test of the emerald tear']) add(`Lendiniara ${phrase}`,lend,`say('${phrase}');equal(#calls.speech,1)`);
const gretta='changes/p99-am-gretta-dialogue/kaladima-Gretta_Mottle.lua';
for(const phrase of ['help to bake','bake muffins','fetch some bread']) add(`Gretta ${phrase}`,gretta,`say('${phrase}');equal(#calls.speech,1);reward(17881,${phrase==='bake muffins'?1:0})`);
add('Warden request letter','changes/p99-nz-tunare-warden/felwithea--Yeolarn_Bronzeleaf.lua',`say('warden of tunare');reward(1598,1)`);
for(const name of ['Sindl_Talonstrike','Zaen_Kalystir']) {
 const file='changes/p99-classic-conversions/'+(name==='Sindl_Talonstrike'?'gfaydark':'qcat')+'--'+name+'.lua';
 for(const phrase of (name==='Sindl_Talonstrike'?['hail','soldiers of tunare','harvesters']:['hail'])) add(`${name} ${phrase}`,file,`say('${phrase}');equal(#calls.speech,1)`);
 add(`${name} return only repeat`,file,'trade({99999},{gold=10});equal(remaining[99999],1);equal(remaining.gold,10);equal(calls.returns,1);trade({99999});equal(calls.returns,2);equal(next(calls.rewards),nil)');
}
for(const [phrase,needle] of [['garments','gloves'],['What ratskin gloves?','6 gold'],['What wolfskin gloves?','13 gold'],['What bearskin gloves?','25 gold']]) add(`Ged specific ${phrase}`,'changes/p99-nz-ged-glove-dialogue/kithicor--Ged_Twigborn.lua',`say('${phrase}');assert(string.find(calls.speech[1],'${needle}',1,true))`);
for(const phrase of ['collect components','interested']) add(`Keeper Bile ${phrase}`,'changes/p99-nz-necro-components-dialogue/cabwest--Keeper_Bile.lua',`say('${phrase}');assert(string.find(calls.speech[1],'two brittle skulls',1,true))`);
for(const [file,id,api] of [['emeraldjungle--hash-tainted_gorilla',94140,'spawn2'],['lakeofillomen--hash-tainted_barracuda',85224,'spawn2'],['lakerathe--hash-tainted_aquagoblin',51149,'unique_spawn']]) add(`Classic death spawn call ${file}`,'changes/p99-classic-conversions/'+file+'.lua',`npc.GetX=function() return 10 end;npc.GetY=function() return 20 end;npc.GetZ=function() return 30 end;npc.GetHeading=function() return 40 end;local spawned={};eq.${api}=function(...) spawned={...} end;event_death_complete({self=npc});equal(#spawned,7);equal(spawned[1],${id});equal(spawned[2],0);equal(spawned[3],0);equal(spawned[4],10);equal(spawned[5],20);equal(spawned[6],30);equal(spawned[7],40)`);
for(const [event,needle] of [['event_aggro','gladiator pens'],['event_death_complete','Meldrath']]) add(`Minotaur Lord ${event}`,'changes/p99-classic-conversions/steamfont--Minotaur_Lord.lua',`${event}({self=npc});assert(string.find(calls.speech[1],'${needle}',1,true))`);
for(const [file,ids,options] of [
 ['changes/p99-am-bvellos-bounties/kael-Captain_Bvellos.lua',[25301,25301,25301,25301],[25077,25084,25018]],
 ['changes/p99-nz-wooly-fungus-faction/halas--Waltor_Felligan.lua',[13966],[15203,15224,15269,15270,15271,15275,15036,15075]],
 ['changes/p99-nz-nillipuss-currency/rivervale--Reebo_Leafsway.lua',[13974,13974,13974,13974],[10308,8303,8304,10302,10303,10304,10305,10306,10309,17302,12001,10301,17301,17300,12002]],
 ['changes/p99-nz-emissary-currency/oggok--Emissary_Glib.lua',[13370],[17928,13371]]]) options.forEach((id,i)=>add(`Enumerated reward ${path.basename(file)} option ${i+1}`,file,`character.choice=${i+1};trade({${ids.join(',')}});reward(${id},1)`));
for(const [i,gold] of [3,4,5].entries()) add(`Crow payout option ${gold}`,'changes/p99-nz-tattered-pouch-currency/qeynos2--Crow.lua',`character.choice=${i+1};trade({17600});equal(calls.cash[1][3],${gold})`);
for(const [input,output] of [[1598,1596],[1597,1599]]) add(`Trilani Warden independent hand-in ${input}`,'effective/quests/erudnint/Trilani_Parlone.lua',`trade({${input},99999});reward(${output},1);equal(remaining[${input}],0);equal(remaining[99999],1);equal(calls.returns,1);trade({${input}});reward(${output},2)`);
add('Lendiniara retained faction magnitudes',lend,'trade({31262,31261,31263,31260});faction(430,75);faction(436,18);faction(448,-37)');
add('Warden retained faction magnitudes','changes/p99-nz-tunare-warden/felwithea--Yeolarn_Bronzeleaf.lua','trade({1571,1599});faction(226,40);faction(279,40);faction(5001,30)');
for(const ids of [[30081],[25301,25301,25301,25301]]) add(`Bvellos bounty faction ${ids[0]}`,'changes/p99-am-bvellos-bounties/kael-Captain_Bvellos.lua',`trade({${ids.join(',')}});faction(448,40);faction(419,10);faction(429,10);faction(430,-20)`);
for(const zone of ['freportw','freeporteast']) add(`Lucan note factions ${zone}`,`changes/p99-am-message-intercept/${zone}-Sir_Lucan_D-Lere.lua`,'trade({18822});faction(330,10);faction(336,10);faction(281,-20);faction(362,-20)');
for(const file of ['changes/p99-am-nalot-rum/iceclad-Sojan_the_Sleepless.lua','changes/p99-nz-sojan-hail/iceclad--Sojan_the_Sleepless.lua']) if(fs.existsSync(path.join(root,file))) add(`Sojan exact P99 hail ${file}`,file,`say('hail');equal(#calls.speech,1);assert(string.find(calls.speech[1],'bleary eyes',1,true));assert(string.find(calls.speech[1],'leave me alone',1,true))`);
for(const phrase of ['greaves','leggings']) add(`Crendatha leg armor dialogue ${phrase}`,'changes/p99-nz-rogue-skyshrine-dialogue/skyshrine--Crendatha_Fe-Dhar.lua',`say('${phrase}');equal(#calls.speech,1);assert(string.find(calls.speech[1],'three flawed sea sapphires',1,true))`);
const jaled='changes/p99-jaled-lua/Jaled_Dar-s_shade.lua';
for(const id of [27255,27256,27258,27259,27266]) add(`Jaled zone flag ${id}`,jaled,`character.level=1;trade({${id},99999});equal(#calls.zone_flags,1);equal(calls.zone_flags[1],128);trade({${id}});equal(#calls.zone_flags,2);equal(calls.zone_flags[2],128)`);
add('Jaled rejects later talisman9296',jaled,'trade({9296,99999});equal(next(calls.rewards),nil);equal(#calls.zone_flags,0);equal(remaining[9296],1);equal(remaining[99999],1)');
for(const phrase of ['hail','aid you','the sleeper','task','talismans']) add(`Jaled dialogue ${phrase}`,jaled,`say('${phrase}');equal(#calls.speech,1)`);
for(const phrase of ['How can I prove my strength?','wish to prove']) add(`Telkorenar strength phrase ${phrase}`,'changes/p99-nz-telkorenar-dialogue/templeveeshan--#Telkorenar.lua',`say('${phrase}');equal(#calls.speech,1);assert(string.find(calls.speech[1],'four tests',1,true));assert(string.find(calls.speech[1],'test of protection',1,true))`);
[10036,22503,16976,10037,10033,10049,10031,10053,10035,10051,10034,10050,10032,10048,10045].forEach((id,i)=>add(`Bulthar reward option ${i+1}`,'changes/p99-am-bulthar-reward/cobaltscar-Chief_Kalan.lua',`character.choice=${i+1};trade({30067,30067,99999});reward(${id},1);faction(432,30);faction(431,-60);equal(remaining[99999],1)`));
for(const phrase of ['Where is Konem?','Konem Matse','supplies']) add(`Phin Konem note phrase ${phrase}`,phin,`say('${phrase}');reward(18921,1)`);
for(const zone of ['freeporteast','freporte']) add(`Nestral exact five factions ${zone}`,`changes/p99-nz-rebby-factions/${zone}--Nestral_TGaza.lua`,'trade({13158,99999});faction(336,7);faction(229,7);faction(329,1);faction(230,1);faction(330,1);equal(remaining[99999],1)');
for(const phrase of ['scrolls','What scrolls?']) add(`Izarod displayed scrolls alias ${phrase}`,'changes/p99-nz-izarod-dialogue/cabwest--Izarod_Fristan.lua',`say('${phrase}');equal(#calls.speech,1);assert(string.find(calls.speech[1],'thrall of bones',1,true))`);
add('Collier factions and depop on success only','changes/p99-am-collier-reward/erudnext-Collier.lua','trade({31828,22570,6949});equal(calls.depops,0);equal(next(calls.factions),nil);trade({31828,22570,6949,6950});faction(223,2);faction(291,-1);faction(230,1);faction(262,-1);faction(273,1);equal(calls.depops,1);assert(string.find(calls.speech[1],"any standard forged weapon",1,true))');
for(const [sister,keywords] of [['Tempi',['possession','haunting','collection']],['Timpi',['detachment','rupturing','requisition','suffering']],['Tompi',['allure','dark paths','acquisition','obligation']]]) {
 const file=`changes/p99-nz-necromancer-words-dialogue/neriaka--X-Ta_${sister}.lua`;
 for(const keyword of keywords) add(`${sister} short/full alias ${keyword}`,file,`say('${keyword}');equal(#calls.speech,1);local short=calls.speech[1];say('Words of ${keyword}');equal(#calls.speech,2);equal(calls.speech[2],short)`);
 for(const word of ['word','words']) add(`${sister} generic ${word} lore`,file,`say('${word}');equal(#calls.speech,1);assert(string.find(string.lower(calls.speech[1]),'components',1,true))`);
 add(`${sister} every displayed task button responds`,file,`say('tasks');local text=calls.speech[1];for phrase in text:gmatch('%[(.-)%]') do local before=#calls.speech;say(phrase);equal(#calls.speech,before+1,'button '..phrase) end`);
}
add('Kaglari exact changed Frogloks delta','changes/p99-am-innoruuk-faction/grobb-Kaglari.lua','trade({13916});faction(251,-10);faction(237,5);faction(308,1)');
add('Baxok added wristbands option','changes/p99-am-gearheart-reward/akanon-Baxok_Curhunter.lua','character.choice=14;trade({13344,99999});reward(2021,1);equal(remaining[99999],1)');
add('Budo four belts pay once and keep three','changes/p99-nz-orc-belts-reward/misty--Deputy_Budo.lua','trade({13916,13916,13916,13916});reward(13024,1);equal(#calls.cash,1);equal(calls.cash[1][3],9);equal(calls.exp,1000);equal(remaining[13916],3);faction(263,5);equal(calls.returns,1)');
const holana='changes/p99-am-karana-clovers/halas-Holana_Oleary.lua';
[15270,15275,15075,15271,15279,15212,15079,15274,15272,15224].forEach((id,i)=>add(`Holana spell option ${id}`,holana,`math.random=function() return 1 end;character.choice=${i+1};trade({13962,99999});reward(${id},1);faction(229,-3);faction(244,-3);faction(336,0);faction(5006,0);equal(remaining[99999],1);${id===15224?"assert(string.find(calls.speech[2],'Endure Fire',1,true));":''}trade({13962});reward(${id},2)`));
add('Holana rejects incomplete offer',holana,'trade({99999});equal(next(calls.rewards),nil);equal(next(calls.factions),nil);equal(remaining[99999],1)');
const weligon='changes/p99-nz-odus-pearls/erudnext--Weligon_Steelherder.lua';
[2104,2106,2108,2111,2112,17003,2101,6012].forEach((id,i)=>add(`Weligon pearl reward option ${id}`,weligon,`character.choice=${i+1};trade({13879,99999});reward(${id},1);equal(calls.cash[1][2],14);equal(remaining[13879],0);equal(remaining[99999],1);trade({13879});reward(${id},2)`));
add('Weligon incomplete pearls unchanged',weligon,'trade({99999});equal(next(calls.rewards),nil);equal(remaining[99999],1)');
const dill='changes/p99-nz-orc-hatchets-rewards/gfaydark--Dill_Fireshine.lua';
[5047,5048,7032,5013,7009,5023].forEach((id,i)=>add(`Dill hatchet reward option ${id}`,dill,`eq.ChooseRandom=function(...) if select('#',...)==6 then return (select(${i+1},...)) else return (select(1,...)) end end;trade({12108,12108,99999});reward(${id},1);equal(remaining[99999],1);trade({12108,12108});reward(${id},2)`));
add('Dill partial hatchet explicitly refunded',dill,'trade({12108,99999});reward(12108,1);equal(remaining[12108],0);equal(remaining[99999],1);equal(#calls.cash,0)');
const byzar='changes/p99-nz-ogre-heads-dialogue/kaladima--Byzar_Bloodforge.lua';
add('Byzar correct and legacy spelling alias',byzar,"say('Zarchoomi');equal(#calls.speech,1);local text=calls.speech[1];say('Zachoomi');equal(calls.speech[2],text)");
// Reviewer cases are executed against current files, never stale embedded source.
// Baseline reproductions are labelled and do not count as proposed-file coverage.
for(const manifest of ['changes/p99-sz-review/behavior-cases.json','changes/p99-tz-review/test-scenarios.json','changes/p99-am-review/runtime-assertions.json','changes/p99-nz-coverage/runtime-assertions.json','changes/p99-af-review/runtime-assertions.json','changes/p99-guild-review/runtime-assertions.json','changes/p99-il-review/runtime-assertions.json','changes/p99-source-review/runtime-assertions.json','changes/p99-armor-review/runtime-assertions.json','changes/p99-trade-surface-review/runtime-assertions.json','changes/p99-ranger-epic-review/runtime-assertions.json','changes/p99-paladin-epic-review/runtime-assertions.json','changes/p99-support-source-review/runtime-assertions.json','changes/p99-conversion-trades/runtime-assertions.json','changes/p99-conversion-ambient/runtime-assertions.json','changes/p99-conversion-world/behavior-cases.json','changes/p99-conversion-era-identity/runtime-assertions.json','changes/p99-final-chain-closure/runtime-assertions.json','changes/p99-final-admission/runtime-assertions.json','changes/p99-final-uncertainty/runtime-assertions.json']) {
 assert.ok(fs.existsSync(path.join(root,manifest)), `Required reviewer manifest is missing: ${manifest}`);
 const document=JSON.parse(read(manifest));
 const records=Array.isArray(document)?document:document.cases;
 for(const record of records) {
  const baselineReproduction=record.coverageKind==='baseline_reproduction';
  const baselineVerification=record.coverageKind==='baseline_verification';
  const baseline=baselineReproduction||baselineVerification;
  const file=record.proposedFile??(baseline?record.file:null);
  assert.ok(file,`Missing source identity: ${manifest}: ${record.name}`);
  assert.ok(baseline? /^(effective|maintained|sources)\//.test(file):file.startsWith('changes/'),`Invalid source category: ${file}`);
  assert.ok(typeof record.assertions==='string'&&record.assertions.trim(),`Missing assertions: ${record.name}`);
  const source=read(file);
  assert.ok(record.sourceSha256||record.source,`Unbound reviewer source: ${record.name}`);
  if(record.sourceSha256) assert.equal(createHash('sha256').update(source).digest('hex'),record.sourceSha256,`Stale case source hash: ${record.name}`);
  if(record.source) assert.equal(source,record.source,`Stale embedded source: ${record.name}`);
  let extra=record.setupExtra??'';
  if(record.setup) {
   const marker='return items;\nend\n';const end=record.setup.lastIndexOf(marker);
   assert.ok(end>=0,`Cannot separate reviewer fixture extension: ${record.name}`);
   extra=record.setup.slice(end+marker.length)+extra;
  }
  if(!baseline) exercisedFiles.add(file);
  cases.push({name:(baselineReproduction?'BASELINE REPRODUCTION: ':baselineVerification?'BASELINE VERIFICATION: ':'Reviewer: ')+record.name,file,baselineReproduction,baselineVerification,source,setup:setup+'\n'+extra,assertions:record.assertions});
 }
}
test('Warden recipe proposal and existing components (static only, no combine execution)',()=>{
 const proposal=JSON.parse(read('changes/p99-nz-tunare-warden.json'));
 const recipe=proposal.rows.find(row=>row.table==='tradeskill_recipe'&&row.after.id===7637).after;
 assert.equal(recipe.enabled,1);assert.equal(recipe.nofail,1);assert.equal(recipe.must_learn,0);assert.equal(recipe.tradeskill,65);
 const rows=fs.readdirSync(path.join(root,'data/tradeskill_recipe_entries')).flatMap(file=>read('data/tradeskill_recipe_entries/'+file).trim().split('\n').filter(Boolean).map(line=>JSON.parse(line))).filter(row=>row.recipe_id===7637);
 assert.deepEqual(rows.filter(row=>row.componentcount>0).map(row=>[row.item_id,row.componentcount]).sort((a,b)=>a[0]-b[0]),[[1594,1],[1595,1],[1596,1],[16552,1]]);
 assert.deepEqual(rows.filter(row=>row.successcount>0).map(row=>[row.item_id,row.successcount]),[[1597,1]]);
});
test('Every non-flavor proposed Lua source has an isolated scenario',()=>{
 const missing=new Set();
 function walk(dir) {
  for(const entry of fs.readdirSync(path.join(root,dir),{withFileTypes:true})) {
   const file=dir+'/'+entry.name;
   if(entry.isDirectory()) walk(file);
   else if(entry.name.endsWith('.json')) {
    const proposal=JSON.parse(read(file));
    if(proposal.format!==1||!proposal.id?.startsWith('p99-')||proposal.id==='p99-combined-audit') continue;
    for(const source of proposal.sources??[]) if(source.proposedFile.endsWith('.lua')&&!/^changes\/p99-conversions-velious-flavor(?:-extra)?\//.test(source.proposedFile)&&!exercisedFiles.has(source.proposedFile)) missing.add(source.proposedFile);
   }
  }
 }
 walk('changes');assert.deepEqual([...missing],[],'New proposed Lua needs focused cases (flavor sources have their own suite)');
});
test('P99 proposed quest handlers: isolated Lua behavior (not game runtime)',t=>{
 const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'p99-behavior-'));t.after(()=>fs.rmSync(tmp,{recursive:true,force:true}));
 const binary=path.join(tmp,'runner');
 execFileSync('go',['build','-o',binary,'../tools/p99-lua-runner.go'],{cwd:path.join(root,'validator'),encoding:'utf8'});
 const output=execFileSync(binary,[],{input:JSON.stringify(cases),encoding:'utf8',maxBuffer:4*1024*1024});
 assert.equal(output.trim().split('\n').length,cases.length);console.log(output.trim());
 if(process.env.P99_TEST_RECEIPT) fs.writeFileSync(process.env.P99_TEST_RECEIPT,JSON.stringify({kind:'isolated-script-behavior-not-game-runtime',completedAt:new Date().toISOString(),scenarios:cases.length,baselineReproductions:cases.filter(c=>c.baselineReproduction).length,baselineVerifications:cases.filter(c=>c.baselineVerification).length,proposedSourceScenarios:cases.filter(c=>!c.baselineReproduction&&!c.baselineVerification).length,cases:cases.map(c=>({name:c.name,file:c.file,sourceSha256:createHash('sha256').update(c.source).digest('hex'),baselineReproduction:!!c.baselineReproduction,baselineVerification:!!c.baselineVerification}))},null,2)+'\n');
});
