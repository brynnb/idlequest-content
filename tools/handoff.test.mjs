import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fixture } from './test-fixture.mjs';
import { handoff, assertPinnedWorktree } from './handoff.mjs';
import { hash } from './dataset.mjs';
import { fileURLToPath } from 'node:url';

test('pinned handoff previews, refuses stale source and stages only reviewed files',async t=>{
  const f=await fixture(t);
  const target='reference/server/internal/quest/content_exclusions.json';
  const before='{"quests":{},"p99_audit":{}}\n';
  const after='{"quests":{},"p99_audit":{"test":{"note":"Reviewed fixture"}}}\n';
  await f.write(target,before);await f.save();
  const luaTarget='maintained/lua/idlequest-authored/freportn/Reviewer.lua';
  const luaBefore='function event_trade(e) end\n', luaAfter=luaBefore+'-- reviewed\n';
  await f.write(luaTarget,luaBefore);
  const row={id:1,zone:'freportn',name:'Reviewer',lua_content:luaBefore,has_say_event:0,enabled:1};
  Object.assign(f.manifest.tables.quests,{columns:Object.keys(row),primaryKey:['id'],rows:1,shards:['data/quests/0.ndjson']});
  await f.write('schema/quests.sql',"CREATE TABLE `quests` (\n  `id` int NOT NULL,\n  `zone` varchar(64) NOT NULL,\n  `name` varchar(128) NOT NULL,\n  `lua_content` mediumtext,\n  `has_say_event` tinyint,\n  `enabled` tinyint,\n  PRIMARY KEY (`id`)\n) ENGINE=InnoDB;\n");
  await f.write('data/quests/0.ndjson',JSON.stringify(row)+'\n');await f.save();
  await fs.mkdir(path.join(f.root,'changes'),{recursive:true});
  await fs.writeFile(path.join(f.root,'changes/ledger.json'),after);
  await fs.writeFile(path.join(f.root,'changes/reviewer.lua'),luaAfter);
  await fs.writeFile(path.join(f.root,'changes/proposal.json'),JSON.stringify({
    format:1,id:'ledger-review',summary:'Fixture review record',baseManifestSha256:hash(await fs.readFile(path.join(f.root,'manifest.json'))),
    evidence:[{url:'https://wiki.project1999.com/Ton_Twostring',note:'Test only'}],rows:[{table:'quests',before:row,after:{...row,lua_content:luaAfter}}],
    sources:[{target,beforeSha256:hash(before),afterSha256:hash(after),proposedFile:'changes/ledger.json'},
      {target:luaTarget,beforeSha256:hash(luaBefore),afterSha256:hash(luaAfter),proposedFile:'changes/reviewer.lua'}],
  }));
  const git=args=>execFileSync('git',['-C',f.root,...args],{encoding:'utf8'}).trim();
  git(['init','-q','-b','codex/test']);git(['config','user.name','Content Test']);git(['config','user.email','content-test@example.invalid']);
  git(['add','.']);git(['commit','-qm','test fixture']);const revision=git(['rev-parse','HEAD']);
  const destination=await fs.mkdtemp('/var/tmp/idlequest-handoff-target-');
  t.after(()=>fs.rm(destination,{recursive:true,force:true}));
  await fs.mkdir(path.join(destination,'server/migrations'),{recursive:true});
  await fs.writeFile(path.join(destination,'server/migrations/152_existing.sql'),'-- unchanged');
  await fs.mkdir(path.join(destination,'server/internal/quest'),{recursive:true});
  const here=path.dirname(fileURLToPath(import.meta.url));
  let checker,normalizer;
  try {
    checker=await fs.readFile(path.resolve(here,'../../server/cmd/check-content-lua/main.go'),'utf8');
    normalizer=await fs.readFile(path.resolve(here,'../../server/internal/questluasource/source.go'),'utf8');
  } catch(error) {
    if(error.code!=='ENOENT') throw error;
    checker=(await fs.readFile(path.resolve(here,'../validator/main.go'),'utf8')).replace('idlequest-content-validator/questluasource','idlequest/internal/questluasource');
    normalizer=await fs.readFile(path.resolve(here,'../validator/questluasource/source.go'),'utf8');
  }
  await fs.mkdir(path.join(destination,'server/cmd/check-content-lua'),{recursive:true});
  await fs.mkdir(path.join(destination,'server/internal/questluasource'),{recursive:true});
  await fs.writeFile(path.join(destination,'server/cmd/check-content-lua/main.go'),checker);
  await fs.writeFile(path.join(destination,'server/internal/questluasource/source.go'),normalizer);
  await fs.writeFile(path.join(destination,'server/go.mod'),'module idlequest\n\ngo 1.23\n\nrequire github.com/yuin/gopher-lua v1.1.1\n');
  // Reuse the checked-in dependency pin in either the game or standalone repo.
  let sums;try{sums=await fs.readFile(path.resolve(here,'../../server/go.sum'),'utf8');}catch{sums=await fs.readFile(path.resolve(here,'../validator/go.sum'),'utf8');}
  await fs.writeFile(path.join(destination,'server/go.sum'),sums.split('\n').filter(s=>s.startsWith('github.com/yuin/gopher-lua v1.1.1')).join('\n')+'\n');
  const luaDestination=path.join(destination,'server/internal/quest/overrides/lua/idlequest-authored/freportn/Reviewer.lua');
  await fs.mkdir(path.dirname(luaDestination),{recursive:true});await fs.writeFile(luaDestination,luaBefore);
  const source=path.join(destination,'server/internal/quest/content_exclusions.json');
  await fs.writeFile(source,before);
  const preview=await handoff(f.root,'changes/proposal.json',destination,revision);
  assert.equal(preview.written,false);assert.equal(await fs.readFile(source,'utf8'),before);
  assert.equal(preview.syntax.checked,1);
  assert.equal(await fs.readFile(luaDestination,'utf8'),luaBefore);
  assert.equal((await fs.readdir(path.join(destination,'server/migrations'))).length,1);
  await fs.writeFile(source,'newer local fix');
  await assert.rejects(handoff(f.root,'changes/proposal.json',destination,revision,{write:true}),/Stale IdleQuest source/);
  assert.equal((await fs.readdir(path.join(destination,'server/migrations'))).length,1);
  await fs.writeFile(source,before);
  await assert.rejects(handoff(f.root,'changes/proposal.json',destination,'0'.repeat(40)),/revision does not match/);
  await fs.writeFile(path.join(f.root,'changes/uncommitted'),'no');
  await assert.rejects(assertPinnedWorktree(f.root,revision),/clean and committed/);
  await fs.unlink(path.join(f.root,'changes/uncommitted'));
  const staged=await handoff(f.root,'changes/proposal.json',destination,revision,{write:true});
  assert.equal(staged.written,true);assert.equal(await fs.readFile(source,'utf8'),after);
  assert.equal(await fs.readFile(luaDestination,'utf8'),luaAfter);
  const receipt=JSON.parse(await fs.readFile(path.join(destination,staged.receipt),'utf8'));
  assert.equal(receipt.revision,revision);
  assert.equal(receipt.migrationSha256,hash(await fs.readFile(path.join(destination,staged.migration))));
  await assert.rejects(handoff(f.root,'changes/proposal.json',destination,revision,{write:true}),/Stale IdleQuest source/);
  assert.equal(await fs.readFile(path.join(destination,'server/migrations/152_existing.sql'),'utf8'),'-- unchanged');
});
