import json,pathlib,hashlib
P=pathlib.Path('.');names={'Guard_'+n for n in ['Bjorn','Clorn','Dobbs','Enre','Gord','Mason','Pert']};p=P/'changes/p99-conversions-velious-flavor.json';data=json.loads(p.read_text());out=[]
sha=lambda b:hashlib.sha256(b).hexdigest()
for row in data['rows']:
 a=row['after']
 if a['zone']=='thurgadina' and a['name'] in names:
  f=P/'changes/p99-conversions-velious-flavor/thurgadina'/(a['name']+'.lua');before=f.read_text();after=before if before.startswith('-- actors: world\n') else '-- actors: world\n'+before;f.write_text(after);a['lua_content']=after
  s=next(s for s in data['sources'] if s['proposedFile']==str(f));s['afterSha256']=sha(after.encode());out.append({'key':a['zone']+'/'+a['name'],'existingProposal':str(p),'existingSource':str(f),'previousProposedSha256':sha(before.encode()),'updatedProposedSha256':s['afterSha256'],'change':'Add actors:world header only. Existing complete event_signal emote and return-all event_trade unchanged. Not a new Lua conversion.','correction':'Earlier handoff inspected immutable baseline null Lua, overlooking this already-composed flavor proposal. No missing source receiver behavior was invented.'})
p.write_text(json.dumps(data,indent=2)+'\n');f=P/'changes/p99-conversion-ambient/guard-scope-updates.json'
if not f.exists():f.write_text(json.dumps(out,indent=2)+'\n')
