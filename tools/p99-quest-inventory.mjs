import fs from 'node:fs/promises';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { scriptKey } from './source-audit.mjs';
import { sourceEnabled } from './source-policy.mjs';

const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');
const sort = xs => xs.sort((a,b)=>a.localeCompare(b,'en'));
const count = xs => Object.fromEntries([...new Set(xs)].sort().map(k=>[k,xs.filter(v=>v===k).length]));
const normalizeLink = s => s.replace(/^#+/,'').replaceAll('_',' ').trim().toLowerCase();
async function walk(root, relative='') {
  const out=[];
  for (const ent of await fs.readdir(path.join(root,relative),{withFileTypes:true})) {
    const p=path.posix.join(relative,ent.name);
    if (ent.isDirectory()) out.push(...await walk(root,p));
    else if (ent.isFile()) out.push(p);
  }
  return sort(out);
}
export function upstreamIdentity(file) {
  const parts=file.split('/');
  if (!['.pl','.lua'].includes(path.extname(file))) return null;
  const [zone,version]=parts;
  if (['plugins','lua_modules','utility'].includes(zone)) return null;
  const eligible=parts.length===2 || parts.length===3 && version==='v0';
  return {key:`${zone}/${path.basename(file,path.extname(file))}`, zone,
    version:parts.length===2?'root':parts.slice(1,-1).join('/'), eligible};
}
export function resolveCacheMember(member, extension) {
  const match=String(member).match(new RegExp(`(?:^|/)(raw-pages/[^/]+\\.${extension})$`));
  if (!match || match[1].includes('..')) throw new Error(`Unsafe cache member: ${member}`);
  return match[1];
}
export function verifyPage(title, entry, metadata, bytes) {
  if (!['cached','fetched'].includes(entry.status)) throw new Error(`Page not cached: ${title}`);
  if (metadata.title!==title) throw new Error(`Cache title mismatch: ${title}`);
  if (metadata.bytes!==bytes.length) throw new Error(`Cache byte mismatch: ${title}`);
  if (metadata.sha256!==sha256(bytes)) throw new Error(`Cache hash mismatch: ${title}`);
}
function sameNameEffectiveLua(effective,name) {
  return effective.filter(e=>e.sourceStatus!=='no-lua-body'&&normalizeLink(e.key.split('/')[1])===normalizeLink(name)).map(e=>({key:e.key,file:e.file,enabled:e.enabled}));
}
export async function inventory(root) {
  const read=p=>fs.readFile(path.join(root,p),'utf8');
  const json=async p=>JSON.parse(await read(p));
  const manifest=await json('manifest.json');
  const zoneFile='changes/p99-audit/p99_zones.json';
  const zoneBytes=await read(zoneFile), zones=new Set(JSON.parse(zoneBytes));
  const ledger=await json('reference/server/internal/quest/content_exclusions.json');
  const npcLedger=await json('reference/server/internal/contentscope/npc_exclusions.json');
  const effective=await json('reference/effective-quests-index.json');
  const effectiveMap=new Map(effective.map(e=>[e.key,e]));
  if(effectiveMap.size!==effective.length) throw new Error('Duplicate effective quest key');
  const audit=ledger.p99_audit;
  const pageManifest=await json('reference/p99-wiki/quest-related-pages.json');
  const state=await json('reference/p99-wiki/raw-pages-state.json');
  const declared=[...pageManifest.highConfidencePages.map(p=>({...p,corpus:'high-confidence'})),...pageManifest.titleReviewCandidates.map(p=>({...(typeof p==='string'?{title:p}:p),corpus:'title-review'}))];
  const pages=[], linkPages=new Map();
  for(const p of declared) {
    const entry=state.pages[p.title];
    if(!entry) throw new Error(`Missing page state: ${p.title}`);
    const raw=resolveCacheMember(entry.rawPath,'wiki'), meta=resolveCacheMember(entry.metaPath,'json');
    const metadata=await json(`reference/p99-wiki/${meta}`);
    const bytes=await fs.readFile(path.join(root,'reference/p99-wiki',raw));
    verifyPage(p.title,entry,metadata,bytes);
    const links=new Set([...bytes.toString().matchAll(/\[\[([^\]|#]+)/g)].map(m=>normalizeLink(m[1])));
    for(const link of links) {if(!linkPages.has(link)) linkPages.set(link,[]);linkPages.get(link).push(p.title);}
    const row=audit[p.title];
    pages.push({title:p.title,corpus:p.corpus,cachePath:`reference/p99-wiki/${raw}`,sha256:metadata.sha256,bytes:bytes.length,url:metadata.url,fetchedAt:metadata.fetchedAt,revision:metadata.revid??metadata.revisionId??null,
      reviewStatus:row?.review_status??'not-recorded',matchStatus:row?.match_status??'not-recorded',scope:row?.scope??'not-recorded',localQuestKeys:row?.local_quest_keys??[],
      verification:row?.verification??null,scopeReassessment:row?.scope_reassessment??null});
  }
  if(new Set(pages.map(p=>p.title)).size!==pages.length) throw new Error('Duplicate declared page');
  const rawFiles=await fs.readdir(path.join(root,'reference/p99-wiki/raw-pages'));
  const integrity={declared:pages.length,stateEntries:Object.keys(state.pages).length,wikiFiles:rawFiles.filter(p=>p.endsWith('.wiki')).length,metadataFiles:rawFiles.filter(p=>p.endsWith('.json')).length,verified:pages.length};
  if(Object.values(integrity).some(n=>n!==1135)) throw new Error(`Unexpected corpus counts: ${JSON.stringify(integrity)}`);
  const sources=[], supportFiles=[];
  for(const file of await walk(path.join(root,'sources/projecteq'))) {
    const id=upstreamIdentity(file);if(!id){if(['.lua','.pl'].includes(path.extname(file)))supportFiles.push({file:`sources/projecteq/${file}`,language:path.extname(file).slice(1),classification:'support-module-not-npc-script',sha256:sha256(await fs.readFile(path.join(root,`sources/projecteq/${file}`)))});continue;}
    const source=`sources/projecteq/${file}`,text=await fs.readFile(path.join(root,source));
    sources.push({...id,file:source,language:path.extname(file).slice(1),sha256:sha256(text),p99Zone:zones.has(id.zone)});
  }
  const maintained=[];
  for(const file of await walk(path.join(root,'maintained/lua'))) {
    if(!file.endsWith('.lua'))continue;
    const source=`maintained/lua/${file}`,text=await read(source),key=scriptKey(source,text);
    maintained.push({key,file:source,enabled:sourceEnabled(text),sha256:sha256(text),category:file.split('/')[0],p99Zone:zones.has(key.split('/')[0])});
  }
  const maintainedMap=new Map();
  for(const row of maintained) {if(maintainedMap.has(row.key))throw new Error(`Duplicate maintained key: ${row.key}`);maintainedMap.set(row.key,row);}
  const upstreamLua=new Map();
  for(const row of sources.filter(s=>s.language==='lua'&&s.eligible)) {if(upstreamLua.has(row.key))throw new Error(`Duplicate eligible upstream Lua key: ${row.key}`);upstreamLua.set(row.key,row);}
  const auditKeys=new Map();
  for(const [title,row] of Object.entries(audit)) for(const key of row.local_quest_keys??[]) {if(!auditKeys.has(key))auditKeys.set(key,[]);auditKeys.get(key).push(title);}
  const patterns=npcLedger.name_patterns.map(p=>new RegExp(p.pattern));
  const perl=sources.filter(s=>s.language==='pl').map(s=>{
    const e=effectiveMap.get(s.key),m=maintainedMap.get(s.key),u=upstreamLua.get(s.key),ex=ledger.quests[s.key];
    const name=s.key.split('/')[1];
    const npcExclusions=[...(npcLedger.npcs??[]),...(npcLedger.additional_npcs??[])].filter(n=>n.zone===s.zone&&(n.name===name||String(n.id)===name));
    const p99PageMentions=sort(linkPages.get(normalizeLink(name))??[]);
    const luaAvailable=Boolean(m||u||e&&e.sourceStatus!=='no-lua-body');
    let classification=!s.eligible?'non-imported-version':!s.p99Zone?'outside-p99-zone':ex?'explicit-quest-exclusion':patterns.some(p=>p.test(name))||npcExclusions.length?'explicit-npc-policy':luaAvailable?'lua-available':p99PageMentions.length?'wiki-linked-missing-lua-review':'unlinked-missing-lua-review';
    return {...s,classification,luaAvailable,effective:e?{enabled:e.enabled,sourceStatus:e.sourceStatus,file:e.file}:null,maintained:m?.file??null,upstreamLua:u?.file??null,exclusion:ex??null,npcExclusions,auditPages:auditKeys.get(s.key)??[],p99PageMentions};
  });
  const npcEvidence=await json('reference/p99-evidence-index.json');
  const npcByName=new Map();
  for(const e of npcEvidence.filter(e=>e.cachePath.includes('/npc-pages/'))) {
    const name=normalizeLink(e.title);if(!npcByName.has(name))npcByName.set(name,[]);npcByName.get(name).push(e);
  }
  const missingLuaTriage=[];
  for(const row of perl.filter(p=>p.classification.endsWith('missing-lua-review'))) {
    const text=await read(row.file), lines=text.split(/\r?\n/);
    const code=lines.filter(l=>!l.trim().startsWith('#')).join('\n');
    const events=sort([...new Set([...code.matchAll(/sub\s+(EVENT_\w+)/g)].map(m=>m[1]))]);
    const questCalls=sort([...new Set([...code.matchAll(/quest::(\w+)/g)].map(m=>m[1]))]);
    const pluginCalls=sort([...new Set([...code.matchAll(/plugin::(\w+)/g)].map(m=>m[1]))]);
    const name=row.key.split('/')[1], normalized=normalizeLink(name);
    const evidence=[];
    for(const npc of npcByName.get(normalized)??[]) {
      const bytes=await fs.readFile(path.join(root,npc.cachePath));
      if(sha256(bytes)!==npc.sha256)throw new Error(`NPC evidence hash mismatch: ${npc.cachePath}`);
      const t=bytes.toString();
      evidence.push({title:npc.title,cachePath:npc.cachePath,url:npc.url,sha256:npc.sha256,eraTags:[...new Set([...t.matchAll(/\{\{([^{}|]*?Era)\b/g)].map(m=>m[1]))],zone:(t.match(/\|\s*zone\s*=([^\n]+)/i)??[])[1]?.trim()??null,doesNotExist:/\{\{\s*(?:DoesNotExist|Does not exist|NotInGame)/i.test(t)});
    }
    const flags=[];
    const rules=[['task-system',/quest::(?:is.?task|updatetask|assigntask|taskselector|failtask)/i],['ldon-system',/lost_dungeons_of_norrath|addldonpoints|LDoN|Wayfarers Brotherhood/i],['epic-1.5-or-2.0',/epic\s*(?:1\.5|2\.0)/i],['holiday-event',/halloween|trick.or.treat|Jack.o.Lantern|great.pumpkin|Eve.Hallows/i],['later-newbie-armor',/newbie armor|newbie quest|armor of the|training armor/i],['soulbinder-mechanic',/soulbind|bind_me/i],['player-event',/^player$/i]];
    for(const [flag,pattern] of rules) {const search=flag==='player-event'?name:text;if(pattern.test(search))flags.push({flag,sourceLines:lines.flatMap((line,i)=>pattern.test(line)?[{line:i+1,text:line.trim().slice(0,280)}]:[]).slice(0,8)});}
    const onlySpeech=questCalls.every(c=>['say','emote','shout','me'].includes(c)) && pluginCalls.every(c=>c==='return_items') && !/\$(?:client|npc|entity_list)->/.test(code);
    const mechanism=events.length===0?'no-event-handler':name==='player'?'player-event':onlySpeech?'speech-and-return-items-only':questCalls.some(c=>['summonitem','exp','faction','givecash','handin'].includes(c))||pluginCalls.some(c=>/check_handin|takeItems/.test(c))?'handin-reward-or-progression':'world-event-or-service';
    const sameNameLua=sameNameEffectiveLua(effective,name).filter(e=>e.key!==row.key);
    let disposition=events.length===0?'empty-or-comment-only-no-conversion-needed':flags.some(f=>['task-system','ldon-system','epic-1.5-or-2.0','holiday-event'].includes(f.flag))?'later-system-or-event-evidence-review-do-not-bulk-convert':onlySpeech&&evidence.length?'p99-npc-flavor-conversion-candidate':evidence.length?'p99-npc-mechanic-review-required':'unresolved-no-cached-npc-name-match';
    missingLuaTriage.push({key:row.key,file:row.file,sha256:row.sha256,classification:row.classification,events,questCalls,pluginCalls,mechanism,disposition,sourceFlags:flags,npcEvidence:evidence,sameNameLua,questPages:row.p99PageMentions,limits:'Static extraction and NPC-name evidence only. NPC presence does not establish the era of its Perl branches. Alias matches are never merged automatically.'});
  }
  const manualEventDispositions=await json('changes/p99-audit/manual-event-dispositions.json');
  for(const row of manualEventDispositions) {if(sha256(await fs.readFile(path.join(root,row.source)))!==row.sha256)throw new Error(`Stale manual review: ${row.key}`);}
  const pageLedger=Object.entries(audit).map(([title,row])=>({title,...row}));
  const effectiveRows=effective.map(e=>({...e,p99Zone:zones.has(e.key.split('/')[0]),questExclusion:ledger.quests[e.key]??null}));
  return {schemaVersion:1,provenance:{baselineManifest:"manifest.json",scopeFile:zoneFile,scopeSha256:sha256(zoneBytes),method:'Exact runtime keys preserved. root/v0 upstream only; maintained name headers honored. Wiki mentions are discovery leads, not proof of same actor or in-era behavior. Snapshot inventory, not gameplay or full parity verification.'},
    summary:{zones:zones.size,corpus:integrity,perlScripts:perl.length,allPerlFiles:perl.length+supportFiles.filter(p=>p.language==='pl').length,supportFiles:supportFiles.length,perlClassifications:count(perl.map(p=>p.classification)),p99PerlClassifications:count(perl.filter(p=>p.p99Zone&&p.eligible).map(p=>p.classification)),sourceLua:sources.filter(p=>p.language==='lua').length,maintained:maintained.length,maintainedCategories:count(maintained.map(p=>p.category)),effective:effective.length,effectiveStatus:count(effective.map(p=>p.sourceStatus)),p99Effective:effectiveRows.filter(p=>p.p99Zone).length,p99EffectiveStatus:count(effectiveRows.filter(p=>p.p99Zone).map(p=>p.sourceStatus)),ledgerEntries:pageLedger.length,ledgerReviewStatuses:count(pageLedger.map(p=>p.review_status)),pageReviewStatuses:count(pages.map(p=>p.reviewStatus)),manualEventDispositions:count(manualEventDispositions.map(p=>p.disposition)),missingLuaTriageMechanisms:count(missingLuaTriage.map(p=>p.mechanism)),missingLuaTriageDispositions:count(missingLuaTriage.map(p=>p.disposition)),questExclusions:Object.keys(ledger.quests).length},zones:sort([...zones]),supportFiles,perl,missingLuaTriage,manualEventDispositions,maintained,effective:effectiveRows,pages,pageLedger};
}
export function markdown(report) {
  const s=report.summary;
  const leads=report.perl.filter(p=>p.classification==='wiki-linked-missing-lua-review');
  return `# P99 quest corpus inventory\n\nReproduce from repository root: \`node tools/p99-quest-inventory.mjs . --write\`. Regression tests: \`node --test changes/p99-audit/inventory.test.mjs\`.\n\n## Scope and evidence\n\nThe declared ${s.zones}-zone audit corpus is listed in p99_zones.json and independently bound to public exported zone rows in scope-provenance.json. It is an audit scope, not a claim of current runtime admission policy. The scope file hash is in inventory.json. No numeric IDs or expansion flags infer era. The full ${s.corpus.verified}-page preserved corpus was checked for manifest membership, title, byte length and SHA-256. No wiki requests were needed.\n\nInventory is exhaustive for these files, not a claim of exhaustive gameplay review. All ${s.ledgerEntries} audit ledger entries and their verification caveats are retained in inventory.json. Missing Lua, enabled state and page completion are independent. Historical reviewed status does not prove rendered or connected-chain verification.\n\n## Counts\n\n- Perl NPC/event scripts: ${s.perlScripts} (${s.allPerlFiles} total Perl files including support modules); upstream Lua files: ${s.sourceLua}; maintained Lua: ${s.maintained}.\n- Effective rows: ${s.effective}; P99-zone effective rows: ${s.p99Effective}.\n- Page review statuses: ${JSON.stringify(s.pageReviewStatuses)}.\n- P99-zone Perl classifications: ${JSON.stringify(s.p99PerlClassifications)}.\n- All Perl classifications: ${JSON.stringify(s.perlClassifications)}.\n\n## Missing-Lua discovery leads\n\nThese ${leads.length} exact keys have no effective, maintained or eligible upstream Lua, are not explicitly quest/NPC-policy excluded, and have a normalized NPC-name link in a cached quest page. A link may name loot, merchant, flavor dialogue, an alias, or later-era behavior. It is NOT automatic conversion approval. Original Perl remains immutable. Numeric and hash-prefixed keys must not be merged. Existing Lua corrections must not be overwritten.\n\n${leads.map(p=>`- ${p.key}: ${p.p99PageMentions.join('; ')}. Source: ${p.file}`).join('\n')}\n\n## Missing-Lua source and NPC triage\n\nAll ${report.missingLuaTriage.length} unexcluded missing-Lua keys have source event/call extraction and verified cached NPC evidence in missing-lua-triage.json. These are discovery classifications, never completed parity reviews. Same-name Lua records are alias leads only. The ${report.manualEventDispositions.length} manually inspected Kithicor/Unrest/Cazic-Thule unlinked scripts have individual source hashes, decisions and uncertainties in manual-event-dispositions.json; generation fails if any reviewed source changed. This separates explicit Halloween/task/Beastlord content and empty handlers from genuine P99 NPC movement and unresolved revamp mechanics. No blanket zone exclusion was applied. The full bodies of all 59 were read, not sampled.\n\n## Complete machine-readable work queue\n\nSee inventory.json: every Perl NPC/event script has an exact key, source hash, zone/version eligibility, classification, Lua availability, policy exclusion and page leads. Every declared wiki page has integrity/provenance and ledger status, including title-review candidates without ledger coverage. Unlinked missing-Lua rows require manual era/content research rather than bulk conversion; outside-zone/version rows are reference-only relative to this scope. Quest exclusions retain their reasons and reviewed_override exceptions. Support modules/plugins are listed independently in supportFiles and are not mistaken for NPC scripts. No ledger states were promoted by this report.\n`;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href) {
  const root=path.resolve(process.argv[2]??'.'),report=await inventory(root);
  if(process.argv.includes('--write')) {
    await fs.mkdir(path.join(root,'changes/p99-audit'),{recursive:true});
    await fs.writeFile(path.join(root,'changes/p99-audit/inventory.json'),JSON.stringify(report,null,2)+'\n');
    await fs.writeFile(path.join(root,'changes/p99-audit/inventory.md'),markdown(report));
    await fs.writeFile(path.join(root,'changes/p99-audit/missing-lua-triage.json'),JSON.stringify(report.missingLuaTriage,null,2)+'\n');
  }
  console.log(JSON.stringify(report.summary,null,2));
}
