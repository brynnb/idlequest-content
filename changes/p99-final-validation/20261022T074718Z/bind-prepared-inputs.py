import pathlib,json,hashlib,datetime
s=pathlib.Path(open('/tmp/p99-validation-current-path').read());a=pathlib.Path(open('/tmp/p99-validation-current-artifacts').read());initial=json.load(open(a/'input-fingerprints.json'));files={}
for name in ['changes','tools','validator','package.json','package-lock.json','manifest.json','README.md','CONTRIBUTING.md','.gitignore']:
 p=s/name
 for f in ([p] if p.is_file()else p.rglob('*')):
  if f.is_file():files[f.relative_to(s).as_posix()]=hashlib.sha256(f.read_bytes()).hexdigest()
result={'capturedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'phase':'After deterministic report regeneration; tests may already be reading these isolated inputs. Later comparison records any test-written receipts.','inputSetSha256':hashlib.sha256(json.dumps(files,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'files':files,'changedSinceCapture':[k for k in sorted(files.keys()|initial['files'].keys())if files.get(k)!=initial['files'].get(k)]}
(a/'prepared-input-fingerprints.json.tmp').write_text(json.dumps(result,indent=2));(a/'prepared-input-fingerprints.json.tmp').replace(a/'prepared-input-fingerprints.json');print(json.dumps({k:v for k,v in result.items()if k!='files'}))
