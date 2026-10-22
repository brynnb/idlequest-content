import json,pathlib,hashlib,collections
r=pathlib.Path(__file__).resolve().parents[2]
x=json.loads((r/'changes/p99-audit/inventory.json').read_text())
a=json.loads((r/'changes/p99-unmapped-review/page-review.json').read_text())
assert {p['title'] for p in a} == {p['title'] for p in x['pages'] if p['reviewStatus']=='not-recorded'}
assert len(a)==len({p['title'] for p in a})==206
for p in a:
 e=p['evidence'];raw=(r/e['cachePath']).read_bytes()
 assert hashlib.sha256(raw).hexdigest()==e['sha256']
 assert len(raw)==e['bytes']
 assert p['verification']['runtime']=='not_run'
 for s in p['linkedEffectiveScripts']:
  assert hashlib.sha256((r/s['file']).read_bytes()).hexdigest()==s['sha256']
assert next(p for p in a if p['title']=="Kurrat's Magician Epic Guide")['classification']=='player-guide'
assert any('tribe brewer' in t for t in next(p for p in a if p['title']=='Dirty Goblin Parchment')['unresolved'])
print('PASS: exact 206-page set; unique dispositions; source/effective hashes; explicit limits and embedded-mechanic uncertainty')
