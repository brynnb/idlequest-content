import json,pathlib,hashlib,re
ROOT=pathlib.Path(__file__).resolve().parents[2]
BASE=ROOT/'changes/p99-conversion-trades'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def perl(key):return (ROOT/'sources/projecteq'/f'{key}.pl').read_text()
def q(s):return json.dumps(s,ensure_ascii=False)
def speechs(key):return re.findall(r'quest::(say|emote)\("(.*?)"\);',perl(key),re.S)
def header(key,notes):return '-- Converted from sources/projecteq/'+key+'.pl\n-- Original Perl SHA256: '+sha(ROOT/'sources/projecteq'/f'{key}.pl')+'\n-- Review: changes/p99-conversion-trades/closure-review.json\n'+''.join('-- '+n+'\n' for n in notes)+'\n'
def refund():return '\nfunction event_trade(e)\n    local item_lib = require("items")\n    item_lib.return_items(e.self, e.other, e.trade)\nend\n'
def out(key,body,notes):
 p=BASE/f'{key.replace("/","--")}.lua';p.write_text(header(key,notes)+body+refund());return p
paths={}
key='iceclad/Joshel_the_Large'
text=speechs(key)[0][1].replace('[Icebreaker]','Icebreaker').replace('yet not wantin\'','ye not wantin\'')
paths[key]=out(key,'function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Say('+q(text)+')\n    end\nend\n',['Partial: documented P99 hail only; no verified P99 authority for bandana 60333.','The later/unverified Icebreaker reward branch is not activated or replaced with a guessed reward.'])
key='thurgadina/Fergus_Sawdust'
paths[key]=out(key,'function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Say('+q(speechs(key)[0][1])+')\n    end\nend\n',['Full bounded source conversion: hail and return-only trade.','P99 forum t=301249 reports this exact hail working; no guessed follow-up quests.'])
key='thurgadina/Guard_Dagur'
a,b=[s for _,s in speechs(key)],"Aye, we wouldn't want ye fallin into the pit now would we."
paths[key]=out(key,'function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Say("Greetings and welcome to Thurgadin, " .. e.other:GetCleanName() .. ". Ye best watch yer step on the bridge there, it can be a bit slippery.")\n        local entities = eq.get_entity_list()\n        if entities:IsMobSpawnedByNpcTypeID(115132) then\n            local baldvin = entities:GetMobByNpcTypeID(115132)\n            if baldvin then\n                baldvin:Say('+q(b)+')\n            end\n        end\n    end\nend\n',['Full source conversion with a boolean presence check, not Perl defined(false).','Guard Baldvin is exact NPC 115132 and remains the speaker of his own line.','Read-only lookup only; no spawn or actor identity changes.'])
key='thurgadina/Meg_Tucter'
paths[key]=out(key,'function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Say('+q(speechs(key)[0][1])+')\n    end\nend\n',['Partial: geonid lore and return-only trade.','Etching Tools 8893 and their eighth-Shawl offer are positively outside the P99 seven-Shawl cutoff.'])
key='thurgadinb/Loremaster_Solstrin'
s=speechs(key)
body='function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Emote('+q(s[0][1]).replace('$name','" .. e.other:GetCleanName() .. "')+')\n    elseif e.message:findi("interested") or e.message:findi("what hero") then\n        e.self:Emote('+q(s[1][1])+')\n        e.self:Say('+q(s[2][1])+')\n    elseif e.message:findi("sacred tomb") then\n        e.self:Say('+q(s[3][1])+')\n    end\nend\n'
paths[key]=out(key,body,['Partial: P99 Hall of Ancestors lore; also recognize documented "I am interested".','No eighth-Shawl orders 8896, books 18610/18611, approved shawl 8895 or issue kit 17651.','Return offered 1199/8895/8896 unchanged instead of consuming unsupported later hand-ins.'])
key='skyshrine/Grudash_the_Baker'
s=speechs(key)
# Only the non-pie closing exchange is retained. The classic quest never has a reward.
paths[key]=out(key,'function event_signal(e)\n    if e.signal == 2 then\n        e.self:Say('+q(s[3][1])+')\n        eq.signal(114496, 3, 1)\n    end\nend\n',['Partial ambient/refund-only conversion, not an implemented Boysenberry Pie quest.','P99 cache says the quest was never implemented and pie references were removed.','Omit both pie say branches and signal 1/3 pie responses. Preserve only non-pie closing signal 2.','Perl signalwith wait_ms and Lua eq.signal delay are milliseconds: preserve the upstream 1 ms, not 1000 ms.'])
key='skyshrine/Ruru_the_Cook'
s=speechs(key)
body='function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Say('+q(s[0][1])+')\n    end\nend\n\nfunction event_signal(e)\n'
for i,idx in [(3,3),(4,4),(5,5)]:
 typ,txt=s[idx];body+=('    if' if i==3 else '    elseif')+' e.signal == '+str(i)+' then\n        e.self:'+('Say' if typ=='say' else 'Emote')+'('+q(txt)+')\n'
