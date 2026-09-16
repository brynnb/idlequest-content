#!/usr/bin/env node
import path from 'node:path';
import { validateDataset, localConfig, loadScratch, verifyDatabase } from './dataset.mjs';
import { readProposal, applyProposal } from './proposal.mjs';
import { handoff } from './handoff.mjs';
import { checkProposalSyntax } from './syntax.mjs';

const [command, rootArg, ...rest] = process.argv.slice(2);
const root = path.resolve(rootArg ?? '.');
const args = new Map();
for (let i = 0; i < rest.length; i += 2) {
  if (!['--env-file', '--database', '--proposal', '--idlequest', '--revision', '--write', '--sequence'].includes(rest[i]) || !rest[i+1]) throw new Error(`Unknown/incomplete argument: ${rest[i]}`);
  args.set(rest[i], rest[i+1]);
}
if (command === 'validate') {
  const result = await validateDataset(root);
  console.log(`Validated ${Object.keys(result.manifest.files).length} files and ${Object.keys(result.manifest.tables).length} tables; manifest ${result.manifestHash}`);
} else if (command === 'check-proposal') {
  if (!args.has('--proposal')) throw new Error('Supply --proposal changes/NAME.json');
  const result = await readProposal(root, args.get('--proposal'));
  console.log(checkProposalSyntax(root,result.proposal));
  console.log(`Validated proposal ${result.proposal.id}: ${result.proposal.rows.length} rows, ${result.proposal.sources.length} sources`);
} else if (command==='handoff') {
  if(!args.has('--proposal')||!args.has('--idlequest')||!args.has('--revision')) throw new Error('Handoff requires --proposal, --idlequest and --revision');
  if(args.has('--write')&&!['true','false'].includes(args.get('--write'))) throw new Error('--write must be true or false');
  console.log(JSON.stringify(await handoff(root,args.get('--proposal'),path.resolve(args.get('--idlequest')),args.get('--revision'),{write:args.get('--write')==='true',sequence:args.has('--sequence')?Number(args.get('--sequence')):undefined}),null,2));
} else if (['load', 'verify-db', 'preview', 'apply-scratch'].includes(command)) {
  if (!args.has('--env-file') || !args.has('--database')) throw new Error('Database operations require --env-file and --database');
  const database = args.get('--database');
  const config = await localConfig(args.get('--env-file'), database);
  if (command === 'load') await loadScratch(root, config, database);
  else if (command === 'verify-db') await verifyDatabase(root, config);
  else {
    if (!args.has('--proposal')) throw new Error('Supply --proposal changes/NAME.json');
    if (!/^idlequest_content_[a-z0-9_]+$/.test(database)) throw new Error('Proposal rehearsal requires an idlequest_content_ scratch database');
    const reviewed = await readProposal(root, args.get('--proposal'));
    console.log(checkProposalSyntax(root, reviewed.proposal));
    console.log(JSON.stringify(await applyProposal(root, args.get('--proposal'), config, { apply: command === 'apply-scratch' }), null, 2));
  }
} else throw new Error('Usage: node tools/cli.mjs validate|load|verify-db|check-proposal|preview|apply-scratch DATASET [--proposal changes/NAME.json --env-file FILE --database idlequest_content_NAME]');
