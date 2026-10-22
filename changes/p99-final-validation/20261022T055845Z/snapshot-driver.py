import pathlib,hashlib,json,shutil,time,datetime,os
src=pathlib.Path('/tmp/idlequest-content-p99');stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ');dest=pathlib.Path('/tmp/p99-validation-'+stamp)
roots=['changes','tools','validator'];basefiles=[p.name for p in src.iterdir()if p.is_file() and p.name in ['package.json','package-lock.json','manifest.json','README.md','CONTRIBUTING.md','.gitignore']]
def fingerprints(root):
 result={}
 for name in roots+basefiles:
  p=root/name
  for f in ([p] if p.is_file() else p.rglob('*')):
   rel=f.relative_to(root).as_posix()
   if rel.startswith('changes/p99-final-validation/'):continue
   if f.is_file():result[rel]=hashlib.sha256(f.read_bytes()).hexdigest()
 return result
attempts=[]
for attempt in range(1,11):
 before=fingerprints(src)
 if dest.exists():shutil.rmtree(dest)
 dest.mkdir()
 for name in roots:shutil.copytree(src/name,dest/name,ignore=lambda p,ns:['p99-final-validation']if pathlib.Path(p)==src/'changes' else [])
 for name in basefiles:shutil.copy2(src/name,dest/name)
 after=fingerprints(src);copied=fingerprints(dest)
 drift=sorted(k for k in before.keys()|after.keys()|copied.keys()if not(before.get(k)==after.get(k)==copied.get(k)))
 attempts.append({'attempt':attempt,'drift':drift})
 if not drift:break
 time.sleep(1)
else:raise RuntimeError('Could not capture coherent inputs; source drift persists')
for name in ['data','docs','effective','maintained','reference','schema','sources','node_modules']:os.symlink(src/name,dest/name,target_is_directory=True)
meta={'snapshot':str(dest),'capturedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'attempts':attempts,'files':before,'inputSetSha256':hashlib.sha256(json.dumps(before,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'baselineLinks':'Read-only use contract; symlinks are not kernel read-only mounts. No baseline writes permitted.'}
out=src/'changes/p99-final-validation'/stamp;out.mkdir(parents=True);json.dump(meta,open(out/'input-fingerprints.json','w'),indent=2);(dest/'SNAPSHOT_INPUTS.json').write_text(json.dumps(meta,indent=2));pathlib.Path('/tmp/p99-validation-current-path').write_text(str(dest));pathlib.Path('/tmp/p99-validation-current-artifacts').write_text(str(out));print(json.dumps({'snapshot':str(dest),'artifacts':str(out),'attempts':len(attempts),'files':len(before),'inputSetSha256':meta['inputSetSha256']}))
