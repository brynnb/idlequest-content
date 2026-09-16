import test from 'node:test';
import assert from 'node:assert/strict';
import { scriptKey, exportEffectiveScripts, exportWikiIndex, portableWikiState } from './source-audit.mjs';
import { createHash } from 'node:crypto';
import fs from 'node:fs/promises';

test('wiki resume paths are portable and unexpected paths fail closed', () => {
  const state = { pages: { Example: { rawPath:'/private-checkout/raw-pages/example.wiki', metaPath:'raw-pages/example.json', status:'cached' } } };
  const clean = JSON.parse(portableWikiState(JSON.stringify(state)));
  assert.deepEqual(clean.pages.Example, {rawPath:'raw-pages/example.wiki', metaPath:'raw-pages/example.json', status:'cached'});
  assert.equal(portableWikiState(JSON.stringify(clean)), portableWikiState(JSON.stringify(state)));
  assert.throws(()=>portableWikiState(JSON.stringify({pages:{Example:{rawPath:'/private-checkout/unexpected'}}})), /Unrecognized/);
});

test('offline wiki export preserves bytes, portable paths and rejects corrupt pages', async t => {
  const root = await fs.mkdtemp('/var/tmp/idlequest-wiki-export-');
  t.after(() => fs.rm(root, { recursive: true, force: true }));
  const cache = `${root}/data/p99wiki-project1999-api-cache`;
  await fs.mkdir(`${cache}/raw-pages`, { recursive: true });
  await fs.mkdir(`${cache}/npc-pages`);
  const body = '{{NPC|name=Example}}\n';
  await fs.writeFile(`${cache}/raw-pages/example.wiki`, body);
  await fs.writeFile(`${cache}/raw-pages/example.json`, JSON.stringify({ title:'Example', url:'https://wiki.project1999.com/Example', sha256:createHash('sha256').update(body).digest('hex') }));
  const output = new Map();
  await exportWikiIndex(root, async (p,b) => output.set(p,b));
  const [entry] = JSON.parse(output.get('reference/p99-evidence-index.json'));
  assert.equal(output.get(entry.cachePath).toString(), body);
  await fs.writeFile(`${cache}/raw-pages/example.wiki`, 'corrupted');
  await assert.rejects(exportWikiIndex(root, async()=>{}), /hash mismatch/);
});

test('source identity follows header override without flattening # or underscores', () => {
  assert.equal(scriptKey('maintained/lua/converted-perl/citymist/Neh_Ashiir.lua', "-- name: #Neh`Ashiir\nfunction event_trade(e) end"), 'citymist/#Neh`Ashiir');
  assert.equal(scriptKey('maintained/lua/converted-perl/citymist/Neh_Ashiir.lua', "function event_say(e) end\n-- name: ignored"), 'citymist/Neh_Ashiir');
});

test('effective source keeps database drift, missing bodies and aliases explicit', async () => {
  const hash = text => createHash('sha256').update(text).digest('hex');
  const output = new Map();
  const lookup = new Map([['citymist/#Neh`Ashiir', [{ file: 'maintained/lua/converted-perl/citymist/Neh.lua', sha256: hash('old'), maintained: true }]]]);
  const index = await exportEffectiveScripts([
    { id:1,zone:'citymist',name:'#Neh`Ashiir',lua_content:'new',enabled:1 },
    { id:2,zone:'citymist',name:'../odd',lua_content:null,enabled:0 },
  ],lookup,async (file, text)=>output.set(file,text));
  assert.equal(index.find(x=>x.id===1).sourceStatus,'database-differs');
  const absent = index.find(x=>x.id===2);
  assert.equal(absent.sourceStatus,'no-lua-body');
  assert.equal(absent.file.includes('../'),false);
  assert.equal(output.get(index.find(x=>x.id===1).file),'new');
});
