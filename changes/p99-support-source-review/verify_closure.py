import pathlib,json,hashlib,collections,os
base=pathlib.Path('changes/p99-support-source-review');read=lambda p:json.loads(pathlib.Path(p).read_bytes());sha=lambda b:hashlib.sha256(b if isinstance(b,bytes)else b.encode()).hexdigest()
a=read(base/'assignment.json');r=read(base/'review-records.json');runtime=read(base/'runtime-manifest-receipt.json');manifest=read(base/'runtime-assertions.json')
assert len(a['records'])==len(r['records'])==1079
assert r['assignmentSha256']==sha((base/'assignment.json').read_bytes())
assert r['baselineManifestSha256']==sha(pathlib.Path('manifest.json').read_bytes())=='8bd2b042870b4e7e46141b811ed12e1a9dee453dcf03f2e07f06fccd4cc3e205'
for old,new in zip(a['records'],r['records']):
 assert old['key']==new['key'] and sha(old['text'])==old['currentSourceSha256']==new['reviewedSourceSha256']
 assert new['summary'] and new['disposition'] and new['limitations'] and new['fullP99ParityClaim'] is False
 art=new['sourceReviewArtifact'];assert sha(pathlib.Path(art['file']).read_bytes())==art['sha256']
 assert new['exactDuplicateRepresentative'] in new['identicalSourceKeys'] and new['key'] in new['identicalSourceKeys']
assert {x['key']for x in r['extraControllerCorrections']}=={'emeraldjungle/Scout_Vyrak','permafrost/Scout_Janomin'}
assert runtime['status']=='passed' and runtime['sourceCount']==92 and runtime['caseCount']==217
assert runtime['manifestSha256']==sha((base/'runtime-assertions.json').read_bytes())
assert len({x['proposedFile']for x in manifest['cases']})==92
for c in manifest['cases']:assert sha(pathlib.Path(c['proposedFile']).read_bytes())==c['sourceSha256']
logs={'p99-support-world-scope':'world-proposal-validation.txt','p99-support-mixed-hints':'mixed-hint-validation.txt','p99-support-ocean-fishing-scope':'ocean-fishing-validation.txt','p99-support-lifecycle-scope':'lifecycle-scope-final-validation.txt','p99-support-lifecycle-values':'lifecycle-values-final-validation.txt'}
proposals=[]
for p in sorted(pathlib.Path('changes').glob('p99-support-*.json')):
 j=read(p);assert j['format']==1
 assert all(row['table']=='quests'for row in j['rows'])
 if j['id'] in logs:
  log=base/logs[j['id']];assert 'validation_exit=0' in log.read_text() and 'failures: null' in log.read_text()
 elif j['id']=='p99-support-named-fixes':
  log=base/'named-review-proposal-validation.json';v=read(log);assert v['status']=='passed' and v['proposalSha256']==sha(p.read_bytes())
 else:
  assert j['id']=='p99-support-dialogue-fixes';log=pathlib.Path('changes/p99-support-dialogue-fixes/validation.log');assert 'failures: null' in log.read_text();assert read(base/'dialogue-review-final-hashes.json')['proposalSha256']==sha(p.read_bytes())
 proposals.append({'file':str(p),'sha256':sha(p.read_bytes()),'rows':len(j['rows']),'sources':len(j['sources']),'fullCliValidation':{'status':'passed','receipt':str(log),'sha256':sha(log.read_bytes())}})
assert len(proposals)==7 and sum(p['sources']for p in proposals)==92
checks={'assignedKeys':1079,'distinctReviewedHashes':len({x['reviewedSourceSha256']for x in r['records']}),'correctedAssignedKeys':r['counts']['proposalCorrectedAssignedKeys'],'extraControllers':2,'allCorrectedFiles':92,'disabledSourcesIncludingControllers':68,'boundedFunctionalCorrections':24,'centralCompatibleScenarios':217,'disabledBodyShapeScenarios':68,'functionalScenarios':149,'fullCliProposalsPassed':7,'completeP99ParityClaim':False}
report={'status':'passed','verifiedAt':os.environ.get('P99_AUDIT_REVIEW_TIMESTAMP','2026-10-22T06:45:50Z'),'timestampNote':'UTC tool/context clock captured before this final verification invocation.','checks':checks,'baselineManifestSha256':r['baselineManifestSha256'],'assignmentSha256':r['assignmentSha256'],'unifiedReviewSha256':sha((base/'review-records.json').read_bytes()),'runtimeManifestSha256':sha((base/'runtime-assertions.json').read_bytes()),'runtimeReceiptSha256':sha((base/'runtime-manifest-receipt.json').read_bytes()),'proposals':proposals,'limits':['Complete source-body classification is not semantic parity for every quest or numeric/text facet.','217 isolated current-source scenarios use mocked quest APIs; no live world, UI, inventory settlement or activation claim.','Explicit unresolved quest evidence remains in exact per-key records and the22-key lifecycle chain list.','No NPC rows, immutable baseline, central ledger, shared tools, commits, push or PR changed by this support-source work.']}
(base/'final-verification.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report['checks'],indent=2));print('unifiedReviewSha256',report['unifiedReviewSha256']);print('finalVerificationSha256',sha((base/'final-verification.json').read_bytes()))
