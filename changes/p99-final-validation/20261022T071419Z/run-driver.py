import pathlib,json,subprocess,os,datetime,time,hashlib
s=pathlib.Path(open('/tmp/p99-validation-current-path').read());a=pathlib.Path(open('/tmp/p99-validation-current-artifacts').read());env=os.environ.copy();env.update(PATH='/tmp/p99-go-toolchain/go/bin:'+env['PATH'],GOCACHE='/tmp/p99-go-cache',GOPATH='/tmp/p99-go-path',P99_TEST_RECEIPT=str(a/'main-runtime-receipt.json'))
steps=[]
def run(name,args):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();t=time.time()
 with open(a/(name+'.log'),'w') as f:p=subprocess.run(args,cwd=s,env=env,stdout=f,stderr=subprocess.STDOUT)
 r={'name':name,'command':args,'startedAt':start,'durationSeconds':round(time.time()-t,3),'exitCode':p.returncode,'log':name+'.log','logSha256':hashlib.sha256((a/(name+'.log')).read_bytes()).hexdigest()};steps.append(r);(a/'run-status.json').write_text(json.dumps({'snapshot':str(s),'steps':steps},indent=2));print(json.dumps(r),flush=True)
for name,tool,extra in [('inventory','p99-quest-inventory',['--write']),('coverage','p99-review-coverage',[]),('ledger','p99-build-ledger',[]),('source-coverage','p99-source-coverage',[]),('resolution','p99-resolution-report',[]),('downstream','p99-refresh-downstream',[]),('containers','p99-container-compatibility',[]),('closure','p99-conversion-closure-report',[]),('combined','p99-merge-proposals',[])]:run('regenerate-'+name,['node','tools/'+tool+'.mjs','.',*extra])
run('public-safety',['node','tools/p99-public-safety.mjs','.'])
run('npm-tests',['npm','test'])
run('armor-evidence',['node','changes/p99-armor-review/verify-evidence.mjs'])
run('paladin-recipes',['node','changes/p99-paladin-epic-review/test-recipes.mjs'])
run('combined-validation',['node','tools/cli.mjs','check-proposal','.', '--proposal','changes/p99-combined-audit.json'])
run('baseline-validation',['npm','run','validate'])
run('reference-integrity',['node','tools/p99-reference-check.mjs','.'])
scripts=[]
for p in sorted((s/'effective').rglob('*.lua')):scripts.append({'name':p.relative_to(s).as_posix(),'source':p.read_text(),'module':'/modules/' in str(p)})
proposal=json.load(open(s/'changes/p99-combined-audit.json'))
for r in proposal['sources']:
 if r['proposedFile'].endswith('.lua'):scripts.append({'name':r['proposedFile'],'source':(s/r['proposedFile']).read_text(),'module':'/modules/' in r['target']})
(a/'compile-input-fingerprints.json').write_text(json.dumps([{'name':x['name'],'module':x['module'],'sha256':hashlib.sha256(x['source'].encode()).hexdigest()}for x in scripts],indent=2))
t=time.time()
with open(a/'full-lua-compile.log','w') as f:p=subprocess.run(['go','run','.'],cwd=s/'validator',env=env,input=json.dumps(scripts),text=True,stdout=f,stderr=subprocess.STDOUT)
steps.append({'name':'full-lua-compile','command':['go','run','.'],'cwd':'validator','scripts':len(scripts),'durationSeconds':round(time.time()-t,3),'exitCode':p.returncode,'log':'full-lua-compile.log','logSha256':hashlib.sha256((a/'full-lua-compile.log').read_bytes()).hexdigest()});(a/'run-status.json').write_text(json.dumps({'snapshot':str(s),'steps':steps,'completedAt':datetime.datetime.now(datetime.timezone.utc).isoformat()},indent=2));print(json.dumps(steps[-1]),flush=True)
