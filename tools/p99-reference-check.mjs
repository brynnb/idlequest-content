// Conservative lexical diagnostic, not runtime reachability or acquisition proof.
import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {findProposals,mergeProposals} from './p99-merge-proposals.mjs';

export function literalReferences(source) {
 const result=[];
 for(const [kind,method,pattern] of [
  ['item','handin',/\bitem\d*\s*=\s*(\d+)/g],
  ['item','SummonItem',/:SummonItem\(\s*(\d+)/g],
  ['item','QuestReward',/:QuestReward\([^,\n]+,\s*[^,\n]+,\s*[^,\n]+,\s*[^,\n]+,\s*[^,\n]+,\s*(\d+)\s*[,)]/g],
  ['item','ground_object',/\bcreate_ground_object\(\s*(\d+)/g],
  ['faction','Faction',/:Faction\(\s*(\d+)/g],
 ])for(const match of source.matchAll(pattern)){
  const id=Number(match[1]);if(id)result.push({kind,method,id,line:source.slice(0,match.index).split('\n').length});
 }
 return result;
}
// Only leading line comments/blank lines and CRLF are normalized. Never erase
// callback statements or arbitrary comments within the original callback body.
export function callbackBody(source) {
 return source.replace(/\r\n/g,'\n').replace(/^(?:[ \t]*(?:--[^\n]*|)\n)*/,'');
}
export function checkReferenceRows(rows,itemIds,factionIds) {
 const references=[],missing=[];
 for(const row of rows.filter(x=>['quests','quest_lua_modules'].includes(x.table)&&x.after)){
  const source=row.after.lua_content??'',before=row.before?.lua_content??'';
  const key=row.table==='quests'?row.after.zone+'/'+row.after.name:'module:'+row.after.module_name;
  const current=literalReferences(source),old=literalReferences(before);
  const token=r=>`${r.kind}:${r.id}`;
  const count=(list,value)=>list.filter(r=>token(r)===value).length;
  const sameOwner=!!row.before&&(row.table==='quests'?row.before.id===row.after.id&&row.before.zone===row.after.zone&&row.before.name===row.after.name:row.before.module_name===row.after.module_name);
  const bodyPreserved=sameOwner&&callbackBody(before)===callbackBody(source);
  for(const ref of current){
   const entry={key,...ref};references.push(entry);
   if((ref.kind==='item'?itemIds:factionIds).has(ref.id))continue;
   const beforeCount=count(old,token(ref)),afterCount=count(current,token(ref));
   const retainedDisabled=row.after.enabled===0&&bodyPreserved&&beforeCount>0&&beforeCount===afterCount;
   missing.push({...entry,classification:retainedDisabled?'retained_disabled_historical':'unresolved_failure',enabledAfter:row.after.enabled,beforeCount,afterCount,originalCallbackBodyPreserved:bodyPreserved});
  }
 }
 const retained=missing.filter(r=>r.classification==='retained_disabled_historical'),failures=missing.filter(r=>r.classification==='unresolved_failure');
 return {method:'Lexical hand-in, SummonItem, scalar QuestReward, ground-object and Faction references. May include comments/unreachable code; dynamic expressions, random pools, keyed tables and acquisition are not verified.',checked:references.length,missingCount:missing.length,missing,retainedHistoricalCount:retained.length,retainedHistoricalSourceKeys:[...new Set(retained.map(r=>r.key))].sort(),failureCount:failures.length,passed:failures.length===0,limits:'Retained historical findings remain visible. Retention requires a disabled owning after-row, matching owner identity, equal literal occurrence counts and the complete original callback body after leading-header/CRLF normalization. Passing does not mean zero missing references.'};
}
export async function checkReferences(root){
 const manifest=JSON.parse(await fs.readFile(path.join(root,'manifest.json'),'utf8'));
 const keys=Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey]));
 const proposal=mergeProposals((await findProposals(root)).map(x=>x.value),'p99-reference-check',keys);
 async function ids(table){const out=new Set();for(const file of manifest.tables[table].shards)for(const line of (await fs.readFile(path.join(root,file),'utf8')).split('\n').filter(Boolean))out.add(JSON.parse(line).id);
  for(const row of proposal.rows.filter(r=>r.table===table)){if(row.before)out.delete(row.before.id);if(row.after)out.add(row.after.id);}return out;}
 return checkReferenceRows(proposal.rows,await ids('items'),await ids('faction_list'));
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const report=await checkReferences(path.resolve(process.argv[2]??'.'));console.log(JSON.stringify(report,null,2));if(!report.passed)process.exitCode=1;}
