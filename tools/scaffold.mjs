import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const source = path.dirname(fileURLToPath(import.meta.url));
const destination = path.resolve(process.argv[2] ?? '../idlequest-content');
await fs.access(path.join(destination, 'manifest.json'));
const idlequest=path.resolve(source,'../..');
await fs.mkdir(path.join(destination,'validator/questluasource'),{recursive:true});
await fs.copyFile(path.join(idlequest,'server/internal/questluasource/source.go'),path.join(destination,'validator/questluasource/source.go'));
const checker=await fs.readFile(path.join(idlequest,'server/cmd/check-content-lua/main.go'),'utf8');
await fs.writeFile(path.join(destination,'validator/main.go'),checker.replace('idlequest/internal/questluasource','idlequest-content-validator/questluasource'));
await fs.writeFile(path.join(destination,'validator/go.mod'),'module idlequest-content-validator\n\ngo 1.23\n\nrequire github.com/yuin/gopher-lua v1.1.1\n');
const sums=(await fs.readFile(path.join(idlequest,'server/go.sum'),'utf8')).split('\n').filter(line=>line.startsWith('github.com/yuin/gopher-lua v1.1.1'));
await fs.writeFile(path.join(destination,'validator/go.sum'),sums.join('\n')+'\n');
// Only tooling and authored handoff docs; never overwrite exported source/data.
for (const entry of await fs.readdir(source)) {
  if (!entry.endsWith('.mjs')) continue;
  if (entry.startsWith('update-local')) continue; // Game checkout maintenance, not volunteer tooling.
  await fs.mkdir(path.join(destination,'tools'), { recursive: true });
  await fs.copyFile(path.join(source,entry),path.join(destination,'tools',entry));
}
for (const [from,to] of [
  ['README.template.md','README.md'], ['CONTRIBUTING.template.md','CONTRIBUTING.md'],
  ['runtime-contract.template.md','docs/runtime-contract.md'],
  ['handoff.template.md','docs/handoff.md'],
]) {
  await fs.mkdir(path.dirname(path.join(destination,to)),{ recursive: true });
  await fs.copyFile(path.join(source,from),path.join(destination,to));
}
await fs.writeFile(path.join(destination,'package.json'),JSON.stringify({
  name: 'idlequest-content-review', private: true, type: 'module', version: '0.1.0',
  scripts: { test: 'node --test tools/*.test.mjs', validate: 'node tools/cli.mjs validate .' },
  engines: { node: '>=22' }, dependencies: { mysql2: '3.16.1', dotenv: '17.2.3' },
},null,2)+'\n');
await fs.writeFile(path.join(destination,'.gitignore'),'node_modules/\n.env\n.env.*\nreports/\n*.log\n');
// Preserve byte-exact upstream/effective sources, including historical whitespace.
await fs.writeFile(path.join(destination,'.gitattributes'),'sources/** -whitespace\neffective/** -whitespace\nmaintained/** -whitespace\nreference/** -whitespace\n');
await fs.mkdir(path.join(destination,'changes'), { recursive: true });
await fs.writeFile(path.join(destination,'changes/README.md'),`# Review proposals

Keep the baseline immutable. Each proposal is JSON with:

- format: 1
- id: lowercase dash-separated ID
- summary: concrete before/after behavior
- baseManifestSha256: SHA-256 of manifest.json
- evidence: objects with url and note (include retrieval/revision information)
- rows: objects with table, before and after (complete exported row or null for insert/delete)
- sources: objects with target, beforeSha256, proposedFile and afterSha256

Proposed Lua belongs under changes/<id>/ and target is the canonical
maintained/lua/<origin>/<zone>/<name>.lua path. Every changed quest Lua row
must match a proposed maintained source. Preserve -- name: aliases.

Check with:

    node tools/cli.mjs check-proposal . --proposal changes/NAME.json
    node tools/cli.mjs preview . --proposal changes/NAME.json --env-file /outside/scratch.env --database idlequest_content_review
    node tools/cli.mjs apply-scratch . --proposal changes/NAME.json --env-file /outside/scratch.env --database idlequest_content_review

Preview runs inside a rolled-back transaction. Application checks exact current
rows and schema, rejects stale fixes and missing references, and rolls back the
whole proposal on failure. Reapplication recognizes unchanged postimages.

Shared-module replacements target maintained/modules/<module-name>.lua. Leading
-- enabled: false comments preserve reviewed disabled state on future imports.
Review-ledger targets and the pinned handoff workflow are documented in
docs/handoff.md. Rehearsal commands intentionally target scratch databases only;
the handoff stages ordinary source edits and a guarded migration for review.
`);
console.log(`Scaffolded ${destination}`);
