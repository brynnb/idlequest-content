"""Extract reproducible public source/item/caller bindings, not era inference from names."""
import pathlib,json,re,hashlib,collections
R=pathlib.Path(__file__).resolve().parents[2];D=R/'changes/p99-final-admission';sha=lambda b:hashlib.sha256(b).hexdigest()
V=json.load(open(D/'review.json'));items={}
for p in sorted((R/'data/items').glob('*.ndjson')):
 for l in p.read_text().splitlines():
  x=json.loads(l);items[x['id']]={'id':x['id'],'name':x['Name'],'classes':x.get('classes'),'races':x.get('races'),'rowSha256':sha(l.encode()),'file':str(p.relative_to(R))}
def source(f,pattern):
 p=R/f;s=p.read_text();lines=[{'line':n,'text':l.strip()}for n,l in enumerate(s.splitlines(),1)if re.search(pattern,l,re.I)]
 return {'file':f,'sha256':sha(p.read_bytes()),'matchingLines':lines}
def extra(fs,patt):return [source(f,patt)for f in fs]
C={}
C['fieldofbone/Trooper_Drix']=extra(['sources/projecteq/cabeast/Drill_Master_Vygan.pl'],r'48008|48009|crown|champion')
C['felwitheb/Elishia_Leafrunner']=extra(['effective/quests/jaggedpine/%23Jeremy_Leafrunner.lua'],r'8969|8970|Elishia')
for k in ['neriaka/Andara_C-Luzz','neriakb/Andara_C-Luzz']:C[k]=extra(['effective/quests/neriakc/Selzar_L-Crit.lua'],r'Andara|bow|2416|19578|19577|19608')
C['neriakc/Medron_Y-Lask']=extra(['effective/quests/neriakc/Ulraz_S-Lon.lua'],r'19571|16170|Medron|19570|armor')
C['freporte/Rigg_Nostra']=extra(['effective/quests/freporte/Tovan_Tenlah.lua','effective/quests/freporte/10000.lua'],r'Rigg|19917|19918|19919|19920|19930|armor|19846')
C['freporte/10000']=extra(['effective/quests/freporte/Rigg_Nostra.lua','effective/quests/freporte/Tovan_Tenlah.lua'],r'Rigg|10000|19917|19918|19919|19920|19930|armor|19846')
C['qcat/Illie_Rols']=extra(['effective/quests/qcat/Ranthor_Bekesna.lua'],r'Illie|20205|20175|20176|20177|armor')
C['qcat/Wellis_Pestule']=extra(['effective/quests/qcat/Unmuz_Tukore.lua'],r'Wellis|20206|20186|20187|20188|armor')
C['rivervale/Bodbin_Gimple']=extra(['effective/quests/rivervale/Kaya_Cloudfoot.lua','effective/quests/rivervale/Megosh_Thistlethorn.lua','sources/projecteq/rivervale/Hibbs_Rootenpaw.lua'],r'Bodbin|19661|19662|19663|19612|19616|machete|bravefoot|scimitar|armor|kit')
C['nektulos/Kamidra_Voragone']=extra(['sources/projecteq/nektulos/Kamidra_Voragone.pl'],r'task|154|13088|Black Eggs')
C['feerrott/Annaelia_Wylassi']=extra(['effective/quests/fearplane/Cazic_Thule.lua'],r'Whistling|7984|1689|Zan Fi|Tynn|satchel|fists') if (R/'effective/quests/fearplane/Cazic_Thule.lua').exists()else[]
C['kaesora/a_tome_keeper']=extra(['effective/quests/cabeast/Master_Bain.lua','effective/quests/cabeast/Master_Raska.lua'],r'18359|18462|18463|18464|18465|18466|18467|18468|18469|18470|tome|Tynnonium')
# Public pinned source annotations are exact evidence of later callbacks, with independent era anchors in public-evidence.json.
markers=r'newbie|armor|armour|kit|mold|mould|pattern|Beastlord|Berserker|epic|DoN|Halloween|Jaggedpine|Tynnonium|Whistling|Dranik|task|qglobal|PoK|Plane of Knowledge|Tanaan|Tome of Primal|Violet Roses|Shar Vahl|Dumul|Trade\(|SummonItem|check_turn_in'
records=[]
for r in V['records']:
 f=r['baselineFile'];s=(R/f).read_text();ids=set()
 for pat in [r'item[1-4]\s*=\s*(\d+)',r'SummonItem\(\s*(\d+)',r'\[(\d+)\]\s*=\s*\d+',r'itemid\s*=\s*(\d+)']:
  ids.update(map(int,re.findall(pat,s)))
 for l in s.splitlines():
  if l.strip().lower().startswith('-- items:'):ids.update(map(int,re.findall(r'\d+',l)))
 rec={'key':r['key'],'source':source(f,markers),'explicitItemSyntaxReferences':[items[i]for i in sorted(ids)if i in items],'sourceCallerTraces':C.get(r['key'],[]),'interpretation':r['reason'],'publicEvidenceIds':r['publicEvidenceIds'],'limits':'Item class masks and actor/source identifiers link the exact body to the independently dated family. They are not standalone P99 numeric parity or runtime admission evidence.'}
 if r['sourceCategory']=='later_beastlord_only':rec['classMaskInterpretation']='Bit 16384 is Beastlord. Class-specific rewards and source/caller context identify the later class branch; generic all-class notes alone do not.'
 if r['sourceCategory']=='later_berserker_only':rec['classMaskInterpretation']='Bit 32768 is Berserker. Class-specific rewards match the official Gates of Discord class introduction.'
 records.append(rec)
(D/'local-evidence.json').write_text(json.dumps({'scope':'Public checkout source and exported item references only. No private runtime code or private data. Sources are exact byte-bound; the original full read is preserved in the historical source-review ledger. Numeric lexical coincidences, high item IDs, NPC exclusion flags and missing wiki pages are not era evidence.','records':records},indent=2)+'\n')
print(len(records),'local evidence records;',sum(len(r['sourceCallerTraces'])for r in records),'additional caller traces')
