import glob
import json
import pathlib
import re

root = pathlib.Path(__file__).resolve().parents[2]
folder = pathlib.Path(__file__).resolve().parent
items = {}
for filename in glob.glob(str(root / 'data/items/*.ndjson')):
    for line in open(filename):
        item = json.loads(line)
        items[item['id']] = item['Name']

count = 0
for armor_set in json.loads((folder / 'recipes.json').read_text()):
    wiki = (root / armor_set['wiki']).read_text()
    checklist = wiki.split('== Checklist ==')[1].split('== Walkthrough ==')[0]
    documented = re.findall(
        r'(?m)^\*\[\[([^\]]+)\]\]\s*\n:\*\[\[([^\]]+)\]\]\s*\n:\*(\d+)x?\s*\[\[([^\]]+)',
        checklist,
    )
    expected = [
        (items[r['reward']], items[r['armor']], str(r['count']), items[r['gem']])
        for r in armor_set['recipes']
    ]
    assert len(documented) == 7 and documented == expected, armor_set['npc']
    source = (folder / (armor_set['npc'] + '.lua')).read_text()
    actual = []
    for block in re.split(r'(?:if|elseif) item_lib.check_turn_in', source)[1:]:
        match = re.search(r'\(e.trade, \{([^}]+)\}\).*?SummonItem\((\d+)\)', block, re.S)
        if not match:
            continue
        required = [int(value) for value in re.findall(r'= (\d+)', match[1])]
        if len(required) != 4:
            continue
        assert required[1:] == [required[1]] * 3, armor_set['npc']
        actual.append((items[int(match[2])], items[required[0]], '3', items[required[1]]))
    assert actual == expected, armor_set['npc']
    count += len(expected)
assert count == 98
print('Verified all 98 recipes against cached P99 checklists, exported item names and proposed Lua.')
