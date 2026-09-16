import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fixture } from './test-fixture.mjs';
import { hash } from './dataset.mjs';
import { readProposal } from './proposal.mjs';

test('module proposals bind source, effective content and persistent enabled state',async t=>{
  const f=await fixture(t);
  const before={module_name:'helper',lua_content:'return {}',enabled:1};
  const content='-- enabled: false\nreturn {reviewed=true}';
  const after={...before,lua_content:content,enabled:0};
  Object.assign(f.manifest.tables.quest_lua_modules,{columns:Object.keys(before),primaryKey:['module_name'],rows:1,shards:['data/quest_lua_modules/0.ndjson']});
  await f.write('data/quest_lua_modules/0.ndjson',JSON.stringify(before)+'\n');await f.save();
  await fs.mkdir(path.join(f.root,'changes'));await fs.writeFile(path.join(f.root,'changes/helper.lua'),content);
  const p={format:1,id:'module-review',summary:'Test',baseManifestSha256:hash(await fs.readFile(path.join(f.root,'manifest.json'))),evidence:[{url:'https://wiki.project1999.com/',note:'fixture'}],rows:[{table:'quest_lua_modules',before,after}],sources:[{target:'maintained/modules/helper.lua',beforeSha256:null,proposedFile:'changes/helper.lua',afterSha256:hash(content)}]};
  const save=()=>fs.writeFile(path.join(f.root,'changes/test.json'),JSON.stringify(p));
  await save();assert.equal((await readProposal(f.root,'changes/test.json')).proposal.sources.length,1);
  p.rows[0].after.enabled=1;await save();await assert.rejects(readProposal(f.root,'changes/test.json'),/Enabled state/);
  p.rows[0].after.enabled=0;p.sources=[];await save();await assert.rejects(readProposal(f.root,'changes/test.json'),/requires maintained source/);
});
