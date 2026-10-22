// Static downstream registry checks. This never executes or edits the game repo.
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {findProposals,mergeProposals} from './p99-merge-proposals.mjs';

export async function buildContainerReview(root='.') {
 const read=async p=>JSON.parse(await fs.readFile(path.join(root,p),'utf8'));
 const evidence=await read('changes/p99-audit/runtime-container-evidence.json');
 const specs=await read('tools/p99-recipe-expectations.json');
 const manifest=await read('manifest.json');
 const wanted=new Set(specs.map(r=>r.recipeId));
 const recipes=new Map();
 for(const file of manifest.tables.tradeskill_recipe.shards) {
  for(const line of (await fs.readFile(path.join(root,file),'utf8')).split('\n').filter(Boolean)) {
   const row=JSON.parse(line);if(wanted.has(row.id))recipes.set(row.id,row);
  }
 }
 const keys=Object.fromEntries(Object.entries(manifest.tables).map(([k,v])=>[k,v.primaryKey]));
 const proposal=mergeProposals((await findProposals(root)).map(x=>x.value),'container-review',keys);
 for(const change of proposal.rows.filter(r=>r.table==='tradeskill_recipe')) {
  if(change.after&&wanted.has(change.after.id))recipes.set(change.after.id,change.after);
 }
 const records=specs.map(spec=>{
  const recipe=recipes.get(spec.recipeId);if(!recipe)throw new Error(`Missing recipe ${spec.recipeId}`);
  const containerIds=spec.containers.map(x=>x[0]);
  if(!evidence.reviewedRecipeIds.includes(recipe.id)) throw new Error(`No downstream compatibility conclusion for recipe ${recipe.id}`);
  const hasRegisteredPath=!evidence.blockedRecipeIds.includes(recipe.id);
  const staticBlocks=[];
  if(!recipe.enabled)staticBlocks.push('recipe_disabled');
  if(recipe.trivial<=0&&!recipe.nofail)staticBlocks.push('invalid_difficulty');
  if(recipe.min_expansion>2||(recipe.max_expansion>=0&&recipe.max_expansion<2))staticBlocks.push('unsupported_expansion');
  if(String(recipe.content_flags??'').trim()||String(recipe.content_flags_disabled??'').trim())staticBlocks.push('content_flags');
  if(!hasRegisteredPath)staticBlocks.push('no_registered_allowed_container');
  return {recipeId:recipe.id,name:recipe.name,tradeskill:recipe.tradeskill,containerIds,staticBlocks,
   manualLearningConclusion:recipe.must_learn===48?'reviewed manual path has no learning gate; see crafting-runtime-evidence.json':'not separately evaluated by this public report',
   disposition:staticBlocks.length?'downstream_static_block':'no_reported_registration_block_not_live_verified'};
 });
 const digest=x=>crypto.createHash('sha256').update(JSON.stringify(x)).digest('hex');
 return {schemaVersion:2,reviewedAt:evidence.checkedAt,evidenceBasis:'attested minimal compatibility conclusions; not independently reproducible runtime source proof',evidenceFile:'changes/p99-audit/runtime-container-evidence.json',
  evidenceSha256:digest(evidence),recipeExpectationsSha256:digest(specs),records,
  counts:{recipes:records.length,downstreamStaticBlocks:records.filter(r=>r.staticBlocks.length).length,registeredPathsOnly:records.filter(r=>!r.staticBlocks.length).length},
  limits:[...evidence.limits,'Manual container identity/policy conclusions only. An unblocked summary does not prove acquisition, character eligibility, inventory settlement, container replacement, success probability, Advanced crafting or live playability.','Missing containers require a separate authorized change in the game repository; enabled content rows alone do not remove these blocks.']};
}

if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href) {
 const root=path.resolve(process.argv[2]??'.');const report=await buildContainerReview(root);
 await fs.writeFile(path.join(root,'changes/p99-audit/container-compatibility.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify(report.counts));
}
