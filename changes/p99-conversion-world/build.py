"""Reproduce bounded, source-reviewed world helper proposals. Baseline is read-only."""
import hashlib, json, pathlib, re
ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / 'changes/p99-conversion-world'
SHA = lambda b: hashlib.sha256(b).hexdigest()
def emit(key, body, note=''):
    zone, name = key.split('/', 1)
    source = ROOT / ('sources/projecteq/' + key + '.pl')
    disabled = key in ['wakening/Phenocryst', 'wakening/Lieutenant_Krofer', 'wakening/#Lieutenant_Krofer']
    text = ('-- enabled: false\n' if disabled else '') + '-- name: ' + name + '\n-- Source: sources/projecteq/' + key + '.pl\n'
    text += '-- Source SHA256: ' + SHA(source.read_bytes()) + '\n'
    text += '-- P99 conversion review: changes/p99-conversion-world/closure-review.json\n'
    if note:
        text += ''.join('-- ' + line + '\n' for line in note.splitlines())
    text += body.strip() + '\n'
    path = OUT / zone / (name + '.lua')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)

emit('neriakb/player', '''
function event_click_door(e)
  local door = e.door:GetDoorID()
  if door == 1 then
    eq.force_door_open(2); eq.force_door_open(49)
  elseif door == 2 then
    eq.force_door_open(1); eq.force_door_open(49)
  elseif door == 49 then
    eq.force_door_open(1); eq.force_door_open(2)
  end
end
''', 'Retain the classic three-leaf Commons gate. Omit only the explicit LDoN\nWayfarer invitation, not the classic door handler. No invented key requirements.')

for name in ['#an_enraged_vampire', 'an_enraged_vampire']:
    emit('frozenshadow/' + name, '''
function event_spawn(e)
  e.self:SendIllusionPacket({gender = eq.ChooseRandom(0, 1)})
end
''', 'Preserve the random cosmetic gender intent with the established Lua illusion API.\nCurrent IdleQuest SendIllusionPacket is a no-op: translated, NOT visually delivered.\nThe hash and plain actor variants remain separate runtime keys.')

emit('eastwastes/a_Ry-Gorr_messenger', '''
function event_spawn(e)
  -- Existing local placement 22501 uses this exact authored patrol.
  -- Start an owner-scoped cursor so normal authenticated waypoint events run.
  eq.start(233)
end
function event_waypoint_depart(e)
  if e.wp == 19 then eq.set_timer("leave", 60000) end
end
function event_timer(e)
  if e.timer ~= "leave" then return end
  eq.stop_timer("leave")
  eq.depop_with_timer()
end
''', 'Preserve departure19 plus60seconds and authored respawn. The shared patrol is\nrepresented by the existing owner-scoped grid executor, not fabricated arrivals.\nNo loot or ring-five hand-in behavior is changed; grid233 is verified in data.')

emit('necropolis/A_Guardian_of_the_Shrine', '''
function event_spawn(e)
  local x, y = e.self:GetX(), e.self:GetY()
  eq.set_proximity(x - 7, x + 7, y - 7, y + 7)
end
function event_enter(e)
  local guardian = eq.get_entity_list():GetMobByNpcTypeID(123011)
  if guardian.valid then guardian:AddToHateList(e.other, 1) end
end
''', 'Zone-local invisible trigger123124 provokes Jaled Dar123011. Preserve hate,\nnot a warning-only substitute. Same-name Skyshrine actor114508 is unrelated.')

emit('necropolis/a_nest', '''
local triggered = false
function event_aggro(e)
  if triggered then return end
  triggered = true
  local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()
  eq.spawn2(123132, 0, 0, x, y, z, h)
  eq.spawn2(123132, 0, 0, x - 2, y, z, h)
  eq.spawn2(123132, 0, 0, x + 2, y, z, h)
  eq.spawn2(123132, 0, 0, x, y - 2, z, h)
  eq.spawn2(123132, 0, 0, x, y + 2, z, h)
  eq.spawn2(123132, 0, 0, x + 1, y + 1, z, h)
  eq.depop_with_timer()
end
''', 'P99 confirms triggered beetles. Six offsets and trap lifecycle are retained\nProjectEQ details, not verified P99 counts. Duplicate aggro cannot duplicate a wave.')

