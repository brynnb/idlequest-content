import pathlib,json,re,sys
R=pathlib.Path(__file__).resolve().parents[2];A=json.loads((R/'changes/p99-source-review/source-navigation.json').read_text())['records']
for i in range(int(sys.argv[1]),int(sys.argv[2])):
 r=A[i];s=(R/r['baselineFile']).read_text();print('\n###',i,r['key']);print('ITEMS',r['itemIdentities']);
 for l in s.splitlines():
  if not l.strip():continue
  l=re.sub(r'"(?:[^"\\]|\\.){240,}"',lambda m:m[0][:95]+' [… speech …] '+m[0][-60:],l)
  print(l)
