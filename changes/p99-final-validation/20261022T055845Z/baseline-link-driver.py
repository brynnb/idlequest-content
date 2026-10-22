import pathlib,os,json,datetime
s=pathlib.Path(open('/tmp/p99-validation-current-path').read());a=pathlib.Path(open('/tmp/p99-validation-current-artifacts').read());source=pathlib.Path('/tmp/idlequest-content-p99');records=[]
for name in ['data','docs','effective','maintained','reference','schema','sources']:
 target=s/name
 if not target.is_symlink():raise RuntimeError('Expected initial symlink: '+str(target))
 staging=s/(name+'.hardlink-stage');staging.mkdir();count=0
 for p in (source/name).rglob('*'):
  dest=staging/p.relative_to(source/name)
  if p.is_symlink():raise RuntimeError('Unexpected immutable source symlink: '+str(p))
  if p.is_dir():dest.mkdir(exist_ok=True)
  else:os.link(p,dest);count+=1
 target.unlink();staging.rename(target);records.append({'directory':name,'hardlinkedFiles':count})
(a/'baseline-link-layout.json').write_text(json.dumps({'changedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'reason':'Dataset safeFile rejects symlink ancestors. No validation bypass; immutable file bytes unchanged.','directories':records,'limits':'Hard links are used read-only by task discipline; not kernel read-only mounts. No chmod or baseline writes.'},indent=2))
print(json.dumps(records))
