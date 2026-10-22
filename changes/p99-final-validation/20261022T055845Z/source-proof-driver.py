import pathlib,json,hashlib
s=pathlib.Path(open('/tmp/p99-validation-current-path').read());a=pathlib.Path(open('/tmp/p99-validation-current-artifacts').read());p=json.load(open(s/'changes/p99-combined-audit.json'));receipt=json.load(open(a/'main-runtime-receipt.json'));byfile={}
for c in receipt['cases']:
 if c['file'].startswith('changes/'):byfile.setdefault(c['file'],[]).append(c)
flavor={}
for d in ['p99-conversions-velious-flavor','p99-conversions-velious-flavor-extra']:
 for row in json.load(open(s/'changes'/d/'review.json'))['reviewed_candidates']:
  if row['outcome']!='converted_proposal':continue
  f='changes/'+d+'/'+row['key']+'.lua';flavor[f]=len(row['tests'])+int('function event_say' in(s/f).read_text())+1
rows=[]
for x in p['sources']:
 f=x['proposedFile']
 if not f.endswith('.lua'):continue
 actual=hashlib.sha256((s/f).read_bytes()).hexdigest();assert actual==x['afterSha256'],f
 for c in byfile.get(f,[]):assert c['sourceSha256']==actual,f
 rows.append({'target':x['target'],'proposedFile':f,'sha256':actual,'mainCases':len(byfile.get(f,[])),'flavorCases':flavor.get(f,0)})
missing=[x['proposedFile']for x in rows if not(x['mainCases']or x['flavorCases'])];assert not missing,missing
out={'scope':'Exact initial snapshot sources only, not final source-closure certification. Main and flavor suites both passed. Case counts across suites may overlap.','proposedLuaFiles':len(rows),'missing':missing,'mainProposedCasesCorrected':sum(c['file'].startswith('changes/')for c in receipt['cases']),'mainBaselineVerificationsCorrected':sum(not c['baselineReproduction'] and (c['baselineVerification'] or c['file'].startswith(('effective/','maintained/','sources/'))) for c in receipt['cases']),'mainBaselineReproductions':receipt['baselineReproductions'],'flavorCases':sum(flavor.values()),'sources':rows};(a/'proposed-source-proof.json').write_text(json.dumps(out,indent=2));print(json.dumps({k:v for k,v in out.items()if k!='sources'},indent=2))
