import pathlib,json,hashlib
root=pathlib.Path('.');h=lambda b:hashlib.sha256(b).hexdigest()
coverage={x['title']:x for x in json.load(open('changes/p99-nz-coverage/page-coverage.json'))}
quests={r['zone']+'/'+r['name']:r for p in root.glob('data/quests/*.ndjson') for l in p.open() if (r:=json.loads(l))}
def proposal(id,title,key,transform,summary):
 b=quests[key];src=next(root.glob('maintained/lua/*/'+key+'.lua'),root/'maintained/lua/modified-upstream'/ (key+'.lua'));before=src.read_text() if src.exists() else b['lua_content'];assert b['lua_content']==before
 after=transform(before);assert after!=before
 out=root/'changes'/id/(key.replace('/','--')+'.lua');out.parent.mkdir(exist_ok=True);out.write_text(after)
 ev=coverage[title]['evidence'];obj={'format':1,'id':id,'summary':summary,'baseManifestSha256':h(root.joinpath('manifest.json').read_bytes()),'evidence':[{'url':ev['url'],'note':f"Cached {ev['fetchedAt']}; revision unavailable; SHA256 {ev['sha256']}. Source-only correction; full runtime and UI not executed. Undocumented numerical values unchanged."}],'rows':[{'table':'quests','before':b,'after':dict(b,lua_content=after)}],'sources':[{'target':str(src),'beforeSha256':h(before.encode()) if src.exists() else None,'proposedFile':str(out),'afterSha256':h(after.encode())}]}
 json.dump(obj,open('changes/'+id+'.json','w'),indent=2)
proposal('p99-sz-alex-dialogue','Shaman Spells (Good)','firiona/Alex_McDarnin',lambda s:s.replace('e.message:findi("i want to help")','e.message:findi("i want to help") or e.message:findi("you want to help")'),'Accept advertised you-want-to-help button while preserving existing P99 spoken phrase; no trade changes.')
proposal('p99-sz-gardern-dialogue','Staff of Temperate Flux Quest','soltemple/Gardern',lambda s:s.replace('e.message:findi("staff of temperate flux")','e.message:findi("staff of temperate flux") or e.message:findi("lore to the staff")'),'Accept documented P99 lore-to-the-staff phrase while preserving existing staff button and unrelated trades.')
proposal('p99-sz-bloogy-counts','Saucy Salted Seadragon Steak','cobaltscar/Bloogy_Shellcracker',lambda s:s.replace('plus seaweed and TWO fish eggs together','plus TWO seaweed and ONE fish egg together').replace('item2 = 19113, item3 = 16498, item4 = 16498','item2 = 19113, item3 = 19113, item4 = 16498'),'Correct both dragon-meat branches to two Saltwater Seaweed and one Fish Eggs per explicit confirmed P99 requirements; preserve existing alternative meats and rewards.')
def semkak(s):
 start=s.index('if item_lib.check_turn_in(e.trade, { item1 = 24986 })');end=s.index('  elseif item_lib.check_turn_in',start);b=s[start:end]
 old='These scrolls are ancient beyond belief. They describe the maneuvers dragons use to avoid being injured by mighty warriors. This will aid the cause of King Tormax greatly. Take this gift from the temple of Vallon and know that you are wise indeed.'
 b=b.replace('e.self:Say("'+old+'")','e.self:Say("This tablet holds great knowledge. The Temple of Strategy thanks you, " .. e.other:GetCleanName() .. ". Take this and know that your own strategies are wise indeed if you have acquired this tablet from the depths of the dragons\' graveyard.")').replace('e.other:SummonItem(eq.ChooseRandom(25036, 25040, 25034, 25035))','e.other:SummonItem(25035) -- Book of Strategy, documented Golden Tablet reward')
 return s[:start]+b+s[end:]