emit('necropolis/a_pile_of_bones', '''
local triggered = false
function event_combat(e)
  if not e.joined or triggered then return end
  triggered = true
  local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()
  eq.depop_with_timer()
  eq.spawn2(123097, 0, 0, x, y, z, h)
end
''', 'Preserve the local triggered construct123097, corpse-position spawn and trap\nrespawn. Trigger only on entry, not a second time on the ensuing combat release.\nNo new probability is inferred from the P99 description that constructs sometimes appear.')

emit('westwastes/A_sentinel-s_voice', '''
local warned = false
function event_spawn(e)
  local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
  eq.set_proximity(x - 30, x + 30, y - 30, y + 30, z - 30, z + 30)
end
function event_enter(e)
  if warned then return end
  warned = true
  e.self:Emote("invades your thoughts: 'Beware mortal!  This land is marked by Veeshan, and is sacred to her brood.  None but Dragonkin are welcome here.  Your life is forteit if you proceed.  Ignore this message at your peril!'")
  eq.depop_with_timer()
end
''', 'Exact invisible trigger120116 at placement26697; use its authored640s respawn.\nPreserve full30-unit XYZ bounds and source wording. No P99 timing claim.')

emit('skyshrine/A_Guardian_of_the_Shrine', '''
function event_signal(e)
  if e.signal == 66 then
    e.self:Shout("BEWARE! BEWARE! The Sleeper has been awakened! He means death for all who remain here! Time is short, flee the Skyshrine now if you value your life!")
  end
end
''', 'Complete local signal receiver only. Cross-zone Sleeper awakening remains\nblocked separately; this translation does not establish its global delivery.')

for name, other_ids in {
    '#Hraashna_the_Warder': [128090,128091,128092],
    '#Nanzata_the_Warder': [128091,128092,128093],
    '#Tukaarak_the_Warder': [128090,128091,128093],
    '#Ventani_the_Warder': [128090,128092,128093],
}.items():
    condition = ' and '.join('not list:GetMobByNpcTypeID(' + str(id) + ').valid' for id in other_ids)
    emit('sleeper/' + name, '''
function event_death_complete(e)
  local list = eq.get_entity_list()
  if ''' + condition + ''' then eq.signal(128094, 66, 0) end
  e.self:Shout("Warders, I have fallen. Prepare yourselves, these fools are determined to unleash doom!")
end
''', 'Retain all three living-warder checks and signal66, without global-state shortcuts.\nThis is a complete local callback, not a functioning cross-zone awakening event.')

emit('sleeper/#The_Sleeper', '''
function event_spawn(e)
  eq.set_timer("sleep", 1000)
end
function event_timer(e)
  if e.timer ~= "sleep" then return end
  e.self:SetAppearance(1)
  eq.stop_timer("sleep")
end
function event_signal(e)
  if e.signal ~= 66 then return end
  e.self:Shout("I AM FREE!")
  eq.depop_with_timer()
  eq.spawn2(128089, 1, 0, -1499, -2344.8, -1052.8, 0)
end
''', 'Preserve the wake signal, exact actor/grid and appearance intent. SetAppearance\nis currently cosmetic no-op; successor Kerafyrm cross-zone lifecycle is still blocked.\nDo not claim the awakening family complete because this receiver is translated.')

for name in ['Bloodpriest_Ioukond','accolyte_of_Zek']:
    emit('wakening/' + name, '''
function event_signal(e)
  eq.depop()
end
''', 'Velium Focus cleanup receiver. Phenocryst signals these quest-spawned actors;\nretain unconditional signal cleanup and no synthetic rewards.')

for name, timer, seconds, dest, grid in [
    ('Berzerker_Dolvad','onset2',55,(-4310,-741,-183),25),
    ('Disciple_Atharm','onset3',90,(-4357,-715,-183),26),
]:
    emit('wakening/' + name, f'''
function event_spawn(e)
  eq.set_timer("{timer}", {seconds * 1000})
end
function event_timer(e)
  if e.timer ~= "{timer}" then return end
  e.self:MoveTo({dest[0]}, {dest[1]}, {dest[2]}, -2, true)
  eq.stop_timer("{timer}")
end
function event_signal(e)
  if e.signal == 1 then eq.start({grid}) end
end
''', 'Preserve source timed walk and authored one-way grid; no invented path.\nDolvad onset/onset2 inconsistency is corrected to the timer actually scheduled.\nPerl timers use seconds; Lua timers use milliseconds. Movement heading-2 is retained.')

