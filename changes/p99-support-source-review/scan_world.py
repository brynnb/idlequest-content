import json,re,collections,hashlib
from pathlib import Path
ROOT=Path('.')
# Token-aware Lua string/comment scanner. Offsets preserved; full source remains in assignment.
pat=re.compile(r'--\[(=*)\[|--[^\n]*|\[(=*)\[|[\"\']')
def code(s):
 out=[]; strings=[];p=0
 for_dummy=0
 while True:
  m=pat.search(s,p)
  if not m:out.append(s[p:]);break
  out.append(s[p:m.start()]);a=m.group()
  if a.startswith('--[') or a.startswith('['):
   eq=m.group(1) if a.startswith('--') else m.group(2);e=s.find(']'+eq+']',m.end());end=len(s) if e<0 else e+len(eq)+2
  elif a.startswith('--'):end=m.end()
  else:
   end=m.end()
   while end<len(s):
    if s[end]=='\\':end+=2
    elif s[end]==a:end+=1;break
    else:end+=1
  raw=s[m.start():end]
  if not a.startswith('--'):strings.append(raw)
  out.append(' '*len(raw));p=end
 return ''.join(out),strings
r=json.load(open(ROOT/'changes/p99-support-source-review/world-sources.json'))
for x in r:
 c,strings=code(x['text']);x['code']=c;x['stringLiterals']=strings
 x['calls']=sorted(set(re.findall(r'([A-Za-z_][\w]*(?:[.:][A-Za-z_]\w*)*)\s*\(',c)) - {'if','elseif','while','for'})
 x['functions']=re.findall(r'\bfunction\s+([A-Za-z_]\w*)\s*\(',c)
 x['indirectSyntax']=[label for label,p in [('indexed_call',r'\]\s*\('),('load_or_eval',r'\b(?:load|loadstring|dofile|loadfile)\b'),('anonymous_function',r'function\s*\(')] if re.search(p,c)]
 x['actionCalls']=[z for z in x['calls'] if z not in x['functions'] and z not in ['e.self:Say','e.self:Emote','e.self:Shout','e.self:QuestSay','e.other:Message','e.self:Message','e.message:findi','e.message:lower','eq.say_link','e.other:GetName','e.other:GetCleanName','e.self:GetCleanName','e.other:GetFaction','e.other:GetID','e.self:GetID','e.self:GetGender','e.other:Class','e.other:Race','e.other:GetRaceName','e.self:GetClass','e.self:GetX','e.self:GetY','e.self:GetZ','e.self:GetHeading','e.self:GetNPCTypeID','e.self:IsEngaged','eq.get_zone_time','eq.ChooseRandom','math.random','string.format','tonumber','tostring','pairs','ipairs','math.floor']]
json.dump(r,open(ROOT/'changes/p99-support-source-review/world-scanned.json','w'),indent=2)
groups=collections.defaultdict(list)
for x in r:groups[tuple(x['actionCalls'])].append(x['key'])
for calls,keys in sorted(groups.items(),key=lambda v:-len(v[1])):print(len(keys),','.join(calls) or '(speech-only/empty)',':',', '.join(keys))
