import fs from 'node:fs';import path from 'node:path';
const root=fs.readFileSync('/tmp/p99-validation-current-path','utf8'),out=fs.readFileSync('/tmp/p99-validation-current-artifacts','utf8');
const {relations}=await import(path.join(root,'tools/relations.mjs'));const manifest=JSON.parse(fs.readFileSync(path.join(root,'manifest.json'))),proposal=JSON.parse(fs.readFileSync(path.join(root,'changes/p99-combined-audit.json')));let checked=0;const missing=[];const targetSets=new Map();
for(const [source,field,target,key]of relations){
 const changes=proposal.rows.filter(c=>c.table===source&&c.after&&Number(c.after[field])>0);if(!changes.length)continue;
 const token=target+'.'+key;
 if(!targetSets.has(token)){
  const ids=new Set();for(const file of manifest.tables[target].shards)for(const line of fs.readFileSync(path.join(root,file),'utf8').split('\n').filter(Boolean))ids.add(JSON.parse(line)[key]);
  for(const c of proposal.rows.filter(c=>c.table===target)){if(c.before)ids.delete(c.before[key]);if(c.after)ids.add(c.after[key]);}targetSets.set(token,ids);
 }
 for(const c of changes){checked++;if(!targetSets.get(token).has(c.after[field]))missing.push({source,field,target,key,value:c.after[field],introduced:!c.before||c.before[field]!==c.after[field],rowKey:c.key});}
}
const result={scope:'Declared static ID links on all proposed after-rows against frozen export plus proposed target changes. No database transaction, dynamic Lua or composite grid proof.',checked,missing};fs.writeFileSync(path.join(out,'row-reference-integrity.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result,null,2));if(missing.some(x=>x.introduced))process.exitCode=1;
