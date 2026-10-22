// Hash-bound structural checks. These do not prove runtime inventory or UI behavior.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const json=p=>JSON.parse(read(p));
const hash=s=>createHash('sha256').update(s).digest('hex');
const proposal=json('changes/p99-armor-review/proposal.json');
const pages=json('changes/p99-armor-review/page-review.json');
const evidence=json('changes/p99-armor-review/evidence.json');
assert.equal(pages.length,11);assert.equal(new Set(pages.map(p=>p.title)).size,11);
assert.equal(proposal.rows.length,7);assert.equal(proposal.sources.length,7);
assert.equal(proposal.baseManifestSha256,hash(read('manifest.json')));
const tradeWithoutSpeech=s=>s.split('function event_trade(e)')[1].split('\n').filter(line=>!/^\s*e\.self:(?:Say|Emote)\(/.test(line)).join('\n');
for(const row of proposal.rows) {
 assert.equal(row.table,'quests');
 assert.deepEqual({...row.after,lua_content:row.before.lua_content},row.before);
 assert.equal(tradeWithoutSpeech(row.before.lua_content),tradeWithoutSpeech(row.after.lua_content),'Only completion speech can change in trade handler');
 const target=`maintained/lua/converted-perl/${row.after.zone}/${row.after.name}.lua`;
 const s=proposal.sources.find(s=>s.target===target);assert.ok(s,target);
 assert.equal(s.beforeSha256,hash(read(s.target)));assert.equal(s.afterSha256,hash(read(s.proposedFile)));
 assert.equal(read(s.target),row.before.lua_content);assert.equal(read(s.proposedFile),row.after.lua_content);
}
const items=new Map(fs.readdirSync(path.join(root,'data/items')).filter(n=>n.endsWith('.ndjson')).flatMap(n=>read('data/items/'+n).trim().split('\n').filter(Boolean).map(JSON.parse)).map(r=>[r.id,r]));
const norm=s=>s.trim().replace(/\s+/g,' ').toLowerCase();
let count=0;
for(const page of pages) {
 assert.equal(page.full_cached_page_read,true);assert.equal(page.source_branch_audit.status,'full_mapped_sources_read');
 for(const ev of [page.evidence,page.npc_evidence])assert.equal(hash(read(ev.cachePath)),ev.sha256,ev.title);
 const source=page.sources[0];assert.equal(hash(read(source.path)),source.sha256);for(const s of source.readSourceHashes)assert.equal(hash(read(s.file)),s.sha256);
 const checklist=read(page.evidence.cachePath).split('== Checklist ==')[1].split('{{End}}')[0];
 const triples=[...checklist.matchAll(/^\*\[\[([^\]]+)\]\]\s*\n:\*\[\[([^\]]+)\]\]\s*\n:\*(\d+)x \[\[([^\]]+)\]\]/gm)];
 assert.equal(triples.length,7);
 const lua=read(source.path);const trades=[...lua.matchAll(/(?:if|elseif) item_lib\.check_turn_in\(e\.trade, \{([^}]+)\}\) then -- ([^\n]+)\n(.*?)(?=  elseif |  end\n  -- Return)/gs)];assert.equal(trades.length,7);
 for(let i=0;i<7;i++) {
  const [,reward,armor,quantity,gem]=triples[i],ids=[...trades[i][1].matchAll(/item\d = (\d+)/g)].map(m=>Number(m[1]));
  const rid=Number(trades[i][3].match(/SummonItem\((\d+)\)/)[1]);
  assert.equal(ids.length,4);assert.equal(Number(quantity),3);
  assert.equal(norm(items.get(ids[0]).Name),norm(armor));for(const id of ids.slice(1))assert.equal(norm(items.get(id).Name),norm(gem));
  assert.equal(norm(items.get(rid).Name),norm(reward));assert.equal(norm(trades[i][2]),norm(reward));assert.equal(page.component_reward_check[i].reward.id,rid);count++;
 }
}
assert.equal(count,77);
for(const file of evidence.tableInputs)assert.equal(hash(read(file.file)),file.sha256);
assert.equal(hash(read(evidence.existingComponentAudit.file)),evidence.existingComponentAudit.sha256);
assert.equal(hash(read(evidence.levelRequirementEvidence.cachePath)),evidence.levelRequirementEvidence.sha256);
assert.ok(read(evidence.levelRequirementEvidence.cachePath).includes('no level requirement'));
console.log(JSON.stringify({pass:true,pages:pages.length,independentlyMatchedExchanges:count,dialogueOnlyProposalRows:proposal.rows.length,limits:'Static evidence/source checks only, not acquisition, inventory settlement or UI.'}));
