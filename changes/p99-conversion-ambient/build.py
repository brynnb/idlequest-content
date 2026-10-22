import json,pathlib,re,hashlib
P=pathlib.Path('.'); O=P/'changes/p99-conversion-ambient';sha=lambda b:hashlib.sha256(b).hexdigest()
assignment=json.load(open(O/'assignment.json'))['rows'];quests={r['zone']+'/'+r['name']:r for f in (P/'data/quests').glob('*.ndjson') for r in map(json.loads,f.open())};idx=json.load(open(O/'wiki-evidence.json'))
files={}
def put(key,body,headers=''):
 text='-- name: '+key.split('/')[1]+'\n'+headers+'-- P99 bounded conversion review: 2026-10-22; see closure-review.json.\n-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.\n'+body.strip()+'\n'
 path=O/(key+'.lua');path.parent.mkdir(parents=True,exist_ok=True);path.write_text(text);files[key]=str(path)
def speech(s):
 parts=re.split(r'(\$name|\$race)',s)
 return ' .. '.join('e.other:GetCleanName()' if p=='$name' else 'e.other:GetRaceName()' if p=='$race' else json.dumps(p) for p in parts if p)
for a in assignment:
 key=a['key']; src=P/a['sourceFile']; s=src.read_text();name=key.split('/')[1]
 if key.startswith('thurgadinb/Councilor_'):
  sayings=re.findall(r'quest::say\("(.*?)"\)',s); moves=re.findall(r'quest::moveto\((.*?)\)',s)
  body=''
  if sayings:body='function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Say('+speech(sayings[0])+')\n    end\nend\n\n'
  body+='function event_signal(e)\n    if e.signal == 1 then\n        e.self:MoveTo('+moves[0][:-1]+'true)\n    elseif e.signal == 2 then\n        e.self:MoveTo('+moves[1][:-1]+'true)\n    end\nend'
  put(key,body,'-- actors: world\n')
 elif name.startswith('Guard_'):
  line=re.search(r'quest::emote\("(.*?)"\)',s)[1]
  put(key,'function event_signal(e)\n    e.self:Emote('+speech(line)+')\nend','-- actors: world\n-- Original Ulfur patrol signal receiver; accepts any signal ID exactly as Perl.\n')
 elif name=='Lieutenant_Ulfur':
  sayings=re.findall(r'quest::say\("(.*?)"\)',s);emote=re.search(r'quest::emote\("(.*?)"\)',s)[1];signals=re.findall(r'quest::signal\((\d+)\)',s)
  body='function event_spawn(e)\n    -- Promote the existing exact native circular patrol to durable callback delivery.\n    -- Runtime admission rejects another active route for this actor lifetime.\n    eq.start(30)\nend\n\nfunction event_say(e)\n'
  for topic,line in zip(['hail','regiment','yes','no'],sayings):body+='    if e.message:findi("'+topic+'") then\n        e.self:Say('+speech(line)+')\n    end\n'
  body+='end\n\nfunction event_waypoint_arrive(e)\n    if e.wp == 15 then\n        e.self:Emote('+speech(emote)+')\n'+''.join('        eq.signal('+n+', 0)\n' for n in signals)+'    end\nend'
  put(key,body,'-- actors: world\n-- Engine adaptation: event_spawn starts existing grid30 (spawn25629), preserving all24 points and pauses.\n-- Player-scene bootstrap and live navigation are not independently validated here.\n')
 elif name in ['Novyak_the_Lookout','Initiate_Kroskain','Templar_Franchus','Templar_Tingar']:
  timers=re.findall(r'quest::settimer\((\d+),(\d+)\)',s); sayings=re.findall(r'quest::say\("(.*?)"\)',s)
  body='function event_spawn(e)\n'+''.join(f'    eq.set_timer("{n}", {int(t)*1000})\n' for n,t in timers)+'end\n\nfunction event_timer(e)\n'
  if name=='Templar_Tingar':body+='    if e.timer == "1" then\n        e.self:Say('+speech(sayings[0])+')\n    elseif e.timer == "2" then\n        e.self:Say('+speech(sayings[1])+')\n        e.self:Say('+speech(sayings[2])+')\n    end\n'
  else:body+='    e.self:Say('+speech(sayings[0])+')\n'
  put(key,body+'end','-- timers: world\n')
 elif name=='Initiate_Corrith':
  put(key,'function event_spawn(e)\n    eq.set_timer("2", 30000)\nend\n\nfunction event_timer(e)\n    e.self:DoAnim(2)\nend','-- timers: world\n-- Runtime limitation: DoAnim is currently a no-op; the original requested animation is retained.\n')
 elif name=='Initiate_Sirchthain':
  put(key,'local function reset_timer()\n    -- Perl rand(40)+10 is [10,50) seconds, despite the inaccurate 10-40 comment.\n    eq.set_timer("2", math.floor((math.random() * 40 + 10) * 1000))\nend\n\nfunction event_spawn(e)\n    reset_timer()\nend\n\nfunction event_timer(e)\n    e.self:DoAnim(2)\n    reset_timer()\nend','-- timers: world\n-- Runtime limitation: DoAnim is currently a no-op; original request retained.\n-- Identity limitation: this original script key has no exact NPC name match; no alias or NPC row is invented.\n')
 elif name=='Julius_Oresko':
  line=re.search(r'quest::say\("(.*?)"\)',s)[1];put(key,'function event_aggro(e)\n    e.self:Say('+speech(line)+')\nend','-- NPC availability on P99 is unverified; exact exported key retained, no NPC row added.\n')
 elif name=='Brina_Snowfox':
  line=re.search(r'quest::say\("(.*?)"\)',s)[1].replace('Wood Elf?','$race?')
  put(key,'function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Say('+speech(line)+')\n    end\nend','-- Repair: duplicate hardcoded Wood Elf / corrupt %#1472 greetings collapse to one player-race greeting.\n-- Common prose is ProjectEQ, not independently verified P99 dialogue; race substitution is a documented template repair.\n')
 elif name=='gnomish_captive':
  put(key,'function event_spawn(e)\n    local x, y = e.self:GetX(), e.self:GetY()\n    eq.set_proximity(x - 20, x + 20, y - 20, y + 20)\nend\n\nfunction event_enter(e)\n    e.self:Say("Please, somebody help me. This bear won\'t let me leave.")\n    e.self:Emote("tries to hide from Bloodmaw deeper in the cave.")\n    eq.clear_proximity()\n    eq.depop()\nend','-- Keep IdleQuest owner-scoped proximity/depop semantics; no static spawn is added.\n-- Distinct from bloody_gnome_captive (118026), the existing Bloodmaw map recipient.\n')