body+='    end\nend\n'
paths[key]=out(key,body,['Partial: standalone cooking hail and non-pie reaction signals 3/4/5; return-only trade.','Do not start Grudash\'s removed pie taunt from hail or continue the removed pie argument via signals 1/2.','No pie, other reward, faction change, XP, or quest progression is introduced.'])
key='thurgadina/Petcas_Coldbeard'
s=speechs(key)
body='function event_say(e)\n    if e.message:findi("hail") then\n        e.self:Say("Hail to ye as well offlander. I bid you welcome to the Icy Mug, one o\' the finest establishments for a drink in Thurgadin.")\n    end\nend\n\nfunction event_signal(e)\n'
# Source has interpolation in the first say; preserve signal text by parsing EVENT_SIGNAL only.
sigs=perl(key).split('sub EVENT_SIGNAL {',1)[1]
for sig in range(1,7):
 block=re.search(r'if\(\$signal=='+str(sig)+r'\)\s*\{(.*?)\}',sigs,re.S).group(1)
 body+=('    if' if sig==1 else '    elseif')+' e.signal == '+str(sig)+' then\n'
 m=re.search(r'quest::say\("(.*?)"\);',block,re.S)
 if m:body+='        e.self:Say('+q(m.group(1))+')\n'
 if sig<6:body+='        eq.signal(115019, '+str(sig)+')\n'
body+='    end\nend\n'
paths[key]=out(key,body,['Partial: bounded Icy Mug greeting and Ronodun signal responses; refunds all trades.','Special Beans 60290 belongs to Warrior epic 1.5 prequest and is excluded.','P99 Souvenir Mugs names Adia, not Petcas, for the 5-gold stein 30145; no duplicate source is invented.','Ronodun 115019 supplies external initiation; this script does not spawn or drive that actor.'])
# Only exact exported before rows; source insertion, no baseline edits.
allrows=[]
for p in (ROOT/'data/quests').glob('*.ndjson'):
 allrows.extend(json.loads(l) for l in p.read_text().splitlines() if l)
rows=[];sources=[]
for key,p in paths.items():
 before=next(r for r in allrows if r['zone']+'/'+r['name']==key)
 assert not before['lua_content'];after=before.copy();after['lua_content']=p.read_text();after['has_say_event']=int('function event_say(' in after['lua_content'])
 rows.append({'table':'quests','before':before,'after':after})
 target='maintained/lua/converted-perl/'+key+'.lua';assert not (ROOT/target).exists()
 sources.append({'target':target,'beforeSha256':None,'proposedFile':str(p.relative_to(ROOT)),'afterSha256':sha(p)})
proposal={'format':1,'id':'p99-conversion-trades','summary':'Convert eight bounded P99-era flavor/refund handlers, preserve exact actor identities, exclude unsupported and later reward branches, and retain complete 16-source closure evidence. These are not eight completed progression quests.','baseManifestSha256':sha(ROOT/'manifest.json'),'evidence':[],'rows':rows,'sources':sources}
(BASE/'paths.json').write_text(json.dumps({k:str(p.relative_to(ROOT)) for k,p in paths.items()},indent=2)+'\n')
(ROOT/'changes/p99-conversion-trades.json').write_text(json.dumps(proposal,indent=2)+'\n')
