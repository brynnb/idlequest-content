import json,pathlib,hashlib,re,copy
R=pathlib.Path('.');D=R/'changes/p99-final-chain-closure';h=lambda x:hashlib.sha256(x.encode() if isinstance(x,str) else x).hexdigest()
read=lambda p:json.loads(pathlib.Path(p).read_text());save=lambda p,x:pathlib.Path(p).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
a=read(D/'assigned-sources.json')['records'];c=read(D/'controller-sources.json');q={r['key']:r['row'] for r in a};q.update({r['zone']+'/'+r['name']:r for r in c});ix={r['key']:r for r in read('reference/effective-quests-index.json')};review=read(D/'review.json');records=review['records']+review.get('additionalRecords',[])
# Refuse to overlap any current format1 proposal, including approved edits made while this review ran.
for p in R.glob('changes/**/*.json'):
 if p==R/'changes/p99-final-chain-closure.json':continue
 try:prop=read(p)
 except:continue
 if not isinstance(prop,dict) or prop.get('format')!=1 or not isinstance(prop.get('rows'),list):continue
 for ch in prop['rows']:
  r=ch.get('after') or ch.get('before')
  if ch['table']=='quests' and r and r['zone']+'/'+r['name'] in {s['key'] for s in records if s['action']!='unchanged'}:raise Exception('OVERLAP '+str(p)+' '+r['zone']+'/'+r['name'])
prop={'format':1,'id':'p99-final-chain-closure','summary':'Resolve twenty-one of twenty-two exact lifecycle chains as positively post-Velious; source-only disable twenty-four exclusive helpers/controllers and guard one later trial entry in a mixed classic monk controller. Preserve all classic branches and original disabled bodies. Krup watcher, Kesler grant mapping and Xantis live recharge success remain explicitly bounded.','baseManifestSha256':h(R.joinpath('manifest.json').read_bytes()),'evidence':[{'url':x['url'],'note':x['fact']+' '+x.get('limitation','')} for x in read(D/'public-evidence.json')['evidence']],'rows':[],'sources':[]}
for r in records:
 k=r['key'];before=q[k];s=before['lua_content'];target=ix[k]['preferredSource'];r.update(baselineFile=target,baselineSourceSha256=h(R.joinpath(target).read_bytes()),beforeSourceSha256=h(s),disposition=r['status'],evidence=r['evidenceIds'])
 if r['action']=='unchanged':continue
 assert R.joinpath(target).read_text()==s,(k,'source differs from composed row')
 if r['action']=='guard_only_later_entry':
  old='elseif e.message:findi("test of patience") then';new='-- P99 excludes the post-Velious Tynnonium trial; all classic branches stay active.\n\telseif false and e.message:findi("test of patience") then'
  assert s.count(old)==1
  after=s.replace(old,new)
 else:after='-- enabled: false\n-- Post-Velious exact chain; complete historical callback body retained.\n-- Evidence: changes/p99-final-chain-closure/review.json\n'+s
 pf=str(D/(k.replace('/','--')+'.lua'));R.joinpath(pf).write_text(after);ar=copy.deepcopy(before);ar['lua_content']=after
 if r['action']=='disable_preserve_full_body':ar['enabled']=0
 sourceTarget=target.replace('sources/projecteq/','maintained/lua/modified-upstream/',1) if target.startswith('sources/projecteq/') else target
 sourceBefore=h(R.joinpath(sourceTarget).read_bytes()) if R.joinpath(sourceTarget).exists() else None
 r.update(sourceTarget=sourceTarget,sourceBeforeSha256=sourceBefore)
 prop['rows'].append({'table':'quests','before':before,'after':ar});prop['sources'].append({'target':sourceTarget,'beforeSha256':sourceBefore,'proposedFile':pf,'afterSha256':h(after)})
 r.update(proposedFile=pf,proposedSourceSha256=h(after),afterSourceSha256=h(after),proposedEnabled=ar['enabled'])
review['records']=[r for r in records if r['assignment']=='original24'];review['additionalRecords']=[r for r in records if r['assignment']=='approved_extension'];review['counts']={'originalRecords':24,'positiveLaterOriginalChains':21,'unresolvedExactEraChains':1,'unchangedNamedReviews':2,'approvedExtensions':4,'disabledSources':24,'mixedControllerEdits':1,'changedRows':25,'sourceChanges':25};review['extensionApproval']='Parent scope coordination confirmed exact four keys before edits; not additional user-facing authorization or blanket controller cleanup.'
save(D/'review.json',review);save('changes/p99-final-chain-closure.json',prop)
print(review['counts'])
