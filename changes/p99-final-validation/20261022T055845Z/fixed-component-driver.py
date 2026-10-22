import pathlib,json,hashlib,subprocess,os,time,datetime
root=pathlib.Path('/tmp/idlequest-content-p99');a=pathlib.Path(open('/tmp/p99-validation-current-artifacts').read());env=os.environ.copy();env.update(PATH='/tmp/p99-go-toolchain/go/bin:'+env['PATH'],GOCACHE='/tmp/p99-go-cache',GOPATH='/tmp/p99-go-path');records=[]
for file in ['changes/p99-af-erdarf-entry.json','changes/p99-il-parity/proposal.json']:
 p=json.load(open(root/file));inputs=[file]+[s['proposedFile']for s in p['sources']]
 def hashes():return {f:hashlib.sha256((root/f).read_bytes()).hexdigest()for f in inputs}
 before=hashes();name='active-fixed-'+p['id'];command=['node','tools/cli.mjs','check-proposal','.', '--proposal',file];start=datetime.datetime.now(datetime.timezone.utc).isoformat();t=time.time()
 with open(a/(name+'.log'),'w')as log:r=subprocess.run(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT)
 after=hashes();record={'proposal':file,'command':command,'startedAt':start,'durationSeconds':round(time.time()-t,3),'exitCode':r.returncode,'inputsBefore':before,'inputsAfter':after,'drift':before!=after,'log':name+'.log','logSha256':hashlib.sha256((a/(name+'.log')).read_bytes()).hexdigest(),'scope':'Actual CLI component validation in active checkout after metadata fixes; separate from preserved initial snapshot.'};records.append(record);(a/'active-fixed-components.json').write_text(json.dumps(records,indent=2));print(json.dumps({k:v for k,v in record.items()if k not in ['inputsBefore','inputsAfter']}),flush=True)
