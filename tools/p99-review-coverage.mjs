import fs from 'node:fs/promises';
import path from 'node:path';

// Reconcile review depth, never infer parity from a historical ledger status.
const root = path.resolve(process.argv[2] ?? '.');
const read = async file => JSON.parse(await fs.readFile(path.join(root, file), 'utf8'));
const inventory = await read('changes/p99-audit/inventory.json');
const levels = ['unreviewed', 'screen_only', 'branch_facets_only', 'source_facets_reviewed'];
const records = new Map(inventory.pages.map(page => [page.title, {
  title: page.title, evidence: {url: page.url, cachePath: page.cachePath, sha256: page.sha256},
  level: 'unreviewed', pageTypeClassified: false, reviewArtifacts: [],
}]));
const additionalTitles = new Set();
function add(title, file, level, pageTypeClassified = false) {
  const record = records.get(title);
  if (!record) { additionalTitles.add(title); return; }
  if (levels.indexOf(level) > levels.indexOf(record.level)) record.level = level;
  record.pageTypeClassified ||= pageTypeClassified;
  if (!record.reviewArtifacts.includes(file)) record.reviewArtifacts.push(file);
}
let file = 'changes/p99-am-review/coverage.json';
for (const row of (await read(file)).pages) {
  const status = row.completion_status;
  add(row.title, file, status === 'branch_facets_verified_only' ? 'branch_facets_only'
    : ['not_a_full_parity_review', 'transferred'].includes(status) ? 'screen_only' : 'source_facets_reviewed');
}
file = 'changes/p99-nz-coverage/page-coverage.json';
for (const row of await read(file)) {
  const status = row.review_status;
  add(row.title, file, status.startsWith('partially_reviewed') ? 'source_facets_reviewed'
    : status === 'component_rewards_reviewed_other_dimensions_open' ? 'branch_facets_only' : 'screen_only',
  ['item_reference_triaged', 'redirect_triaged'].includes(status));
}
file = 'changes/p99-af-review/findings.json';
for (const row of (await read(file)).pages) add(row.title, file, 'screen_only', row.classification_level === 'manual');
file = 'changes/p99-af-review/manual-notes.json';
for (const [title, note] of Object.entries(await read(file))) {
  // Explicit page-purpose/exclusion classifications must not be upgraded into
  // source-facet reviews merely because they have a manual note.
  add(title, file, note.classification ? 'screen_only' : 'source_facets_reviewed', Boolean(note.classification));
}
file = 'changes/p99-sz-review/ledger-records.json';
for (const title of Object.keys(await read(file))) add(title, file, 'source_facets_reviewed');
for (file of ['changes/p99-tz-review/manual-facet-review.json', 'changes/p99-nz-coverage/manual-facet-review.json', 'changes/p99-il-review/manual-facet-review.json','changes/p99-armor-review/page-review.json','changes/p99-ranger-epic-review/manual-facet-review.json','changes/p99-paladin-epic-review/manual-facet-review.json']) {
  for (const row of await read(file)) add(row.title, file, 'source_facets_reviewed');
}
file = 'changes/p99-guild-review/coverage.json';
for (const row of (await read(file)).pages) add(row.title, file, 'source_facets_reviewed');
file = 'changes/p99-unmapped-review/page-review.json';
for (const row of await read(file)) add(row.title, file, 'screen_only', true);
const pages = [...records.values()].sort((a, b) => a.title.localeCompare(b.title));
const counts = {};
for (const row of pages) {
  row.disposition = row.level === 'source_facets_reviewed' ? 'source_facets_reviewed'
    : row.pageTypeClassified ? 'page_type_classified_only' : row.level;
  counts[row.disposition] = (counts[row.disposition] ?? 0) + 1;
}
const report = {
  schemaVersion: 1,
  limits: [
    'Source facets reviewed is not full P99 parity, live execution, complete acquisition or UI verification.',
    'Page-type classification does not verify every embedded claim or related quest.',
    'Branch-only and screen-only records still require substantive source review.',
    'Specific numeric and runtime uncertainties remain in the linked review artifacts; historical reviewed labels are not fresh proof.',
  ],
  counts, additionalReviewTitlesOutsideCachedCorpus: [...additionalTitles].sort(), pages,
};
await fs.writeFile(path.join(root, 'changes/p99-audit/review-coverage.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({cachedPages: pages.length, counts, additionalTitles: additionalTitles.size}, null, 2));
