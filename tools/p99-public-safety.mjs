// Publication gate for the authored audit. It never needs the private runtime checkout.
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';

const rules = [
 ['private_repository_reference', new RegExp('(?:https?://(?:raw\\.githubusercontent\\.com|github\\.com)/)?brynnb/'+'idlequest(?:/|["\\s])')],
 ['private_source_snapshot_name', new RegExp('(?:server__internal__'+'world__|docs__[^\\s/]+\\.md\\.txt|quest_spells\\.go\\.txt)')],
 ['raw_runtime_source', /(?:^|\\n|\n)\s*(?:package world\b|func recipeRequiresLearning\b)/],
 ['copied_runtime_registry', /"(?:registeredRecipeContainerIds|relevantDefinitions|missingIdsAbsentFromRegistrySource|recipeContainerId|curatedRecipesOnly)"\s*:/],
 ['private_evidence_or_backup_reference', /(?:\/tmp\/p99-private-evidence|\/workspace\/shared\/idlequest-content-p99-checkpoints)/],
];
const archived = /\.(?:zip|tgz|gz|tar|7z|bz2|xz)$/i;
export function inspectPublicText(text, file = '') {
 const findings=[];
 for(const [category,pattern] of rules) if(pattern.test(text)||pattern.test(file)) findings.push({file,category});
 if(archived.test(file)) findings.push({file,category:'uninspected_embedded_archive'});
 return findings;
}
async function walk(root, prefix='') {
 const result=[];
 for(const entry of await fs.readdir(path.join(root,prefix),{withFileTypes:true})) {
  if(entry.name==='.git'||entry.name==='node_modules')continue;
  const file=path.posix.join(prefix,entry.name);
  if(entry.isDirectory())result.push(...await walk(root,file));
  else if(entry.isSymbolicLink())result.push({file,symlink:true});
  else if(entry.isFile())result.push({file});
 }
 return result;
}
function authored(file){return file==='package.json'||/^tools\/p99-/.test(file)||/^changes\/p99-/.test(file)}
export async function scanPublication(root='.') {
 const findings=[];let files=0,bytes=0;
 for(const entry of (await walk(root)).filter(e=>authored(e.file))) {
  files++;
  if(entry.symlink){findings.push({file:entry.file,category:'authored_symlink_requires_review'});continue;}
  const data=await fs.readFile(path.join(root,entry.file));bytes+=data.length;
  findings.push(...inspectPublicText(data.toString('utf8'),entry.file));
 }
 return {schemaVersion:1,scope:'Authored P99 changes, P99 tools, and package configuration. Existing public baseline files are not rewritten.',filesScanned:files,bytesScanned:bytes,findings,passed:findings.length===0,limits:['Pattern checks are a publication guard, not proof that arbitrary confidential information is absent.','Embedded archives and symlinks fail closed; inspect and publish only ordinary sanitized files.','Run final tests and bind the publication manifest after any edits. Historical receipts are not evidence that changed publication bytes were tested.']};
}
const hash=s=>crypto.createHash('sha256').update(s).digest('hex');
function windows(text) {
 const lines=text.replace(/\r/g,'').split('\n').map(s=>s.trim()).filter(Boolean),out=[];
 for(let i=0;i+4<=lines.length;i++) {const s=lines.slice(i,i+4).join('\n');if(s.length>=100)out.push(hash(s));}
 return out;
}
function textMembers(text) {
 const result=[text];
 try {const visit=x=>{if(typeof x==='string')result.push(x);else if(Array.isArray(x))x.forEach(visit);else if(x&&typeof x==='object')Object.values(x).forEach(visit)};visit(JSON.parse(text));}catch{}
 return result;
}
// Optional private comparison is used only locally. No reference text, path or fingerprint
// is written to the report. The normal public test suite does not need this input.
export async function comparePrivateSnapshots(root, privateDirectory) {
 const publicWindows=new Set();
 for(const prefix of ['reference','sources','maintained','effective']) {
  for(const {file,symlink} of await walk(path.join(root,prefix))) {
   if(symlink)continue;
   for(const member of textMembers(await fs.readFile(path.join(root,prefix,file),'utf8')))for(const value of windows(member))publicWindows.add(value);
  }
 }
 const privateWindows=new Set();let references=0;
 for(const {file,symlink} of await walk(privateDirectory)) {
  if(symlink||!file.endsWith('.txt'))continue;
  references++;
  for(const value of windows(await fs.readFile(path.join(privateDirectory,file),'utf8')))if(!publicWindows.has(value))privateWindows.add(value);
 }
 const findings=[];
 for(const {file,symlink} of (await walk(root)).filter(e=>authored(e.file))) {
  if(symlink)continue;
  const text=await fs.readFile(path.join(root,file),'utf8');
  if(textMembers(text).some(member=>windows(member).some(value=>privateWindows.has(value))))findings.push({file,category:'private_snapshot_overlap'});
 }
 return {referencesCompared:references,findings,passed:findings.length===0,limits:'Detects normalized four-line private snapshot overlap that is not present in the existing public baseline; not arbitrary paraphrases.'};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const root=path.resolve(process.argv[2]??'.');const report=await scanPublication(root);
 const index=process.argv.indexOf('--private-reference-dir');
 if(index>=0){const comparison=await comparePrivateSnapshots(root,process.argv[index+1]);report.privateComparison=comparison;report.passed&&=comparison.passed;}
 console.log(JSON.stringify(report,null,2));if(!report.passed)process.exitCode=1;
}
