import pathlib,json,hashlib
r=pathlib.Path('.');d=r/'changes/p99-tz-review';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();manual=json.load(open(d/'manual-facet-review.json'));tests=json.load(open(d/'test-scenarios.json'));assert len(manual)==223;assert len(tests)==139
for t in tests:assert sha(r/t['proposedFile'])==t['sourceSha256'],t['name']
old=json.load(open('changes/p99-nz-coverage/sky-upgrade-candidates.json'));pairs=[q for q in old['pairs']if any(x in q['actor']for x in ['Gragrot','Tynicon','Gina','Ooga','Falorn'])]
for q in pairs:
 q['review']='Exact named item identities and source compared; seven resolved swaps restored, no unquantified extra effects.'
 if q['actor']=='Gina MacStargan':q['keys']=['airplane/Gina_McStargan']
 if not q['oldItemIds']:q['review']='Blocked: old Spiroc Warhammer item identity absent/ambiguous; no similar ID substituted.'
 if q['actor']=='Falorn':q['review']='Existing4321→27701 preserved/tested. Current Warrior page explicitly gives Aerated intermediate, unlike Old Sky general new-reward statement; retain specific current page behavior.'
 for k in q['keys']:
  p=r/'effective/quests'/(k+'.lua');q.setdefault('sources',[]).append({'key':k,'file':str(p),'sha256':sha(p)})
(d/'old-sky-upgrade-review.json').write_text(json.dumps({'evidence':old['evidence'],'scope':'Relevant intro, Shadow Knight and Shaman sections plus current Warrior force/old-trinket sections read; not a new whole-page review of all Old Sky classes. All four changed actor bodies fully read. No corresponding Perl upgrades exist in snapshot; original Lua old reward outputs are not upgrade branches.','pairs':pairs},indent=2)+'\n')
small=json.load(open(d/'final-small-recipe-review.json'))
for q in small:
 title='The Cigar'if q['recipe']['id']==9780 else "Yegek's Test, Part 1";q['evidence']=next(x['evidence']for x in manual if x['title']==title);q['entriesSha256']=hashlib.sha256(json.dumps(q['entries'],sort_keys=True).encode()).hexdigest();q['review']='All entries and item names fully compared with cached page; exact component/container/output counts, enabled1 preserved. Live crafting not exercised.'
(d/'final-small-recipe-review.json').write_text(json.dumps(small,indent=2)+'\n')
ledger=[{'title':q['title'],'suggested_status':'substantive_facets_reviewed_with_explicit_limits','evidence_sha256':q['evidence']['sha256'],'facet_artifact':'changes/p99-tz-review/manual-facet-review.json','classification':q['verified_facets'].get('classification'),'source_hashes':q['sources'],'proposed_resolution_references':q['referenced_proposals'],'remaining_or_baseline_findings':q['unresolved'],'not_claimed':'Full P99 parity, exact undocumented quantities, rendered UI or engine execution.'}for q in manual];(d/'ledger-suggestions.json').write_text(json.dumps(ledger,indent=2)+'\n')
ps=[]
for p in sorted(r.glob('changes/p99-tz-*.json')):
 j=json.load(p.open())
 if j.get('format')==1:ps.append({'file':str(p),'sha256':sha(p),'rows':len(j['rows']),'sources':len(j['sources'])})
receipt={'status':'Frozen for parent combined validation','pages':len(manual),'focused_mock_cases_passed':len(tests),'focused_proposed_files':len({x['proposedFile']for x in tests}),'own_proposals':len(ps),'own_row_changes':sum(p['rows']for p in ps),'own_source_changes':sum(p['sources']for p in ps),'proposals':ps,'verification':{'test_script':'changes/p99-tz-review/test-proposals.mjs','test_output':'changes/p99-tz-review/behavior-tests.txt','test_manifest_sha256':sha(d/'test-scenarios.json'),'facet_review_sha256':sha(d/'manual-facet-review.json'),'runtime':'Pinned Go normalizer plus real item turn-in helper and strict mocked APIs only. No full runtime/UI/engine claims. Parent performs authoritative combined proposal/dataset and fresh global test validation.'},'shared_changes':['Voleen tax prerequisite removed in existing p99-am-muffin-recipients source; AM runtime assertion binding refreshed, previous AM receipt requires fresh global validation.','Vygan militia restored by AM in p99-am-geozite-dialogue with retained Perl numeric fallback.','Other shared resolutions linked per-title in manual-facet-review.json.'],'blocked':['Two doll item charge corrections cannot be represented because exported items primaryKey is empty.','Geologist exact toolkit combine has no exported recipe; no invented recipe ID/skill/failure metadata.','Garzicor recipes retain ambiguous duplicate component definitions and missing required outputs; no guessed recipe creation.','Ooga old Spiroc Warhammer identity unresolved.','Tarton nofail1 conflicts with documented research-dependent failure; enabled-only proposal retains known-conflicting fallback.','Jaka ground row47 Y689 differs from page520; ground allowlisting preserves imported coordinates.','Other explicit per-title numeric, loot, encounter, faction identity, event availability and engine/UI limits remain in facet artifact.']}
(d/'final-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print({k:v for k,v in receipt.items()if k in ['pages','focused_mock_cases_passed','focused_proposed_files','own_proposals','own_row_changes','own_source_changes']})
(d/'README.md').write_text('''# T–Z P99 review receipt

All 223 assigned cached pages have substantive, hash-bound facet reviews. This is not a claim of full P99 parity. Baseline discrepancies and proposed corrections are deliberately separate; read each record's `referenced_proposals` before interpreting an early baseline finding as unfixed.

## Deliverables
- `manual-facet-review.json`: every page, full-page evidence hash, reviewed source hashes, facet findings, explicit gaps and referenced proposals.
- `ledger-suggestions.json`: non-mutating coverage-ledger recommendations. The immutable baseline ledger was not edited.
- `final-receipt.json`: exact proposal/source/row counts and hashes, shared-source references and blockers.
- `test-scenarios.json` and `behavior-tests.txt`: 139 passing, current-source-hash-bound focused cases. They execute through the pinned Go normalizer with real item turn-in helper and mocked world APIs, not the game engine or rendered UI.
- Recipe/ground/Old Sky sidecars preserve exact row evidence, identities, counts and remaining availability limits. `blocked-gift-doll-charges.json` is a recommendation, not an applicable item-table proposal.

## Important limits
Undocumented XP, faction magnitudes, random probabilities, timers and world coordinates are not fabricated. Exact supported corrections coexist with explicitly retained source fallbacks. Enabling a recipe or ground allowlist row does not establish live crafting or pickup. Full epic, encounter and UI lifecycle checks remain separate. Historical `p99_audit` labels are not treated as runtime exclusions; actual `quests` policy exclusions remain intact. Friendly-faction and documented no-minimum-level adaptations remain intact.

The two doll charge edits are blocked by the item table's missing primary key. Geologist's toolkit recipe is absent, Garzicor crafting has missing/ambiguous definitions, Ooga's old hammer identity is unresolved, and Tarton's known no-fail discrepancy and Jaka placement difference remain explicit. Other per-page limits are retained rather than erased by a broad completion label.

No remote writes, deployment or user-computer work were performed. Parent owns combined structural/compiler/runtime validation and any eventual PR.
''')