emit('wakening/Berzerker_Voldak', '''
function event_spawn(e)
  eq.set_timer("onset1", 58000)
end
function event_timer(e)
  if e.timer ~= "onset1" then return end
  e.self:MoveTo(-4311, -720, -183, -2, true)
  eq.stop_timer("onset1")
end
function event_signal(e)
  if e.signal == 1 then
    eq.start(24)
    eq.signal(119168, 1, 300)
  elseif e.signal == 2 then
    e.self:Say("Woah! we're being ambushed!!")
    eq.signal(119168, 2, 300)
  end
end
''', 'Literal signal delays are milliseconds in BOTH Perl and Lua.\nOwner-scoped grid starts plus signals pass current structural preflight.\nNo public-world actor header: these are player-owned quest spawns.')

emit('wakening/Corporal_Hlash', '''
function event_spawn(e)
  eq.set_timer("onset", 60000)
  eq.set_timer("readygo", 150000)
end
function event_timer(e)
  if e.timer == "onset" then
    e.self:MoveTo(-4341, -748, -183, -2, true)
    eq.stop_timer("onset")
  elseif e.timer == "readygo" and e.self:GetX() == -4341 and e.self:GetY() == -748 then
    e.self:Say("Onward men, the eyes of Zek are upon us.")
    eq.stop_timer("readygo")
    eq.signal(119167, 1, 300)
    eq.signal(119166, 1, 300)
    eq.signal(119169, 1, 300)
  end
end
function event_waypoint_arrive(e)
  if e.wp == 5 then
    e.self:Say("Hold here squad")
    eq.signal(119050, 0, 300)
  end
end
function event_say(e)
  if e.message:findi("troop attack") and e.self:GetX() == -225 and e.self:GetY() == 1725 then
    e.self:Shout("Destroy them!!")
    eq.message(10, "Suddenly, all around the Sifaye village, several beings phase into reality.  Their eyes glow with the golden light of divinity, obviously sent from a higher plane of existence.  The Kromzek assault squad is surely doomed. You decided to withdraw and report what you have found, perhaps the Lieutenant will understand.")
    eq.signal(119167, 2, 300)
  end
end
function event_signal(e)
  if e.signal == 1 then
    eq.start(23)
  elseif e.signal == 2 then
    e.self:Say("Grraaaggh! AMBUSH!! Die well!")
    eq.spawn2(119174, 0, 0, -146, 1703, -192, 374)
    eq.spawn2(119174, 0, 0, -149, 1731, -192, 374)
    eq.spawn2(119174, 0, 0, -162, 1738, -192, 374)
    eq.spawn2(119174, 0, 0, -172, 1758, -192, 364)
  end
end
''', 'Retain authored route23, spatial speech gate, all four defenders and signals.\nPerl quest::signal(id,300) means Lua eq.signal(id,0,300), NOT signal ID300.\nP99 also describes phase pumas absent from Perl; no guessed extra actors are added.')

emit('wakening/a_sifaye_defender', '''
function event_spawn(e)
  eq.set_timer("leave", 300000)
  local target = eq.ChooseRandom(119166, 119167, 119168, 119169)
  -- EQEmu does not attack an absent target. Avoid the current runtime's
  -- unsupported deferred-empty-hate batch when a chosen giant has died.
  if eq.get_entity_list():GetMobByNpcTypeID(target).valid then
    eq.attack_npc_type(target)
  else
    e.self:Say("I am unable to locate NPC type " .. target)
  end
end
function event_timer(e)
  if e.timer ~= "leave" then return end
  eq.stop_timer("leave")
  eq.depop()
end
''', 'Preserve randomized NPC-versus-NPC aggression and300-second lifetime.\nNPC spell list10 requires a version5-ready scene; no attack is replaced by flavor.')

