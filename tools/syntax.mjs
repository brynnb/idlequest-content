import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { sourceKind } from './source-policy.mjs';

export function checkProposalSyntax(root, proposal) {
  const scripts=proposal.sources.filter(s=>sourceKind(s.target)!=='ledger')
    .map(s=>({name:s.target,source:s.content,module:sourceKind(s.target)==='module'}));
  if(!scripts.length) return {checked:0,failures:[]};
  try { return JSON.parse(execFileSync('go',['run','.'],{cwd:path.join(root,'validator'),input:JSON.stringify(scripts),encoding:'utf8',maxBuffer:8*1024*1024})); }
  catch(error) { throw new Error(`Runtime Lua syntax validation failed: ${error.stdout??error.message}`); }
}
