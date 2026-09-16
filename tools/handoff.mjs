import fs from 'node:fs/promises';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { readProposal } from './proposal.mjs';
import { sourceDestination, sourceKind } from './source-policy.mjs';
import { hash, safeFile } from './dataset.mjs';
import { generateMigration } from './migration.mjs';
import { randomUUID } from 'node:crypto';

export async function assertPinnedWorktree(root, revision, files=[]) {
  if(!/^[a-f0-9]{40}$/.test(revision??'')) throw new Error('Supply the full reviewed content commit SHA');
  const git=args=>execFileSync('git',['-C',root,...args],{encoding:'utf8'}).trim();
  if(git(['rev-parse','HEAD'])!==revision) throw new Error('Content revision does not match checkout');
  if(git(['status','--porcelain','--untracked-files=all'])) throw new Error('Content checkout must be clean and committed');
  for(const file of files) {
    await safeFile(root,file);
    const tracked=execFileSync('git',['-C',root,'show',`${revision}:${file}`]);
    if(hash(tracked)!==hash(await fs.readFile(path.join(root,file)))) throw new Error(`Unpinned file: ${file}`);
  }
}

export function validateLua(idlequest, sources) {
  const scripts=sources.filter(s=>sourceKind(s.target)!=='ledger').map(s=>({name:s.target,source:s.content,module:sourceKind(s.target)==='module'}));
  if(!scripts.length) return {checked:0,failures:[]};
  try {
    return JSON.parse(execFileSync('go',['run','./cmd/check-content-lua'],{
      cwd:path.join(idlequest,'server'),input:JSON.stringify(scripts),encoding:'utf8',maxBuffer:8*1024*1024,
    }));
  } catch(error) { throw new Error(`Runtime Lua validation failed: ${error.stdout??error.message}`); }
}

async function destinationState(root, relative) {
  // Check every existing ancestor; never follow a destination symlink out of the
  // repository, even for a newly added source under a currently missing folder.
  let current=root;
  for(const part of relative.split('/')) {
    if(!part||part==='.'||part==='..'||part.includes('\\')) throw new Error('Unsafe destination');
    current=path.join(current,part);
    try { if((await fs.lstat(current)).isSymbolicLink()) throw new Error(`Destination symlink: ${relative}`); }
    catch(error) { if(error.code!=='ENOENT') throw error; }
  }
  try { const content=await fs.readFile(current);return {content,sha256:hash(content)}; }
  catch(error) { if(error.code==='ENOENT') return {content:null,sha256:null};throw error; }
}

export async function handoff(root, proposalFile, idlequest, revision, {write=false, sequence}={}) {
  await assertPinnedWorktree(root,revision,[proposalFile,'manifest.json']);
  const {manifest,manifestHash,proposal}=await readProposal(root,proposalFile);
  await assertPinnedWorktree(root,revision,proposal.sources.map(s=>s.proposedFile));
  const syntax=validateLua(idlequest,proposal.sources);
  const migrations=await fs.readdir(path.join(idlequest,'server/migrations'));
  const highest=Math.max(...migrations.map(f=>Number(f.match(/^(\d+)_/)?.[1]??0)));
  const seq=sequence??highest+1;
  if(!Number.isInteger(seq)||seq<=highest) throw new Error(`Use a fresh migration sequence above ${highest}`);
  const migration=`server/migrations/${String(seq).padStart(3,'0')}_content_${proposal.id}.sql`;
  const sql=await generateMigration(root,manifest,proposal,revision);
  const edits=[];
  for(const source of proposal.sources) {
    const destination=sourceDestination(source.target);
    const before=await destinationState(idlequest,destination);
    if(before.sha256!==source.beforeSha256) throw new Error(`Stale IdleQuest source: ${destination}`);
    edits.push({path:destination,before:before.content,after:source.content});
  }
  // Include the complete preimages as an explicit rollback source, but no DB
  // credentials or personal state. The normal migration ledger pins the SQL too.
  const receipt=`data/content-releases/${proposal.id}.json`;
  const cleanSources=proposal.sources.map(({content,...source})=>source);
  const provenance={format:1,revision,baseManifestSha256:manifestHash,proposalFile,proposalSha256:hash(await fs.readFile(path.join(root,proposalFile))),
    migration,migrationSha256:hash(sql),syntax,proposal:{...proposal,sources:cleanSources}};
  for(const [file,content] of [[migration,sql],[receipt,JSON.stringify(provenance,null,2)+'\n']]) {
    if((await destinationState(idlequest,file)).sha256!==null) throw new Error(`Refusing to replace existing artifact: ${file}`);
    edits.push({path:file,before:null,after:content});
  }
  if(!write) return {written:false,revision,migration,receipt,files:edits.map(e=>e.path),syntax};
  // This stages reviewable files only. It does not modify any database, commit,
  // push or deploy. All preimages are checked before the first write.
  const lock=path.join(idlequest,'.content-handoff.lock');
  const handle=await fs.open(lock,'wx');
  const written=[];
  try {
    await assertPinnedWorktree(root,revision,[proposalFile,...proposal.sources.map(s=>s.proposedFile)]);
    for(const edit of edits) {
      const state=await destinationState(idlequest,edit.path);
      if(state.sha256!==(edit.before===null?null:hash(edit.before))) throw new Error(`Destination changed during handoff: ${edit.path}`);
    }
    for(const edit of edits) {
      const file=path.join(idlequest,edit.path);
      await fs.mkdir(path.dirname(file),{recursive:true});
      const temporary=`${file}.content-stage-${randomUUID()}`;
      try {
        await fs.writeFile(temporary,edit.after,{flag:'wx'});
        const current=await destinationState(idlequest,edit.path);
        if(current.sha256!==(edit.before===null?null:hash(edit.before))) throw new Error(`Destination changed during handoff: ${edit.path}`);
        if(edit.before===null) await fs.link(temporary,file);else await fs.rename(temporary,file);
      } finally { await fs.rm(temporary,{force:true}); }
      written.push(edit);
    }
  } catch(error) {
    // Restore only files this operation wrote and which still contain our bytes.
    for(const edit of written.reverse()) {
      const file=path.join(idlequest,edit.path);
      if(hash(await fs.readFile(file))!==hash(edit.after)) throw new Error(`Handoff failed; concurrent edit prevents restoration: ${file}`,{cause:error});
      if(edit.before===null) await fs.unlink(file);else await fs.writeFile(file,edit.before);
    }
    throw error;
  } finally { await handle.close();await fs.unlink(lock); }
  return {written:true,revision,migration,receipt,files:edits.map(e=>e.path),syntax};
}
