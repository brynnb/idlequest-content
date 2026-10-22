import collections,glob,hashlib,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[2];OUT=ROOT/'changes/p99-conversion-world'
cache={}
def rows(table):
 if table not in cache:
  cache[table]=[json.loads(l) for f in (ROOT/'data'/table).glob('*.ndjson') for l in f.read_text().splitlines()]
 return cache[table]
checks=[]
def take(table,pred,columns,note):
 chosen=[{k:r[k] for k in columns} for r in rows(table) if pred(r)]
 assert chosen,(table,note)
 checks.append(dict(table=table,columns=columns,expected=chosen,note=note))
ids={70059,70061,70062,70063,70069,111146,111154,111163,111173,111174,113486,113553,113554,113555,113557,113443,113548,113492,113471,113534,113528,113508,114508,116006,116012,116548,116556,116577,116142,116210,116211,119024,119050,119158,119164,119166,119167,119168,119169,119173,119174,120116,123011,123097,123124,123132,123148,123162,128046,128071,128096,128100,128090,128091,128092,128093,128094,128089}
take('npc_types',lambda r:r['id'] in ids,['id','name','level','class','race','npc_spells_id','npc_spells_effects_id','loottable_id'],'Exact source/helper identities. Exclude flags deliberately do not define enabled quest policy.')
take('spawn2',lambda r:r['id'] in [22501,26697,58538,25251,76541],['id','zone','spawngroupID','x','y','z','heading','pathgrid','respawntime','_condition','cond_value'],'Messenger patrol233, sentinel640s lifetime, legacy duplicate throne, post-wake Apprentice and absent Kalayia grid are explicit data facts.')
take('spawnentry',lambda r:r['spawngroupID'] in [13946,15537],['spawngroupID','npcID','chance'],'All three messenger variants share the verified patrol; Apprentice imported chance0 is recorded, not an era exclusion.')
take('grid',lambda r:(r['zoneid']==116 and r['id']==233) or (r['zoneid']==119 and r['id'] in [23,24,25,26]),['id','zoneid','type','type2'],'Existing authored patrol/one-way route policies, not fabricated coordinates.')
take('grid_entries',lambda r:(r['zoneid']==116 and r['gridid']==233) or (r['zoneid']==119 and r['gridid'] in [23,24,25,26]),['gridid','zoneid','number','x','y','z','heading','pause'],'Full source-backed route points and pauses including Hlash attack position.')
take('doors',lambda r:r['zone']=='neriakb' and r['doorid'] in [1,2,49],['id','zone','doorid','name','lockpick','keyitem','pos_x','pos_y','pos_z','heading'],'Exact linked gate leaves; no invented lock/key requirements.')
take('npc_spells',lambda r:r['id']==10,['id','name','parent_list','attack_proc','range_proc','defensive_proc'],'Defender ranger magic is not omitted; no inherited/ranged/defensive proc capability blocker in this list.')
take('items',lambda r:r['id'] in [1692,1693,1694,1695,1696,1697,1698,1699,1700,1701,1702,1703,1704,1705,1706,1707,1708,1709,22851,22852],['id','Name'],'All hand-in and reward identities; no inferred substitute IDs.')
loot=[r for r in rows('loottable_entries') if r['loottable_id'] in [11786,11694]]
ld={r['lootdrop_id'] for r in loot}
take('loottable_entries',lambda r:r['loottable_id'] in [11786,11694],['loottable_id','lootdrop_id','multiplier','probability','droplimit','mindrop'],'Source giants really reference loot groups containing Holy Symbol of Zek1699.')
take('lootdrop_entries',lambda r:r['lootdrop_id'] in ld and r['item_id']==1699,['lootdrop_id','item_id','chance','multiplier'],'Verify all three Velium Focus giants can supply the required medallions.')
proposal=json.load(open(ROOT/'changes/p99-conversion-world.json'));keys={r['before']['zone']+'/'+r['before']['name'] for r in proposal['rows']}
take('quests',lambda r:r['zone']+'/'+r['name'] in keys,['id','zone','name','enabled','has_say_event'],'Exact24 preimages; disabled Phenocryst/Krofer variants must remain disabled.')
(OUT/'static-expectations.json').write_text(json.dumps(dict(kind='static-identity-and-data-not-live-runtime',checks=checks),indent=2)+'\n')