# These two caller extensions were separately authorized after the helper
# callgraph review. Dialogue is copied from the complete reviewed Perl bodies.
def texts(key, method):
    return [json.dumps(v) for v in re.findall(r'quest::' + method + r'\("([^"\n]*)"\)', (ROOT / ('sources/projecteq/' + key + '.pl')).read_text())]
p = texts('wakening/Phenocryst', 'emote')
emit('wakening/Phenocryst', f'''
local item_lib = require("items")
function event_say(e)
  if e.message:findi("hail") then e.self:Emote({p[0]})
  elseif e.message:findi("help you") then e.self:Emote({p[1]})
  elseif e.message:findi("find what") then e.self:Emote({p[2]})
  elseif e.message:findi("gather these stones for you") then
    e.self:Emote({p[3]})
    e.other:Faction(458, 10)
    e.other:SummonItem(1694)
  end
end
function event_trade(e)
  if item_lib.check_turn_in(e.trade, {{item1 = 1692}}) then
    e.self:Emote({p[4]})
    e.other:SummonItem(1701)
    e.other:Faction(458, 15)
  elseif item_lib.check_turn_in(e.trade, {{item1 = 1693}}) then
    e.self:Emote({p[5]})
    e.other:Faction(458, 15)
    eq.set_global("veliumfocus", "1", 5, "F")
  elseif item_lib.check_turn_in(e.trade, {{item1 = 1694, item2 = 1695, item3 = 1697, item4 = 1696}}) then
    e.self:Emote({p[6]})
    e.self:Emote({p[7]})
    e.other:Faction(458, 15)
    e.other:SummonItem(1698)
    eq.spawn2(119158, 0, 0, 408.10, -690.21, -201.55, 374)
    eq.spawn2(119158, 0, 0, -564.04, -985.80, -191.31, 374)
    eq.spawn2(119164, 0, 0, 303.02, 254.44, -201.54, 374)
    eq.set_timer("cleanup", 3600000)
  elseif item_lib.check_turn_in(e.trade, {{item1 = 1698, item2 = 1699, item3 = 1699, item4 = 1699}}) then
    e.self:Emote({p[8]})
    e.other:Faction(458, 10)
    e.other:SummonItem(1700)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
function event_timer(e)
  if e.timer ~= "cleanup" then return end
  eq.stop_timer("cleanup")
  eq.signal(119158, 0, 0)
  eq.signal(119164, 0, 0)
end
''', 'Authorized caller extension: all four classic hand-ins, all three giant spawns,\none-hour cleanup and faction deltas retained. P99 permits the amiable-faction\nshortcut; remove the artificial global gate under the repository faction policy.\nFix veliumfcous typo and return nonmatching items. These are source-backed\nstationary giants: P99 approach/cave-depop and postreward geonid procession have\nno authored route here and are NOT claimed implemented by this proposal.')

k = texts('wakening/Lieutenant_Krofer', 'say')
def named(s):
    return s.replace('$name', '" .. e.other:GetCleanName() .. "')
