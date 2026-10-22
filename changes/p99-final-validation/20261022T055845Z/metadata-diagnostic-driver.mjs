import fs from 'node:fs';
import path from 'node:path';
const root=fs.readFileSync('/tmp/p99-validation-current-path','utf8'),out=fs.readFileSync('/tmp/p99-validation-current-artifacts','utf8');
const {sourceKind,sourceEnabled}=await import(path.join(root,'tools/source-policy.mjs'));
const {scriptKey}=await import(path.join(root,'tools/source-audit.mjs'));
const proposal=JSON.parse(fs.readFileSync(path.join(root,'changes/p99-combined-audit.json'))),issues=[];
for(const source of proposal.sources){
 const kind=sourceKind(source.target);if(kind==='ledger')continue;
 const text=fs.readFileSync(path.join(root,source.proposedFile),'utf8');
 const key=kind==='module'?source.target.slice('maintained/modules/'.length,-4):scriptKey(source.target,text);
 const matches=proposal.rows.filter(r=>r.table===(kind==='module'?'quest_lua_modules':'quests')&&r.after&&(kind==='module'?r.after.module_name:r.after.zone+'/'+r.after.name)===key&&r.after.lua_content===text);
 if(matches.length!==1){issues.push({key,issue:'source-row-match',matches:matches.length});continue;}
 const row=matches[0].after;
 if(Boolean(row.enabled)!==sourceEnabled(text))issues.push({key,issue:'enabled-header-mismatch',rowEnabled:row.enabled,headerEnabled:sourceEnabled(text),source:source.proposedFile});
 if(kind==='quest'&&Boolean(row.has_say_event)!==text.toLowerCase().includes('event_say'))issues.push({key,issue:'say-event-metadata-mismatch',source:source.proposedFile});
}
fs.writeFileSync(path.join(out,'proposal-metadata-diagnostic.json'),JSON.stringify({checked:proposal.sources.length,issues},null,2));console.log(JSON.stringify(issues,null,2));