proposal={'format':1,'id':'p99-conversion-ambient','summary':'Convert bounded Velious ambient timer, proximity, aggro and council movement sources; retain existing enabled state and exact identities. Cosmetic animation limitations and disconnected world dependencies remain explicit. No later eighth-Shawl rewards.','baseManifestSha256':sha((P/'manifest.json').read_bytes()),'evidence':[{'url':r['url'],'note':f"Cached {r['fetchedAt']}; SHA256 {r['sha256']}; {r['cachePath']}. NPC identity evidence is not independent verification of ProjectEQ ambient prose."} for r in idx],'rows':[],'sources':[]}
for ev in json.load(open(O/'runtime-evidence.json')):
 proposal['evidence'].append({'url':ev['url'],'note':'Official QuestManager source distinguishes millisecond signal delays from second-based settimer. See changes/p99-conversion-ambient/signal-units.json.'})
for key,file in sorted(files.items()):
 old=quests[key];new={**old,'lua_content':(P/file).read_text(),'has_say_event':int('function event_say(' in (P/file).read_text())}
 target='maintained/lua/converted-perl/'+key+'.lua';tp=P/target
 assert not tp.exists(),target
 proposal['rows'].append({'table':'quests','before':old,'after':new});proposal['sources'].append({'target':target,'beforeSha256':None,'proposedFile':file,'afterSha256':sha((P/file).read_bytes())})
(P/'changes/p99-conversion-ambient.json').write_text(json.dumps(proposal,indent=2)+'\n')
print('Converted',len(files),'keys',*files,sep='\n')