proposal('p99-sz-semkak-tablet','Strategies of the Ancient Dragons','kael/Semkak_Prophet_of_Vallon',semkak,'Golden Tablet gives documented Book of Strategy and tablet response; preserve wiki-ambiguous Scroll of Scaled Tactics random pool and all numerical rewards.')
def xyrin_timer(s):
 s=s.replace('function event_spawn(e)','local escort_stage = 0 -- persisted closure state; 0=waiting, 1=escort, 2=finished\n\nfunction event_spawn(e)\n\tescort_stage = 0')
 s=s.replace('if(item_lib.check_turn_in(e.trade, {item1 = 12134})) then','if(escort_stage == 0 and item_lib.check_turn_in(e.trade, {item1 = 12134})) then\n\t\tescort_stage = 1\n\t\teq.stop_timer("depop");\n\t\teq.set_timer("escort_complete",360000);')
 start=s.index('\telseif(e.wp == 5) then');end=s.index('\n\tend',start)
 s=s[:start]+s[end:]
 old='\tif(e.timer == "depop") then\n\t\teq.depop();'
 new='''\tif(e.timer == "escort_complete" and escort_stage == 1) then
\t\tescort_stage = 2
\t\teq.stop_timer("escort_complete");
\t\teq.stop_timer("depop");
\t\te.self:Say("Many thanks to all who aided in this battle. I offer you this, a weapon I found on a slain Erudite paladin. May Marr watch over his soul and may Marr guide yours. Now I must go.");
\t\t-- P99: after six minutes, drop at current position, regardless of aggro.
\t\t-- Existing thirty-minute item decay retained; P99 does not document decay.
\t\teq.create_ground_object(5414,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading(),1800000);
\t\teq.depop();
\telseif(e.timer == "depop" and escort_stage == 0) then
\t\teq.stop_timer("depop");
\t\teq.depop();'''
 assert old in s
 return s.replace(old,new)
parts=[]
for name in ['Andlin','Boris','Gallius','Janeal','Meighan','Theo','Warren','Xyrin']:
 key=('oot' if name=='Xyrin' else 'freportn')+'/Sentry_'+name
 ident='p99-sz-sentry-'+name.lower()
 def faction_fix(s):
  if name=='Xyrin':s=xyrin_timer(s)
  return s.replace('Faction(362,5,0)','Faction(362,1,0)').replace('Faction(330,-10,0)','Faction(330,-1,0)').replace('Faction(281,5,0)','Faction(281,1,0)')
 proposal(ident,'Sentry Xyrin Quest',key,faction_fix,'Match all three explicitly documented P99 per-step faction deltas; preserve item/XP/lifecycle behavior and unresolved Xyrin timing.')
 parts.append(json.load(open('changes/'+ident+'.json')))
# One isolated proposal prevents selecting only part of this eight-sentry correction.
out=dict(parts[0]);out['id']='p99-sz-sentry-factions';out['summary']='Correct each of eight Sentry Xyrin quest steps to documented faction +1/-1/+1. Xyrin uses supported six-minute timer and current-position single harpoon drop with persistent closure guard; exact XP and live lifecycle remain unresolved.';out['rows']=[r for p in parts for r in p['rows']];out['sources']=[s for p in parts for s in p['sources']]
json.dump(out,open('changes/p99-sz-sentry-factions.json','w'),indent=2)
for p in parts:root.joinpath('changes',p['id']+'.json').unlink(missing_ok=True)
# First part id changed above; remove original individual proposal by stable name.
root.joinpath('changes/p99-sz-sentry-andlin.json').unlink(missing_ok=True)
def sornita(s):
 start=s.index('\telseif(item_lib.check_turn_in(e.trade, {item1 = 12590}))');end=s.index('\n\tend',start)
 return '-- P99: Shakey head remains unfinished through Velious; later rogue epic 1.5 continuation excluded.\n'+s[:start]+s[end:]
proposal('p99-sz-sornita-era',"Shakey the Scarecrow's Head",'erudnext/Sornita_Eltern',sornita,'Remove only post-Velious Water-Stained Ancient Tome continuation explicitly unavailable on P99; preserve20gold Torn Parchment exchange and unknown-item returns.')
proposal('p99-sz-smaka-factions','Shadow Knight Epic Quest','neriaka/Smaka',lambda s:s.replace('Faction(236, 5, 0)','Faction(236, 3, 0)').replace('Faction(334, 5, 0)','Faction(334, 1, 0)').replace('Faction(370, 5, 0)','Faction(370, 1, 0)'),'Match explicitly documented SK Epic Cough Elixir faction3/1/1; preserve1000platinum cost.')
def duriek(s):
 a,b=s.split('elseif faction >= 35',1)
 return a.replace('Faction(404, 7)','Faction(404, 3)')+'elseif faction >= 35'+b
