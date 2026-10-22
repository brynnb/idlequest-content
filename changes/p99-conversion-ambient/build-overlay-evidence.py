import json,pathlib,hashlib,re
P=pathlib.Path('.');O=P/'changes/p99-conversion-ambient';sha=lambda s:hashlib.sha256(s.encode()).hexdigest();read=lambda p:P.joinpath(p).read_text();rows=lambda t:[json.loads(l) for f in sorted(P.joinpath('data',t).glob('*.ndjson')) for l in f.open()]
npcs={r['id']:r for r in rows('npc_types')};quests={r['zone']+'/'+r['name']:r for r in rows('quests')};overlay={};files={}
for f in sorted(P.joinpath('changes').glob('*.json')):
 if f.name=='p99-combined-audit.json':continue
 try:pr=json.loads(f.read_text())
 except:continue
 for r in pr.get('rows',[]):
  if r.get('table')!='quests':continue
  a=r.get('after') or {};k=a.get('zone','')+'/'+a.get('name','');overlay[k]=(a,str(f))
 for s in pr.get('sources',[]):files[s.get('afterSha256')]=s.get('proposedFile')
keys=['thurgadina/'+n for n in ['Lieutenant_Ulfur','Guard_Bjorn','Guard_Clorn','Guard_Dobbs','Guard_Enre','Guard_Gord','Guard_Mason','Guard_Pert','Loremaster_Fronden','Doogle_McBanick','Petcas_Coldbeard']]+['thurgadinb/'+n for n in ['Seneschal_Aldikar','#Dain_Frostreaver_IV','Chamberlain_Krystorf','Councilor_Juliah_Lockheart']]+['iceclad/Ritap','iceclad/Sojan_the_Sleepless']
out=[]
for k in keys:
 q,owner=overlay.get(k,(quests[k],None));body=q.get('lua_content') or '';f=files.get(sha(body));orig='sources/projecteq/'+k+'.pl';d={'key':k,'originalDatabaseLua':quests[k].get('lua_content'),'originalQuestId':quests[k]['id'],'originalEnabled':quests[k]['enabled'],'effectiveComposedProposal':owner,'proposedFile':f,'composedLuaSha256':sha(body),'handlers':re.findall(r'function (event_\w+)\(',body),'worldActors':bool(re.search(r'^-- actors: world$',body,re.M)),'worldTimers':bool(re.search(r'^-- timers: world$',body,re.M))}
 if P.joinpath(orig).exists():d['originalPerlSha256']=sha(read(orig));d['originalHandlers']=re.findall(r'sub (EVENT_\w+)',read(orig))
 out.append(d)
edges=[]
for r in json.loads(read(O/'assignment.json'))['rows']:
 s=read(r['sourceFile'])
 for kind,args in re.findall(r'quest::(signalwith|signal)\(([^)]+)\)',s):
  parts=[x.strip() for x in args.split(',')]
  if not parts[0].isdigit():continue
  id=int(parts[0]);edges.append({'source':r['key'],'targetNPCID':id,'targetExactName':npcs.get(id,{}).get('name'),'signalID':int(parts[1]) if kind=='signalwith' and len(parts)>1 else 0,'delayMS':int(parts[2]) if kind=='signalwith' and len(parts)>2 else int(parts[1]) if kind=='signal' and len(parts)>1 else 0})
(O/'connected-overlay-evidence.json').write_text(json.dumps({'method':'Use composed top-level proposals, excluding generated combined artifact, then fall back to baseline database. Never treat zero-length baseline Lua as current missing receiver without checking overlay.','correction':'Seven Ulfur guards were already translated in prior flavor proposal; this worker adds only public actor scope to existing bodies. Original null database rows are not new rows.','sources':out,'originalSignalEdges':edges},indent=2)+'\n')