em = texts('wakening/Lieutenant_Krofer','emote')[0]
emit('wakening/Lieutenant_Krofer', f'''
local item_lib = require("items")
local function faction_reward(e)
  e.other:Faction(448, 10); e.other:Faction(419, 10)
  e.other:Faction(429, 10); e.other:Faction(430, -30)
end
function event_say(e)
  if e.message:findi("hail") then e.self:Say({k[3]})
  elseif e.message:findi("next assignment") then e.self:Say({k[5]})
  elseif e.message:findi("prepared") then
    e.self:Say({k[6]})
    e.other:SummonItem(1706)
  end
end
function event_trade(e)
  local qglobals = e.qglobals or {{}}
  if item_lib.check_turn_in(e.trade, {{item1 = 1702}}) then
    e.self:Say({named(k[7])})
    e.other:AddEXP(1000); e.other:Ding()
    eq.set_global("krofer_assignment", "1", 0, "F")
  elseif qglobals.krofer_assignment and item_lib.check_turn_in(e.trade, {{item1 = 22851, item2 = 22851, item3 = 22852, item4 = 1703}}) then
    e.self:Say({k[8]})
    e.other:Ding(); faction_reward(e); e.other:AddEXP(1000)
    e.other:GiveCash(1, 0, 2, 10)
    eq.delete_global("krofer_assignment")
    eq.set_global("tunarean_regiment", "1", 0, "F")
  elseif item_lib.check_turn_in(e.trade, {{item1 = 1704}}) then
    e.self:Say({named(k[9])})
    e.other:Ding(); faction_reward(e); e.other:AddEXP(1000)
    e.other:GiveCash(0, 5, 4, 11)
    e.other:SummonItem(1705)
  elseif item_lib.check_turn_in(e.trade, {{item1 = 1707}}) then
    e.self:Emote({em})
    e.other:AddEXP(1000); e.other:Ding(); e.other:SummonItem(1708)
    eq.spawn2(119168, 0, 0, -4975, -699, -182, 126)
    eq.spawn2(119166, 0, 0, -4954, -697, -182, 126)
    eq.spawn2(119167, 0, 0, -4954, -671, -182, 126)
    eq.spawn2(119169, 0, 0, -4976, -672, -182, 126)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
function event_signal(e)
  eq.spawn2(119173, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
  eq.depop_with_timer()
end
''', 'Authorized caller extension: preserve signed requisition, four distinct actors,\nmission report and signal-driven replacement. P99 says the meat/messenger parts\nare optional; prepared does not require the artificial tunarean_regiment global.\nKeep meat-assignment state, check it BEFORE consuming inputs, and return extras.\nP99 meat payment is10pp2gp1cp; other XP/cash/deltas remain explicitly upstream.\nFaction locks omitted per repository policy. The staged replacement preserves\nthe walkthrough warning against an immediate mission-report turn-in.')

fail = texts('wakening/#Lieutenant_Krofer', 'say')[0]
emit('wakening/#Lieutenant_Krofer', f'''
local item_lib = require("items")
function event_spawn(e) eq.set_timer("leave", 1500000) end
function event_trade(e)
  if item_lib.check_turn_in(e.trade, {{item1 = 1708}}) then
    e.self:Say({fail})
    e.other:AddEXP(1000); e.other:Ding(); e.other:SummonItem(1709)
    eq.depop()
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
function event_timer(e)
  if e.timer ~= "leave" then return end
  eq.stop_timer("leave")
  eq.depop()
end
''', 'Separately authorized exact receiver extension119173. Preserve25-minute\nlifetime, mission-report exchange,1000upstreamXP, and postreward depop.\nActual enabled=0 quest policy is retained, not bypassed by this conversion.')

rows = {}
for shard in (ROOT / 'data/quests').glob('*.ndjson'):
    for line in shard.read_text().splitlines():
        r = json.loads(line); rows[r['zone'] + '/' + r['name']] = r
proposal = dict(format=1, id='p99-conversion-world',
    summary='Source-bound world and quest-helper Lua conversions; preserve classic lifecycle effects, distinguish superseded controllers, and retain all three disabled caller policies.',
    baseManifestSha256='8bd2b042870b4e7e46141b811ed12e1a9dee453dcf03f2e07f06fccd4cc3e205',
    evidence=[dict(url='https://wiki.project1999.com/Coldain_Ring_Quests', note='Cached evidence and complete49-row source/runtime reconciliation are bound in changes/p99-conversion-world/closure-review.json; source odds, choreography and XP are not silently claimed P99 exact.'),
              dict(url='https://github.com/brynnb/idlequest-content/blob/b717b8a5c5dc5bd779d160b534c10329c1ae04bc/docs/runtime-contract.md', note='Public baseline contract plus read-only current implementation compatibility review. No private implementation source or documentation is redistributed.')], rows=[], sources=[])
for path in sorted(OUT.glob('*/*.lua')):
    key = path.parent.name + '/' + path.stem
    before = rows[key]
    after = dict(before, lua_content=path.read_text(), has_say_event=int('function event_say(' in path.read_text()))
    assert after['enabled'] == before['enabled']
    proposal['rows'].append(dict(table='quests', before=before, after=after))
    proposal['sources'].append(dict(target='maintained/lua/converted-perl/' + key + '.lua', beforeSha256=None, proposedFile=str(path.relative_to(ROOT)), afterSha256=SHA(path.read_bytes())))
(ROOT / 'changes/p99-conversion-world.json').write_text(json.dumps(proposal, indent=2) + '\n')