proposal('p99-sz-duriek-factions','Shadow Knight Epic Quest','paineel/Duriek_Bloodpool',duriek,'Match explicitly documented TrueSpirit+3 on letter, elixir and tome; preserve final Corrupted Ghoulbane branch+7 and allXP/gates.')
proposal('p99-sz-sarkis_ebonblade-class','Shadow Knight Plane of Sky Tests','airplane/Sarkis_Ebonblade',lambda s:s.replace('e.other:Class() == "Shadowknight"','e.other:GetClass() == 5'),'Normalize rewrites Class to GetClassName, but Shadowknight differs from actual Shadow Knight display spelling; preserve intended class5 eligibility using numeric ID. Book-return step remains unresolved.')
proposal('p99-sz-zand-alias','Shaman Skull Quests','cabeast/Hierophant_Zand',lambda s:s.replace('(e.message:findi("chosen savior"))','(e.message:findi("chosen savior") or e.message:findi("chosen saviour"))'),'Accept Oxyn-advertised British spelling while retaining original US spelling; preserve trade branches and era limit.')
proposal('p99-sz-quarg-alias','Shaman Skull Quests','fieldofbone/Crusader_Quarg',lambda s:s.replace('findi("collect the Crusaders of Rok Nilok?")','findi("collect the Crusaders of Rok Nilok")'),'Accept actual advertised phrase under runtime literal findi; trailing question mark remains accepted. No extra chest grant invented.')
proposal('p99-sz-dovan-alias','Shaman Skull Quests','swampofnohope/Mystic_Dovan',lambda s:s.replace('findi("galdon vok nir?")','findi("galdon vok nir")'),'Accept advertised Galdon Vok Nir phrase with or without punctuation under actual literal findi; preserve unrelated services.')
recipes={r['id']:r for p in root.glob('data/tradeskill_recipe/*.ndjson') for l in p.open() if (r:=json.loads(l))}
ev=coverage['Shaman Skull Quests']['evidence'];rows=[]
for id in [9235,9351,9766,9767]:
 b=recipes[id];a=dict(b,enabled=1)
 if id==9351:a['nofail']=1
 rows.append({'table':'tradeskill_recipe','before':b,'after':a})
json.dump({'format':1,'id':'p99-sz-skull-recipes','summary':'Enable four explicitly documented Shaman Skull combines; Totem explicitly NOFAIL. Preserve exact component/output/container rows and all other metadata, including SkullII trivial17 whose exact value remains unverified.','baseManifestSha256':h(root.joinpath('manifest.json').read_bytes()),'evidence':[{'url':ev['url'],'note':f"Full cached page SHA256 {ev['sha256']}; explicitly NOFAIL Ton Warrior Totem, components and no-fail quest containers. Live crafting not tested."}],'rows':rows},open('changes/p99-sz-skull-recipes.json','w'),indent=2)
epic_parts=[]
for zone in ['butcher','fieldofbone','oot','rathemtn']:
 def lesser(s):
  s=s.replace('e.message:findi("what are you")','e.message:findi("what are you") or e.message:findi("who are you")')
  s=s.replace('\n\t\teq.depop()\n\tend\nend\n\nfunction event_timer','\n\tend\nend\n\nfunction event_timer')
  if zone=='butcher':s=s.replace('10 * 60 * 1000','5 * 60 * 1000')
  return s
 id='p99-sz-epic-lesser-'+zone
 proposal(id,'Shaman Epic Quest',zone+'/a_lesser_spirit',lesser,'Allow documented repeat gems until expiry and who-are-you alias; Butcher documented five-minute expiry, other original timers retained.')
 epic_parts.append(id)
for name in ['a_greater_spirit','a_greater_spirit_']:
 def greater(s):
  start=s.index('\telseif(e.message:findi("heyokah"))');mid=s.index('\telseif(e.message:findi("i will walk the path"))',start);end=s.index('\n\tend\nend',mid)
  first=s[start:mid];last=s[mid:end].replace('e.message:findi("i will walk the path")','e.message:findi("i will walk the path") or e.message:findi("path of the heyokah")')
  return s[:start]+last+'\n'+first.rstrip()+s[end:]
 id='p99-sz-epic-'+name
 proposal(id,'Shaman Epic Quest','freportn/'+name,greater,'Handle full documented path-of-Heyokah completion and advertised link before generic Heyokah gem branch; preserve rewards and signals.')
 epic_parts.append(id)
def tower(s):
 start=s.index('\t\telseif(item_lib.check_turn_in(e.trade, {item1 = 18456');end=s.index('\n\t    end',start)
 return s[:start]+s[end:]
id='p99-sz-epic-tower'
proposal(id,'Shaman Epic Quest','emeraldjungle/Spirit_Sentinel',tower,'Remove three-book turn-in from explicitly wrong tower NPC94052; correct pond NPC94141 and its branch unchanged.')
epic_parts.append(id)
objs=[json.load(open('changes/'+id+'.json')) for id in epic_parts]
combined=dict(objs[0]);combined.update(id='p99-sz-shaman-epic',summary='Seven evidence-backed Shaman Epic source fixes: lesser repeat gems/alias, greater completion ordering, wrong tower books returned; full live chain remains unverified.',rows=[r for o in objs for r in o['rows']],sources=[s for o in objs for s in o['sources']])
json.dump(combined,open('changes/p99-sz-shaman-epic.json','w'),indent=2)
for id in epic_parts:(root/'changes'/ (id+'.json')).unlink()
