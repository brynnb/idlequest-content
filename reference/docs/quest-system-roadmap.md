# Quest system checkpoint and implementation handoff

Current work: [P99 quest parity implementation plan](p99-quest-parity-plan.md)
(October 2, 2026). This document retains historical checkpoints. Consult the
current plan and generated audit results before treating an older pending,
scope or deployment statement below as current.

Updated September 6, 2026. Read alongside `p99-quest-audit-workflow.md`.

## Intent and boundaries

Make the documented P99 Classic/Kunark/Velious quest paths playable, with
IdleQuest's deliberate quest faction bypass. Prefer shared runtime capabilities
and data corrections over bespoke NPC logic. Keep upstream source untouched.
Missing evidence should become a recorded question, not an invented value.
Ordinary content edits need not wait for perfect historical certainty when a
defensible existing value works; ingredients, required items and outputs must
be identifiable and usable.

Do not deploy, alter production data, or push just because a batch passes.
These require separate authorization. Check dirty state before starting.

### October 3 newly confirmed shared boundaries

The ninth-ring rendered checks expose two further gaps; details and exact
records are in `coldain-ring-nine-audit.md`:

- `SetAppearance` and `DoAnim` currently do nothing in the Lua bridge. They are
  not yet represented in the deferred registry. Berradin's adapter records its
  omitted collapse explicitly. Do not call a source execution or loot pass
  visual parity; adding these to strict auditing must also consider existing
  runtime callers rather than suddenly reject unrelated cosmetic quest events.
- Shared player social assistance now follows server-compiled TAKP primary/
  directional relationships, verified with Berradin's four bodyguards. Dedicated
  profiles remove his kill rewards while preserving shared guard data. The
  remaining Harmony/lull radius gap is separate: the scan does not yet apply
  buff-modified assist radii. See coldain-ring-nine-audit.md for current receipts
  and source differences; do not force scripted hate as a substitute.

Juliah's separate incorrect shared court faction is corrected through existing
content data and has a before-failure/after-pass Docker combat-allowlist test.

## Current verification summary

### Current scope decision (user-directed)

Quest mechanics tests should reduce the exact quest-spawned enemy to 10 HP,
then use normal combat, actual death/corpse loot and the next hand-in. Do not
turn these into encounter-balance, raid, gearing or party-tactics projects.
Disclose reduced HP; do not fabricate a dead NPC or grant its reward. This
supersedes the earlier instructions below to prepare a stronger group for
Lhranc. Separate focused combat tests cover spell/proc correctness.

- [ ] **Deferred: finish/review NPC procs against raid actors.** Existing
  uncommitted work adds raid member/pet melee-proc dispatch, direct spell
  damage/death and spell-rune absorption through the shared runtime. Files:
  `runtimeNpcAttackTickSystem.ts`, `runtimeNpcSpellEffectApplicationSystem.ts`,
  `raid/runtimeContext.ts`, `raid/simulator/raidSimulator.ts`, and
  `testing/unit/npcRaidProcDispatch.test.ts`. Focused 29-test batch and nine
  raid-simulator tests passed, but this is not full raid spell/proc parity:
  review end-to-end proc execution, other spell effects, rune/death projection
  and rendered raid behavior before calling it complete. Leave this work
  parked; it is not a prerequisite for continuing quest mechanics tests.
  Resume only as a separately requested raid task. Preserve the existing dirty
  implementation; do not expand it to make a quest encounter easier to test.

Read this before the chronological checkpoints below. The full SK epic and
quest corpus remain incomplete; no deployment or push has been performed.

| Area | Verified evidence | Remaining |
| --- | --- | --- |
| Quest faction convenience | Shared Ally/max-friendly policy; Go tests retain independent eligibility gates | Do not restore faction grinding |
| Delivery continuity | Marl dialogue earns Seal, Gerot returns Note, Marl accepts it; GPU Docker passes without item grants | Only this short segment |
| Kurron chain | Fresh-server real fight, guaranteed earned letter and Duriek hand-in pass | Not the full epic |
| Caradon/Kyrenna and Glohnor | Connected GPU Docker passes in21.2m: real chest key, natural Caradon respawn, both attackers, actual Kyrenna drops, Marl's Shroud, Soulcase combine, Glohnor's mummy drops and Gerot/Marl hand-ins; all three ritual items retained together | No starting/intermediate item grants. Weapon branches and full epic remain separate; setup/travel/10HP fights are debug-assisted |
| Lhranc final content | Migration 135 and overrides applied locally; GPU Docker final-segment test passes: four entry items consumed, actual human spawned, reduced to 10 HP, normal combat death, corpse sword acquired (13.7s including GPU preflight) | Entry items are seeded; complete acquisition chain and full-strength encounter balance are not proven. Raid proc work is deferred separately |
| Nested dialogue | Override corpus classified; actual Serena response clicks and Lhranc regression pass on fresh server | Dynamic/helper phrases, broader corpus and post-response inventory projection |
| Runtime capability inventory | Explicit deferred API registry; strict tests and generated coverage exclude reached stubs | Exact general NPC lookup/enumeration, hate changes, movement and durable world-effect delivery remain incomplete |

## Foundation checkpoints

### Quellious natural acquisition exposes an inaccessible quest zone

The runtime-filtered dependency check finds Drogik101016 at20360, missionary56076
at3304, Glyssa9067 at9064 and Drigaz55157 at11218. Loot joins contain the
canonical necklace/document and bone/bronze ingredient IDs; raw chance fields
are not asserted as effective drop probabilities. Receipts:
`/var/tmp/idlequest-quellious-natural-sources.log` and
`/var/tmp/idlequest-quellious-spawn-dependencies.log`.

The first GPU natural-acquisition run killed real missionary56076/3304, but its
actual corpse had no items. Document acquisition remains unverified; do not
reroll through server restart or substitute later-era NPC448178 with100% loot.
Drogik was not reached: Warrens101 had `peqzone=0` despite populated spawn/loot
data and local rendered/nav assets. Migration126 enabled only the19-zone
Velious continent, not this Odus zone. Migration138 now enables only exact
Warrens101/version0 locally, with preimage and checksum receipt
`/var/tmp/idlequest-local-migration138-receipt.log`. Temporary-table tests prove
idempotence and leave alternate versions, Stonebrunt and tutorials unchanged:
`/var/tmp/idlequest-warrens-access-tests.log`.

The shared spawn-dependency command now checks normal player zone lookup too,
so selectable NPCs in an inaccessible zone no longer produce an overall pass.
Stonebrunt100 also remains disabled, but its rendered zone assets are absent
locally (a nav file alone is insufficient); prepare/verify those assets before
considering a separate enablement. Do not expand the Velious continent set.

The original server accepted Warrens after the row correction, but its cached
zone list still omitted it: the client snapshot had id101/shortName"101",
gameReadyfalse and navmeshLoadedfalse. This is a local live-migration cache
boundary, not a successful rendered zone transition. The original server was
preserved for Sky timers; use a fresh isolated stack for Warrens verification.
No production change. First failure receipt:
`/var/tmp/idlequest-quellious-regent-acquisition-e2e.log`.

Fresh isolated-stack GPU verification passes (2 tests including hardware
preflight,28.5s): Warrens loads, real Drogik101016/20360 dies after10-current-HP
setup, actual corpse includes14585, and that necklace goes through Leraena,
Glyssa and Drigaz to earn1780. Both letters and the necklace have the correct
return/consumption behavior. No reward or intermediate item grants. Receipt:
`/var/tmp/idlequest-quellious-drogik-fresh-e2e.log`. This run does not include
the missionary or the final three-item Regent hand-in. The isolated server was
stopped only after this completed run; do not restart it to reroll Drogik loot.
The original server remains alive. Typecheck passed:
`/var/tmp/idlequest-quellious-regent-typecheck.log`.

### Quellious symbols: rendered sacks, combines and two symbol hand-ins pass

Migration137 is now applied **locally only**, with the two recipe preimages and
checksum recorded in `/var/tmp/idlequest-local-migration137-receipt.log`.
The GPU Docker `quest-quellious-combines.spec.ts` passes (2 tests including
hardware preflight,16.7s): click Leraena's dialogue option to earn sack17090,
combine eight seeded raw bone necklaces into14582, hand it in for1564, earn a
second sack, combine eight seeded bronze necklaces into14583, then give that
and the **earned**1564 for1565. Exact ingredients and sacks are consumed; no
filled bag, sack or symbol is granted by debug. This is a connected crafting/
hand-in segment, not natural necklace acquisition or the full Regent chain.
Receipt: `/var/tmp/idlequest-quellious-combines-registry-e2e.log`.

The run exposed and fixed a shared client bug: ContainerInventoryModal used
the Advanced recipe listing to decide whether to show manual Combine for quest
containers. `show_in_advanced=0` correctly hid these recipes from that listing,
but incorrectly removed their Combine button too. Removed the redundant async
listing check; exact generated container registry recognition controls the UI,
and existing server recipe/ownership authorization remains unchanged. No
recipe visibility relaxation or quest-specific UI exception was added.
Earlier fixture attempts incorrectly used nearby `/say` instead of the NPC
dialogue panel, then used a non-displayed phrase; those were test-path errors,
not grounds to grant rewards or change dialogue dispatch.

Restored Leraena's Initiate/Disciple/Regent dialogue and hand-ins in the
modified-upstream override, and corrected Glyssa's documented faction rewards.
Focused real Lua execution tests pass for each hand-off, both shaman/shamen
dialogue spellings, missing required items, unrelated offered-item preservation,
and rejection at level19 versus success at level20. The level gate precedes
item consumption. Existing paw/guild reward regression tests still pass.
Log: `/var/tmp/idlequest-quellious-turnins.log`.

P99 does not give Initiate XP/faction amounts; that stage uses the preceding
temple quest's modest 500XP and +20/+5/-5 faction scale as an explicit IdleQuest
approximation. This is source-level verification, not a completed acquisition
chain: the updated overrides were targeted-imported locally (receipt
`/var/tmp/idlequest-quellious-import.log`). The subsequent local combine
verification is recorded above. No production changes were made. Next: verify
actual necklace and missionary acquisition and extend the Regent hand-offs.

Reviewed the preserved Quellious Symbol Quests page (Warrens era), upstream
Leraena/Glyssa/Drigaz sources and current item/recipe rows. Restoring Lua alone
would still fail: sack17090 was absent from the registry and recipes9754/9755
were disabled. Added the eight-slot Velious sack to the authoritative registry,
limited to those exact recipes, and regenerated the client definitions through
`gen_tradeskill_containers`. Migration137 enables only the two verified recipes,
sets Velious minimum expansion and hides Advanced crafting; existing no-fail
and consumed-sack behavior stays intact. Registry tests, temporary-table
migration/idempotence tests, and typecheck pass:
`/var/tmp/idlequest-quellious-container-go.log`,
`/var/tmp/idlequest-quellious-container-sql.log`,
`/var/tmp/idlequest-quellious-container-typecheck.log`.

The remaining packet is the Regent letter/necklace/translation/document chain
and natural source acquisition checks. Preserve real item/level prerequisites
and only waive faction. Do not advertise the entire quest chain as verified.
The separate test server used the updated registry; the original server and
its Sky respawn timers were preserved. No production change.

The GPU Docker hand-in regression now passes both paw handling and Disciple
eligibility (3 tests including RX9070XT preflight,20.2s). The Disciple test seeds
only its two entry items, offers both at level19 and verifies their return with
no XP/reward, then debug-levels to20 and gives the same returned items through
the rendered Give UI. Both are consumed and exactly one Disciple symbol appears.
This proves isolated eligibility/transaction behavior, not necklace acquisition
or the sack combine. Logs: `/var/tmp/idlequest-quellious-level-e2e.log` and
`/var/tmp/idlequest-quellious-level-typecheck.log` (typecheck passed).

### Leraena rendered hand-in passes; natural acquisition remains separate

New `quest-leraena-paws.spec.ts` runs with3D enabled, real dialogue controls and
Give UI on existing dev73593. It seeds four initial nonstackable paws explicitly:
two offered are returned with no scroll/currency/XP; four offered consume exactly
three, leave one, and grant one valid scroll,170 copper-equivalent and XP.
Class is Paladin6 and stored faction is hostile. Hardware-GPU exec75610 passes
both tests in9.7s including RX9070XT preflight:
`/var/tmp/idlequest-leraena-e2e-actual-npc.log`. Typecheck passed before the
subsequent locator/NPC-ID-only corrections.

Initial runs failed on a stale NPC ID copied from the upstream trailing comment;
the actual local Leraena record is24081, not98079. Corrected that fixture and
used the existing span-based dialogue controls. No NPC replacement, response
injection, population reset or gameplay workaround. Previous failed receipts:
`/var/tmp/idlequest-leraena-e2e.log`,
`/var/tmp/idlequest-leraena-e2e-locators.log`.

Read-only runtime dependency check confirms original paw-bearing38145 at
Toxxulia placement3582/group4932, selection probability50%, respawn640s.
Types38172/414078/414080/414192 are not eligible there:
`/var/tmp/idlequest-leraena-paw-sources.log`. This checker intentionally exits1
for those absent candidates. No claim of full paw acquisition, effective drop
probability or continuous quest completion. Ledger evidence updated; no
production change, commit, push or deployment. Original Sky server preserved.

### Preserved-cache relocation reader repaired

Title triage no longer opens stale absolute paths in the removed
idlequest-quest-turnin-tests checkout. It resolves the original declared
raw-pages member inside the current cache, preserving the untouched historical
manifest. Before classification it verifies metadata title, byte length and
SHA256; missing files, path traversal and substituted content fail explicitly.
Node regression passes (`/var/tmp/idlequest-cache-reader-tests.log`). Actual
triage now completes over217 title candidates:21 ledger-covered,196 otherwise
classified,0 remaining manual review (`/var/tmp/idlequest-cache-triage-fixed.log`).
This closes the tooling failure below, not the918-page quest behavior audit.

Leraena acquisition remains pending. Read-only local loot joins identify
Odd Kobold Paw13883 on original NPC38145 at chance2.45 and38172 at2.8, plus
imported414xxx variants with different chances. These numbers are raw loot
entry values, not verified effective drop probabilities or proof of eligible
placements. Verify actual Toxxulia population/source provenance before choosing
a continuous fixture; do not pick the higher-rate imported variants merely to
get a passing test. No drops, NPCs, timers or production data were changed.

### Leraena's Velious paw quest restored; rendered check pending

The July ledger excluded Kobold Shaman Paws only because of Kunark-only scope.
Reviewed its preserved P99 page and metadata (July17 SHA256
00ae321646305a1b409c646f36142ed7fb1d19bb6b8efad9201c13d8fce2a427), actual
upstream/override, and local item records13883/15011/15213. Restored the
three-paw branch in the existing modified-upstream override; the specific
slay response precedes the broad shaman topic so it is reachable. Separate
Warrens symbol/Stonebrunt chains are not silently enabled or advertised.
P99 faction deltas replace upstream mismatches; XP500 and equal scroll choice
remain disclosed upstream approximations, and17 silver uses the documented
example. The ledger records these decisions and the lack of acquisition/E2E
proof. Do not infer a hard class/level gate from an advisory minimum-level table.

Focused Go tests pass for directions, hostile faction,0-4 paws, exact consumption,
one valid scroll and preservation of guild-note behavior:
`/var/tmp/idlequest-leraena-paws-go.log`. Canonical targeted importer dry-run and
local apply completed, changing only erudnext/Leraena_Shelyrak:
`/var/tmp/idlequest-leraena-import-preview.log`,
`/var/tmp/idlequest-leraena-import-apply.log`. No server restart or production
change. Next: rendered hand-in and actual paw-acquisition evidence.

Content audit reports no unexpected enabled later-era rows:
`/var/tmp/idlequest-leraena-content-audit.log`. Title triage is blocked by a
stale absolute cache path pointing into removed idlequest-quest-turnin-tests,
not by a verified missing preserved page:
`/var/tmp/idlequest-leraena-title-triage.log`. Repair that reader against the
preserved current cache without rewriting historical provenance or claiming
the triage gate passed.

### Fresh-build browser integration without resetting the Sky camp

Built a separate local test server on18080/14433/17100 (exec81031) and Vite
on5174 (exec97891), following the documented split setup. Original dev73593
was not restarted. Hardware-GPU Docker exec48608 passed all seven checks in
1.1m on the RX9070XT:
`/var/tmp/idlequest-quest-isolated-integration.log`.

Command: `E2E_APP_URL=http://localhost:5174 IDLEQUEST_REAL_GAME_E2E=true
IDLEQUEST_E2E_CONTENT_AUDIT=true npm run test:e2e:docker --
testing/e2e/quest-dialogue-discovery.spec.ts testing/e2e/quest-npc-buff.spec.ts
testing/e2e/quest-npc-healing.spec.ts --project=chromium --workers=1
--reporter=line`.

Covers Teydar's genuine SK/Enchanter distinction with hostile stored faction,
Lhranc's response options, nested Serena responses, Jemoz's single Holy Armor
and camp/relogin persistence, and Ulazia's healing/refund boundary. This is
integration coverage on the newer state-serialization/alias code, not a browser
reproduction of every alias shape or a complete quest/epic acquisition chain.
The typed-key and alias specifics remain proven by focused/SQL tests above.

Stopped only the extra owned server/client handles after success. Both are
terminal, their TCP ports are closed, and original5173 still responds. No Sky
encounter was run on the fresh instance; no original population reset or loot
reroll was used. The original server still has the older build until its camp
check is finished. No production changes, push, deployment or commit.

### Shared table identity restored with explicit metadata

The two alias regressions below are now fixed. `table_state_aliases.go` records
actual shared-table paths as `lua:table-aliases` alongside existing serialized
values, then reconnects those paths after hydration. Paths use the same typed
key encoding as table values. Roots and children are sorted for stable output;
metadata is replaced even when empty so deliberately split references do not
revive. No identity is inferred from equal values or source initializers.
Invalid/missing alias endpoints reject execution before rewards, including
dialogue probes. Older state without metadata cannot recover historic identity.
Cycles and function-bearing table values remain unsupported.

Focused tests cover root/nested/global aliases, joining, clearing, deliberately
separated equal-valued tables, old key decoding, and malformed metadata:
`/var/tmp/idlequest-quest-alias-validation.log`. Real temporary-table tests
verify shared identity through a second SQL-backed invocation for hail,
keyword, NPC and player events while retaining rollback/retry checks:
`/var/tmp/idlequest-quest-alias-sql.log`. Broad Go run: world passes; quest
still fails only the Tundra Jack source-matrix missing-resolver case:
`/var/tmp/idlequest-quest-alias-full.log`.

These are shared runtime/persistence checks, not a new P99 content claim or
rendered test. Dev73593 remains unchanged/running to preserve the Sky natural
respawn clock. The new server code still needs a fresh-server browser
integration checkpoint; no production changes, push or deployment occurred.

### Shared Lua table identity: reproduced, implementation pending

New `TestLuaHelperStateAcrossFreshEvents/shared_table_alias` and
`nested_table_alias` regressions fail on the second event. Two variables
referencing the same data table (or one referencing a nested table) are restored
as separate objects by `applyLuaScriptState`. Log:
`/var/tmp/idlequest-quest-table-alias-before.log`. These two new tests are
intentionally red at this checkpoint; the earlier key-encoding fix remains
separate. No production/server restart occurred.

Persist explicit alias relationships alongside serializable table values, then
restore those relationships after value hydration. Do not infer shared identity
from equal contents, or always preserve the source initializer's aliases: a
quest can deliberately replace one variable with a distinct equal-valued table
during an event. Test shared, nested, deliberately separated equal tables,
reassignment and clearing before claiming identity preservation. Cycles and
function-bearing tables remain an explicitly separate serialization limitation.

### Durable Lua table keys no longer collide

Shared state serialization previously truncated numeric keys with `int`, and
encoded integer1 and literal string`"#1"` identically. A fresh-VM regression
with keys1,1.5,`"#1"` and a reserved-prefix string reproduced a nil lookup on
the second event (`/var/tmp/idlequest-quest-table-keys-before.log`).
`closure_state.go` now owns typed key encoding/decoding used by the existing
serializer and Lua value reconstruction. Ordinary integer keys retain their
existing format; fractional keys use an explicit numeric prefix and reserved
string prefixes are escaped. Old integer saves and old noninteger string keys
still read as before. Values already lost to historical collisions cannot be
recovered by this change. Function-bearing/cyclic table persistence remains a
separate unsupported boundary; this does not serialize arbitrary Lua graphs.

Focused helper/cleared-state/dialogue/key tests pass:
`/var/tmp/idlequest-quest-table-keys-final.log`. Real temporary-table tests
exercise typed keys through SQL state persistence and a second fresh invocation
for hail, keyword, NPC and player events, retaining rollback/retry assertions:
`/var/tmp/idlequest-quest-table-keys-sql.log`. Broader Go run world passes; quest
still fails only the documented Tundra Jack source-matrix missing resolver:
`/var/tmp/idlequest-quest-table-keys-go.log`. No claim of an identified P99
content record affected by these particular key shapes, or rendered verification
of this change. Dev73593 has not been rebuilt; Sky's natural population timer
has not been reset.

Slot-aware inventory investigation remains deferred: current boolean inventory
projection has quantities but no exact offered-instance locations, and the
vendored client_ext helpers also depend on slot ranges. Do not invent a slot
mapping or silently choose which same-item instance was handed in. The current
fail-closed APIs remain unchanged; no in-scope override caller was established
in this pass.

### Sky pursuit failure diagnosed without a population reset

GPU Docker run79270 (existing dev73593, no restart) produced actual corpses
2657 and2658, then timed out on2659. Unlike the earlier death failure, the
captured player remained alive at2465/2465 HP in airplane. The runtime actor
2659 had10/12259 HP and was fleeing78.1 units away; navigation was inactive.
The selected-target display still reported full HP, so use the runtime actor
record when diagnosing this boundary. Log:
`/var/tmp/idlequest-sky-guarded-followup.log`.

The manual-combat fixture now reissues the real `/nav target` command when
navigation has finished and the same live target leaves melee range. It keeps
the original30-second kill timeout, exact-target assertion, actual death/loot
receipt and living-character/zone guard. No warp, damage grant beyond the
declared10HP setup, fake death, raid or loot override was added. This is a
manual test-driver correction, not a change to AutoLevel pursuit policy.

Typecheck passed (`/var/tmp/idlequest-sky-pursuit-typecheck.log`). Serialized
GPU rerun31439 could not reach combat: the prior two real kills left only
eight live azaracks, so the unchanged ten-live precondition failed. Log:
`/var/tmp/idlequest-sky-pursuit-followup.log`. Do not report the pursuit change
as browser-verified or the Protector trigger as passed. Retry after natural
population recovery; do not restart dev73593 or reset spawns for this purpose.

The mixed-effect investigation additionally confirmed
`client/client_combat.go:GetMaxHp` deliberately returns0 because HP is
client-computed. Client `mechanics/bonusCalc.ts` includes capped total stamina,
item HP and spell HP. Server `Mob.CalcMaxHP` is not an interchangeable source
for that projection. Keep the mixed-batch limitation explicit until these
semantics can be shared, rather than installing an invented HP delta.

### Scoped NPC content regression and mixed-effect investigation

Raid work remains parked in the unchecked TODO above. Added
`npc_lookup_content_test.go` against the actual upstream Tundra Jack signal
handler: the fixture explicitly supplies Iceberg (NPC type30062, a distinct
spawn), verifies the requested identity, and proves strict execution still
rejects unimplemented `eq.follow`. Compatibility execution records that
deferred effect. Focused lookup/security/content tests pass:
`/var/tmp/idlequest-quest-scoped-content.log`. This is a source/runtime
regression, not a rendered escort test or P99 authority verification. The
source-only database matrix's missing-resolver failure is not suppressed.

- [ ] Before preparing mixed buff/heal quest batches, unify projected maximum
  HP semantics. `playerSessionVitals` prefers `LivePosition.MaxHP`, whereas
  buff publication invokes `Mob.CalcSpellBonuses` and does not update that
  live maximum. `Mob.CalcMaxHP` is a separate operation. Simply chaining a
  copied buff list with the old live maximum would miscalculate healing;
  inventing a server/client delta is not a verified solution. Preserve ordered
  effects and test HP buffs, stacking rejection, percentage healing and
  rollback before removing the current mixed-batch limitation.

### Existing-NPC buff batches join quest settlement

`preparePlayerBuffFromSource` now shares ordinary buff stacking, persistence
and projection between item/player casting and parent quest transactions.
Preparation uses a copied mob/buff list, never early live mutation. Successive
buffs evaluate against the prior prepared list; a weaker blocked buff is a
valid committed cast, with no replacement of the stronger buff. Existing
partial cure counters survive serialization. Publication checks character
identity; ordinary non-transactional SaveBuffs behavior is retained explicitly.
`prepareQuestEffectSettlement` now includes pure buff batches as well as pure
heal batches. Mixed heal/buff sequences remain on their existing path until
projected stat/vitals ordering is implemented; spawn-dependent effects and
cures remain incomplete.

Real temporary-table tests prove rollback/payment retention, ordered stacking,
counter preservation, commit-before-publication, and actual world-resolved buff
plans skipping duplicate legacy delivery. Logs:
`/var/tmp/idlequest-prepared-buff-sql.log`,
`/var/tmp/idlequest-buff-world-sql.log`,
`/var/tmp/idlequest-prepared-buff-focused.log`.

New `quest-npc-buff.spec.ts` uses actual freportn/Jemoz_Lerkarson dialogue:
Hail -> click "devoted to truth" -> one NPC-attributed Holy Armor11 -> camp and
re-enter the same character -> saved buff remains. No item, buff or NPC is
granted for this test; only initial travel/debug setup is used. Effective
source: modified-upstream/freportn/Jemoz_Lerkarson.lua. This covers that dialogue
reward, not his full Militia Helm quest or a broad P99-content audit.

Dev37914 stopped cleanly; rebuilt dev73593 is current. Initial browser exec63272
failed before gameplay because Vite was not ready (connection refused). After
confirming HTTP readiness, serialized GPU exec84473 passed all three tests in
26.2s including RX9070XT preflight and the healing/refund regression:
`/var/tmp/idlequest-quest-buff-ready-browser.log`. Typecheck passed:
`/var/tmp/idlequest-quest-buff-typecheck.log`. Final Go run: world passes, quest
retains only the known Tundra Jack missing-resolver matrix failure:
`/var/tmp/idlequest-quest-buff-final-go.log`.
No migration, production deployment or spawn reroll test was performed.

### Direct quest healing joins payment and progress settlement

The live world service now supplies prepared effect settlements to both
`settleQuestTurnIn` and ordinary event settlement. A batch of instantaneous
heals from existing NPCs persists inside the same transaction as payment,
inventory and quest-state writes, then publishes after commit. Multiple heals
use ordered projected HP rather than each starting from the original value.
Server-only `QuestSpellCast.Settled` prevents the later world delivery pass from
applying committed heals again; it cannot be supplied through JSON.

Real temporary-table tests verify effect-write failure rolls back payment, HP,
state and transaction receipt; retry succeeds; duplicate hand-in IDs do not
publish twice. Hail, keyword, NPC and player callback tests also inject effect
write failure and verify rollback/no publication. World SQL tests exercise
the real resolved NPC spell plan and prove later legacy capture delivery does
not send a second heal. Ordered HP and replacement-character tests pass.
Logs: `/var/tmp/idlequest-atomic-quest-heal-sql.log`,
`/var/tmp/idlequest-atomic-effects-event-sql.log`. Full world tests pass; quest
tests retain the known Tundra Jack resolver failure:
`/var/tmp/idlequest-atomic-quest-heal-integration.log`.

Scope remains explicit: mixed timed-buff/spawn-dependent sequences use their
existing delivery path until they have transaction plans too; this is not an
outbox for every world effect. Cures remain rejected. Concurrent live-vitals
changes during preparation/commit and reconnect recovery still need dedicated
verification. Dev22982 stopped after prior tests; rebuilt dev37914 is running
the new integration. GPU regression exec2047 passed seven tests in1.0m,
`/var/tmp/idlequest-atomic-quest-heal-browser.log`. The healer spec now also
requires exactly one heal after the successful reliable-stream turn-in response;
focused exec38369 passed both tests including RX9070XT preflight in12.1s,
`/var/tmp/idlequest-atomic-heal-once-browser.log`. Typecheck passed:
`/var/tmp/idlequest-atomic-heal-typecheck.log`. Browser checks verify successful
donation and rejected cure refunds; SQL tests provide injected-failure evidence.
No migration, production deployment or rare-drop reroll was performed.

### Shared prepared healing supports a parent payment transaction

`preparePlayerHealFromSource` now separates effect preparation, durable writes
and post-commit publication. The existing ordinary/NPC heal executor uses this
same plan; formulas, clamping, attribution and notifications are not duplicated.
Preparation/persistence do not mutate live HP or send packets. The plan retains
its original character ID and refuses publication to a replacement character
on the same session. A real temporary-table test includes payment and healing
in one transaction, verifies rollback of both, and proves successful commit
precedes live HP/notification publication. Existing world-capture healing and
partial-counter persistence SQL tests still pass. Full world suite and focused
replacement-character tests pass. Logs:
`/var/tmp/idlequest-prepared-heal-focused.log`,
`/var/tmp/idlequest-prepared-heal-sql.log`,
`/var/tmp/idlequest-prepared-heal-world.log`.

This is the shared execution primitive, NOT completed atomic donation delivery:
the live quest hand-in/event settlement must next persist prepared effects
inside its own transaction, publish after commit, and suppress duplicate legacy
application. Multi-spell ordering and reconnect/race behavior need integration
tests at that boundary. Buffs and client-owned cures are not yet prepared this
way. Running dev22982 predates this extraction; no browser rerun, migration,
production change or spawn reset in this checkpoint.

### Ordinary quest events preflight effects before committing progress

Hand-ins already called the world-effect validator before settlement, but hail,
keyword, NPC and player events committed character/script state before world
delivery discovered unsupported effects. The event settlement boundary now
calls a configure-once validator supplied by `NewWorldHandler`, reusing the
same `validateQuestRuntimeCapture` as hand-ins. World keeps actor/session and
effect validation; quest service keeps transaction ownership. Missing online
owners produce an error rather than a nil-session panic. This is preflight,
not guaranteed delivery: post-preflight races still require durable recovery.

Real temporary-table tests inject a rejected effect across all four entry
points and verify zero EXP, currency, globals or primary/registered script
state, then exercise normal rollback/retry. Removing the new hook reproduced
false-success on every path; the hook was restored before final tests.
Evidence: `/var/tmp/idlequest-event-preflight-before.log`,
`/var/tmp/idlequest-event-preflight-sql.log`. Full world suite passes; full quest
suite retains only the known Tundra Jack resolver failure:
`/var/tmp/idlequest-event-preflight-integration.log`.

Dev48234 stopped after completed prior browser work; rebuilt dev22982 runs this
change. Serialized GPU dialogue/healing/isolated Soulcase regression exec86962
passed all seven tests including RX9070XT preflight in1.1m,
log `/var/tmp/idlequest-event-preflight-browser.log`. Soulcase's entry Heart is
seeded; this is not full epic acquisition. Server logs explicitly show deferred
movement rejected at preflight for spawn21922 and others. Donation cures remain
rejected. Reconnect inspection confirms `entity.Buff.Counters` is saved but
intentionally not serialized; login/buff payloads and mechanics ActiveBuff omit
per-kind counters, while live combat retains them in canonical actor effects.
Connecting cure delivery must also reconcile this persistence/projection gap;
do not enable it with an unacknowledged client packet.

### Quest healing preflight shares the actual effect calculator

`instantPlayerHealEffectAmount` now owns supported-effect recognition and the
existing heal formulas for effects0/79/101/147. Ordinary spell execution and
quest preflight call it; quests no longer reject a supported instantaneous heal
merely because it is not effect0. Unsupported/mixed cure or damaging slots still
fail before settlement. Regression first failed on effect79, then passed all
four families with actual NPC-attributed HP application and clamping; mixed-slot
rejection tests pass. Full world suite and real temporary-table buff/counter
settlement checks pass. Logs: `/var/tmp/idlequest-quest-heal-parity-before.log`,
`/var/tmp/idlequest-quest-heal-parity-after.log`,
`/var/tmp/idlequest-quest-heal-world.log`, `/var/tmp/idlequest-quest-heal-sql.log`.
The no-mutation test reads `playerSessionVitals`, matching the fixture's
character-data HP, rather than an unsynchronized mock mob's default100HP.

Read-only local spell check: Complete Heal13 is effect0/base7500, not effect101;
Light Healing17 is effect0/base35. Cure Poison203 is effect36/base-1 and Cure
Disease213 effect35/base-1. Do not describe this as a Complete Heal repair or
working donation cures. The external cure adapter still lacks durable delivery.
Dev22308 stopped cleanly; rebuilt dev48234 includes this and table-helper state
changes. GPU healing regression exec95628 passed: two tests including RX9070XT
preflight in13.0s, log `/var/tmp/idlequest-heal-parity-browser.log`. The rendered
case verifies actual Light Healing donation, source attribution and rejected
cure refunds; the additional heal-family coverage is server-level, not browser
verification of those extra families. No migration or production changes.

### Table-held helper closure state covered

Two new fresh-VM/JSON cases reproduced lost counters in local helper tables and
nested global helper tables. The shared closure traversal now follows Lua
functions through table string/number keys with deterministic ordering and
visited-table identity. Self-referencing tables terminate; independently
instantiated same-name counters retain separate keys. Existing directly
reachable function roots are visited first to preserve their established paths.
Imported table-method patterns exist (for example Saxarivza's `eq.reject_say`
and module methods); this is evidence of the calling pattern, not a claim that
those individual quests contain the synthetic regression's lost counter.

All six helper cases plus cleared/direct/table state and registered-callback
tests pass. Real temporary-table rollback/retry tests pass; full world tests
pass and full quest tests retain only the known Tundra Jack resolver failure.
Logs: `/var/tmp/idlequest-table-helper-before.log`,
`/var/tmp/idlequest-table-helper-after.log`,
`/var/tmp/idlequest-table-helper-sql.log`,
`/var/tmp/idlequest-table-helper-integration.log`.

This preserves variables captured by table-held functions; it is NOT arbitrary
Lua object graph serialization. Mixed tables containing both scalar state and
methods, table alias identity, dynamic closure replacement and function/userdata
table keys remain outside the verified persistence contract. No browser rerun
or dev-server restart for this source-only checkpoint; the prior seven-test
browser pass predates this extension.

### Corrected Sky chase fixture reaches a new failure boundary

Follow-up read-only local DB inspection confirms player death, not an unexplained
travel request: `character_corpses.id=186`, `charid=2710`, `zone_id=71`,
position(-502.551,-110.408,-355.025). Character2710 is now in zone9 with35HP;
its saved bind rows also name zone9. The corpse's `killed_by=0` does not identify
the damage source, so this does not establish combat damage versus falling.
The test now uses the existing `questCampGuard` during corpse waits to fail
immediately on death/zone change rather than waiting30s for loot. All eight
guard tests and typecheck pass (`/var/tmp/idlequest-sky-death-guard.log`,
`/var/tmp/idlequest-sky-death-typecheck.log`). This fixture adjustment has not
been rerun; four-hour spawn availability has not been reset.

Fixture setup detail: `debug target hp 10` calls
`combatService.debugSetRuntimeNpcHp`, which applies damage to current HP but
retains original maximum HP. It is not a10/10HP creature and may trigger normal
low-health behavior. No maximum-HP override, flee suppression, immunity, extra
gear or party changes were introduced during this diagnosis. Determine the
actual death/chase sequence before selecting further test-only accommodations.

On rebuilt dev22308 (rebuilt for verified Lua-state fixes, not to reroll loot),
the corrected `quest-sky-protector-trigger.spec.ts` ran serialized on RX9070XT.
Exec11527 failed in 42.9s after actual corpses2657,2658,2659,2660: navigation now
passes the former fourth-target approach failure. The fifth corpse wait timed
out. Server recorded test character2710 leaving zone71 for zone9 at02:16:17,
then rejecting end-combat messages for2661,2662,2663 because its active set had
already been cleared by zoning. Evidence:
`/var/tmp/idlequest-sky-trigger-corrected.log` and
`/var/tmp/idlequest-closure-state-dev.log`. This does not prove whether death,
fall/zone geometry or another transition caused the zone exit. No boss spawn,
boss death or Blade acquisition is proven. No restart/reset or reward grant
was used after this failure.

The fixture now captures a compact zone/player/target/navigation/active-enemy
and recent-event snapshot before camp on failure; it retains the exact corpse
assertion and original timeout. This diagnostic addition has not been rerun
against a reset population. Next reproduction must use legitimate availability
and distinguish player death from navigation/zone exit before changing gameplay
or adding test survivability accommodations.

Cure-delivery reinspection also confirms the existing
`runtimeExternalCounterCureSystem.ts` adapter is tested but has no production
caller. `NetworkBridge.handlePlayerBuffUpdate` updates buffs/vitals only, and
`quest_spells.go` intentionally rejects instantaneous effects35/36. Keep that
preflight until owner-scoped, correlated delivery, persistence/reconnect and
donation recovery are connected; do not add a second cure implementation or
claim that sending an unacknowledged packet completes this boundary.

### Explicitly cleared quest flags no longer revive

Fresh-VM regression reproduced both local and global `stage=nil` reverting to
the saved `ready` value on the next event. `serializableLuaValue` now represents
Lua nil as JSON null. Capture retains null for removed, previously tracked
globals; the pre-event snapshot also tracks initialized globals cleared during
the very first event. Registered NPC/player callbacks restore their saved state
after clearing encounter-load effects, preserving tombstones across callbacks.
This leaves non-Lua state such as NPC-added loot untouched.

Tests cover local/global flags, set-then-clear, clearing on the first event, and
repeated reads through fresh VMs and JSON. Focused helper/registered-state tests
and real temporary-table transaction rollback/retry pass. Logs:
`/var/tmp/idlequest-cleared-state-before.log`,
`/var/tmp/idlequest-cleared-state-after.log`,
`/var/tmp/idlequest-cleared-state-sql.log`. Full quest/world run retains the
known Tundra Jack resolver failure only; world passes:
`/var/tmp/idlequest-cleared-state-integration.log`.

Owned dev36362 stopped cleanly after earlier browser completion; rebuilt
dev22308 includes both closure and cleared-state fixes, log
`/var/tmp/idlequest-closure-state-dev.log`. Serialized GPU dialogue/healing/
isolated Soulcase verification exec4239 finished successfully: seven tests
including RX9070XT preflight passed in 1.1 minutes, log
`/var/tmp/idlequest-closure-state-browser.log`. Soulcase still seeds the entry
Heart; this is not full epic acquisition. No spawn reset or rare-drop reroll
test accompanies this rebuild. Server logs retain deferred movement at
spawn21922, timer2815's unsupported eq.start, and Ulazia cure-spell preflight
rejections (the test verifies refunds for those unsupported cures). These
passes do not clear those implementation gaps.

### Helper-owned quest state now survives fresh Lua VMs

`closure_state.go` discovers Lua function upvalues through the script's global
functions and the active callback, recursively following helper closures.
Function and upvalue identity deduplicate shared references and terminate
recursive cycles. Sorted global roots make traversal independent of Lua table
iteration order and of which named event is running. Unique variable names keep
existing `upvalue:name` keys; independent same-name variables use separate
`closure:path` keys instead of overwriting one another. Ambiguous legacy values
cannot be reliably assigned to either independent variable and are not copied
into both. No migration reconstructs previously lost progress.

Before the fix, fresh-event tests returned `count=1` instead of `count=2`, and
independent counters returned `1:11` instead of `2:12`. Four regression cases
now pass through JSON serialization and fresh Lua VMs: nested helpers, separate
factory closures, recursive/shared state, and cross-event closures. Existing
direct scalar/table and registered-encounter state tests also pass. The real
temporary-table failure/rollback/retry test now puts its counter back inside the
reward helper, rather than avoiding the original failing pattern, and passes.
Evidence: `/var/tmp/idlequest-closure-state-before.log`,
`/var/tmp/idlequest-closure-state-after.log`,
`/var/tmp/idlequest-closure-state-sql.log`. Full quest/world run retains only the
known Tundra Jack missing-resolver failure; world passes:
`/var/tmp/idlequest-closure-state-integration.log`.

This is source and real DB regression verification, not a new rendered quest
playthrough. The running dev server has not yet been restarted for this change.
The newer checkpoint covers closures stored inside tables. Dynamically replaced
closure identity and table alias identity still need dedicated persistence review; nil/deleted scalar
state is handled by the newer checkpoint above. This
does not claim arbitrary Lua object-graph persistence or close the world-effect
delivery/recovery backlog below.

### Dialogue/runtime character and script-state settlement consolidated

The old `persistQuestCapture` ignored write failures and could report success
after only some globals, EXP, currency, faction, skills or tasks were saved.
Actor script state and registered-encounter state were committed separately.
An injected currency-column failure reproduced success plus surviving globals,
EXP and script state across hail, keyword, NPC and player event entry points.

`event_settlement.go` now commits these character changes and staged script
state through the existing `persistQuestCaptureTx` and currency settlement
primitives. Failed writes return an error/no reward projection; the duplicated
legacy writer and separate service state-commit wrapper are removed. Runtime
captures stage copies of primary and registered-encounter state before merging,
so identically named variables do not overwrite each other's durable records.
State locks use sorted keys. Encounter source result sets are fully read/closed
before loading callback state, avoiding nested-query connection retention.

Real temporary-table tests inject failure, prove all rows roll back, retry
successfully, and verify separate primary counter1/encounter counter11. Logs:
`/var/tmp/idlequest-event-settlement-before.log`,
`/var/tmp/idlequest-event-settlement-after.log`,
`/var/tmp/idlequest-event-encounter-settlement.log`,
`/var/tmp/idlequest-event-settlement-integration.log`.
Full quest/world run still fails only at known Tundra Jack; world passes:
`/var/tmp/idlequest-event-settlement-final-go.log`.

This does NOT yet atomically include subsequent world effects or item delivery;
durable outbox/recovery remains open. Saved-state read/execute isolation against
simultaneous callbacks also needs separate validation. The SQL tests use
connection-local temporary tables, not production mutations or a migration.
Dev4954 was stopped after prior tests; fresh dev36362 runs this code, log
`/var/tmp/idlequest-transactional-quest-events-dev.log`. Serialized GPU dialogue,
healing and isolated Soulcase regression exec69503 is terminal0: seven tests
including RX9070XT preflight passed in1.0m; log
`/var/tmp/idlequest-event-settlement-browser.log`. Soulcase test seeds its entry
Heart but earns the container through dialogue and uses its actual Combine
button; this is a successful-path integration check, not another continuous
epic result. Server log still reports the explicitly unsupported NPC movement
at spawn21922, so do not claim all runtime events are error-free.

Historical state-serializer finding (fixed by the newer checkpoint above): a variable used only inside a nested helper
is not captured as a direct event-handler upvalue. The settlement test was
adjusted to directly captured handler counters to isolate transaction behavior;
it did not claim nested-helper state persistence. Dedicated closure regressions
and the restored helper-owned SQL counter now cover that case. No assertion about transactional rollback or state isolation was
relaxed for this fixture correction.

### Blade source trigger audit and nullable script correction

New `quest-sky-protector-trigger.spec.ts` tests the actual existing azarack
deaths -> Key Master signals -> Protector spawn -> real boss corpse boundary.
It does not require the rare Blade roll or claim acquisition without one.
Current imported Key_Master counts10 deaths; local DB has ten placements of
one identical azarack71031 (level53,maxdmg216,respawn14400s). Preserved P99
`npc-pages/protector-of-sky-a680b349bb.wiki` instead describes one stronger
trigger azarack. There is no distinguishing record in this local dataset.
The test explicitly labels the current ten-kill approximation; no content
change was made to invent a particular trigger placement.

First GPU run exec26806 is terminal1 after28.2s: actual azarack corpses2657,
2658,2659 were observed. Pulling2660 failed before combat: character alive at
2465/2465HP, target alive at12259HP and155.49 units away, combat list empty.
The fixture now starts `/nav target` BEFORE waiting for combat so it can
pursue roamers instead of relying on a sampled debug travel position. Typecheck
passes; rerun remains pending. Do not reset the four-hour respawns or repeatedly
reroll the encounter. Log `/var/tmp/idlequest-sky-protector-trigger-e2e.log`.
No Protector, boss corpse, Blade acquisition or full epic was proved by this run.

Server-log audit also exposed a regression from the new fail-closed script
loader: enabled neriakc/player row19735 has NULL Lua, which is legal in the
schema. Local DB has2749 such catalog rows. Its upstream player.pl only emits
a later-era LDoN invitation, not an in-scope quest to restore. Loading NULL into
a Go string caused a zone-entry error. The loader now uses sql.NullString,
treating a NULL source like an empty script while retaining genuine database,
scan and nonempty Lua failures. Real temporary-table regression fails before
and passes after, together with prerequisite and recovery tests:
`/var/tmp/idlequest-null-script-before.log`,
`/var/tmp/idlequest-null-script-after.log`. No imported rows were rewritten.
After the Sky test ended, dev43682 was stopped and dev4954 started to verify
this fix, not to reset/retry Sky. New server log:
`/var/tmp/idlequest-nullable-quest-source-dev.log`.
Fresh-server GPU Docker Neriak/healing regression exec12710 is terminal0:
two tests including RX9070XT preflight passed in12.4s. Log:
`/var/tmp/idlequest-nullable-source-browser.log`. The new server log confirms
Neriak zone entry and contains no QuestRuntime failure; the NULL-source error
from the preceding build is gone. Sky trigger verification remains pending.

### Timed quest globals now expire

`GlobalUpdate.Duration` was captured from Lua but discarded by both
`persistQuestCapture` and transactional `persistQuestCaptureTx`; each always
wrote NULL `expdate`. `getGlobals` also returned rows whose stored expiration
was already past. This made temporary progress/cooldown flags permanent.
Examples in the actual override corpus include FennKaedrick M30, Seta/Tomer
M30, Trantor H1, Marthor M5 and the airplane sirran M20 flag.

Shared `global_state.go` now supplies expiry to both writers using
EQEmu QGVarDuration's S/M/H/D/Y units (year31556926 seconds), and the reader
excludes expired rows. F/f is permanent; omitted duration remains permanent
for existing internal captures. Invalid explicit formats expire immediately,
as EQEmu does. Source inspected September6:
https://github.com/EQEmu/EQEmu/blob/master/zone/questmgr.cpp#L1791 .
Real temporary-table tests reproduced expired reads and NULL timed writes in
both paths before the fix and pass after it. Unit coverage includes units,
case, zero/negative durations, malformed input and permanent flags.
Logs: `/var/tmp/idlequest-global-expiration-before.log`,
`/var/tmp/idlequest-global-expiration-after.log`, and combined inventory/
prerequisite/dialogue regressions `/var/tmp/idlequest-global-inventory-integration.log`.

No existing rows are rewritten: legacy NULL rows lack the creation/expiration
information needed to reconstruct their intended deadlines. Any cleanup needs
a separate content-aware audit, not a guessed blanket expiration. No migration.
After connected Glohnor exec59532 completed, these fixes were loaded into the
fresh server and the existing dialogue/healing browser regressions passed
(details below). Expiration itself is proved by the direct SQL regressions,
not by those successful-dialogue browser cases.

### Runtime player inventory projection repaired

Related quest-global scope correction: both save paths formerly deleted only
by characterID/name. This erased same-named flags belonging to unrelated NPCs
or zones while missing shared charid0 flags altogether. Both now use one
`deleteQuestGlobalSQL` predicate in `global_state.go`, matching EQEmu's
local-or-zero scope on character, NPC and zone. Real temporary-table tests
reproduce the failure for ordinary and transactional persistence, then verify
visible local/shared flags disappear while another character, NPC, zone and
different name survive. Logs `/var/tmp/idlequest-global-delete-before.log`
and `/var/tmp/idlequest-global-delete-after.log`; expiration and prerequisite
regressions also pass. No migration or live-row cleanup; dev4954 has not been
rebuilt for this latest change. Slot-aware inventory implementation remains
deferred pending an explicit EQEmu-slot to IdleQuest bag/slot mapping.

Historical persistence caveat, now partly resolved by the newer settlement
checkpoint above: the old non-transactional writer ignored errors and performed
separate character writes. That writer is now removed. Item/world-effect
delivery after the database commit and concurrent callback isolation remain
open; scope/expiry or transaction tests alone do not prove those boundaries.

NPC and player runtime events read `PlayerInfo.Inventory` successfully but
discarded it when constructing `PlayerProxy`. Lua `HasItem` therefore returned
false for a carried prerequisite in those handlers, unlike dialogue/trade.
`context_reads.go` now owns the shared character-backed proxy construction,
used by hail, keyword, trade, NPC runtime and player runtime entry points.
Offered trade items remain excluded from the trade's inventory view; identity,
tasks, activities and stored factions are preserved. Bank-scope semantics are
unchanged. A follow-up regression exposed a related quantity bug: the database
reader counted occupied inventory rows, so a three-item stack appeared as one
and offering one hid the remaining two. It now sums `item_instances.quantity`.
Real temporary-table tests fail before the correction (expected3, actual1) and
pass afterward, including partial/full offer views and prerequisite failures:
`/var/tmp/idlequest-quest-stack-count-before.log` and
`/var/tmp/idlequest-quest-stack-count-after.log`.

Real temporary-table regression reproduced both failures before the fix
(`/var/tmp/idlequest-runtime-inventory-before.log`) and passes afterward along
with prerequisite/script failure tests
(`/var/tmp/idlequest-runtime-inventory-after.log`). The projection unit test
also proves offered-item subtraction does not mutate another event's view.
The wider runtime/dialogue/faction run still fails only the existing Tundra
Jack matrix case; 2,963 handlers were exercised
(`/var/tmp/idlequest-runtime-inventory-focused.log`). Do not claim a green
full suite. The inventory repair was kept out of the server during the running
connected camp, then loaded in dev43682 for the fresh-server regression below.

Inventory audit boundary: this fixes boolean `PlayerProxy.HasItem`, not every
inventory API. `lua_bridge.go` previously returned0 for `GetItemIDAt` and -1
for `GetInventory():HasItem`, regardless of ownership. The old iterator test
only checked an absent item. These methods now reject explicitly through the
shared deferred-capability registry in ordinary and strict execution, including
when Lua catches the error and attempts to award a reward afterward. The old
test is renamed to state its actual rejection contract; positive-ownership
regressions reproduce the false-success path before this fix and pass after it.
Evidence: `/var/tmp/idlequest-slot-api-before.log` and
`/var/tmp/idlequest-slot-api-after.log`. Full quest/world run still has only
the known Tundra Jack matrix failure, with world passing:
`/var/tmp/idlequest-slot-api-full-go.log`. This is fail-closed handling, NOT
slot-aware inventory implementation. The boundary is now loaded in dev43682;
its failure cases are proved by Go tests, not the browser regression below.
Inspected direct callers
include later-era Tipt/Txevu/Uqua scripts and the upstream `client_ext` module.
Before enabling any affected content, trace its effective module/handler path,
define actual slot/quantity/search-scope mapping using canonical inventory
constants, and test positive ownership as well as absence. Do not substitute a
made-up slot or call the boolean inventory repair slot-API parity. The static
coverage scanner now normalizes direct slot reads and inventory-object method
variables to these canonical registry keys. It is extracted into the cohesive
`scripts/quests/lua-runtime-api-scan.mjs` module, with three Node tests proving
deferred classification, boolean-ownership distinction and retained existing
entity/item-module scans. It remains conservative source scanning, not proof
of branch reachability; strict Lua execution is the authoritative reached-API
check. Tests: `/var/tmp/idlequest-lua-api-scan-tests.log`. Canonical generator
completed against the current local corpus into temporary outputs, selecting
the same19 cases and41/101 target APIs:
`/var/tmp/idlequest-slot-aware-coverage.log`. Existing fixtures were not
overwritten. The current
browser quest specs do not directly cover runtime inventory prerequisites;
the new temporary-database-to-Lua tests are the direct evidence for this fix.

Connected Glohnor extension **passed**: the Cell Key chain
continues with its earned Shroud through the actual mummy drops and Gerot/Marl
hand-ins, asserting all three ritual items survive together. The isolated and
connected tests share `testing/helpers/questGlohnor.ts`; only the isolated test
seeds a Shroud. Typecheck passed. Owned GPU Docker exec59532 is terminal0:
two tests including RX9070XT preflight passed in21.2m. Log:
`/var/tmp/idlequest-connected-glohnor-e2e.log`. Caradon appeared after one real
1200s placeholder cycle; Glohnor was already available. No intermediate item
grants, spawn resets, forced drops or fake deaths. All of14368/14369/14370
finished with count1 and14373/14377/14378/14379/14380/14381/17051 were consumed.
Actual adds were finished, including39145/21825 after the mummy encounter.
This supersedes separate seeded-Shroud evidence as chain continuity, not full
epic or full-strength encounter certification.

After the connected run completed, owned dev94380 was stopped cleanly and
dev43682 started with the inventory/slot-read/expiration fixes. Current log:
`/var/tmp/idlequest-quest-inventory-expiry-dev.log`. A serialized fresh-server
dialogue/healing GPU regression passed as exec78406 (terminal0), six tests in
53.2s with RX9070XT; log
`/var/tmp/idlequest-inventory-expiry-browser-regression.log`. It checks existing
successful behavior, not injected expiry or slot-lookup failures.

Cell Key acquisition is now part of quest-caradon-chain.spec.ts rather than a
starting item grant. Cached P99 SK page identifies the Hole bank mimics; actual
local types39056/39057/39058 are named a_chest, placements15882/15883/15884,
640s respawn, ordinary key14373 drop25%. The first GPU run killed15882 (empty)
and15884 (key), then looted the actual key. It subsequently failed: the shared
acquisition helper traveled away from surviving chest adds, and the character
died during the Caradon placeholder fight. Evidence:
`/var/tmp/idlequest-earned-key-caradon-e2e.log`, terminal failure after5.3m.
Do not count the run as a successful connected chain or a natural Caradon wait.

Shared fixture correction: questCombatCleanup.ts now finishes real assisting
NPCs before travel/pause, used by both drop acquisition and placeholder camps.
It uses actual navigation/melee, 10HP opponents, fresh corpse receipts, and
disclosed player-health restoration between add fights. Camps also navigate
after reducing a primary to10HP so manual melee follows fleeing targets.
Drop acquisition can loot the correct item's corpse when an assisting NPC
dropped it, not just the initial target; it reselects and travels to that actual
corpse after cleanup. No raid setup, fake deaths, spawn resets or reward grants.
Typecheck passes (`/var/tmp/idlequest-quest-add-cleanup-typecheck.log`).

Rerun completed successfully: owned exec98229 is terminal0, two tests including
hardware preflight passed in25.1m. Evidence
`/var/tmp/idlequest-earned-key-caradon-add-cleanup-e2e.log`; RX9070XT, one worker.
Chests15883 and15882 had no key; naturally respawned chest39057/15884 dropped
14373, which this same character looted after finishing real adds. Caradon's
placeholder39000/15892 and adds39037/15836,39144/21760 died normally, followed
by the natural1200s respawn wait. Caradon appeared; his earned-key hand-in
released both attackers, actual Kyrenna death supplied Heart14380/Blood14381,
Caradon was also killed, Marl consumed the earned Blood for Shroud14377, and
Knarthenne's dialogue-earned Soulcase consumed the Heart to produce14368.
No initial or intermediate item grants. Player level/skills, travel, 10HP enemy
adjustment and between-add healing are disclosed setup. All killings/corpses/
loot and quest/container transactions are real. This connects the formerly
separate Soulcase and Kyrenna segments, not Glohnor or the full weapon branch.

Future-run wait guards now distinguish death, camp, zone/instance/character
changes and loading from an ordinary empty spawn. Both acquisition and
placeholder waits use the shared guard; eight focused tests and typecheck pass
(`/var/tmp/idlequest-quest-camp-guard-unit.log`,
`/var/tmp/idlequest-quest-camp-guard-typecheck.log`). They were added after the
running browser loaded its helpers, so do not claim this run exercised them.
The actual add cleanup and fleeing-target navigation were loaded and exercised.

After that run completed, stopped only owned dev session13135 (terminal130)
and rebuilt through npm run dev:test. Current dev session94380, log
`/var/tmp/idlequest-quest-read-boundaries-dev.log`, Vite5173/HTTP8080/WT4433.
Then ran quest-dialogue-discovery.spec.ts and quest-npc-healing.spec.ts serially
through hardware GPU Docker: six tests including preflight passed in51.1s,
exec56873 terminal0, `/var/tmp/idlequest-quest-read-boundaries-e2e.log`.
This freshly verifies Teydar SK/non-SK greeting and ingredient responses,
Lhranc options, actual Serena response clicks, unsupported cure donation
refunds and paid NPC-attributed healing on the newer server. No raid work,
production changes, commit, push or deployment. The earlier no-restart notes
below describe their original checkpoints, not the current binary.

Script-loading/execution failure boundary corrected while the camp runs.
Service.loadScriptFromDBCandidates now treats only sql.ErrNoRows as an absent
candidate; storage/scan failures stop lookup. executeEvent propagates both load
and Lua failures, and failed captures cannot escape as rewards. Hail and keyword
paths reuse one source loaded before effects, instead of rereading it for
discovery after persistence. Module-store failures no longer fall back merely
because their text mentions quest_lua_modules. Encounter-discovery failures are
not cached as an absent handler, so a subsequent successful request can recover.

Real connection-local temporary-table tests reproduced swallowed syntax, Lua
execution, unresolved-actor and closed-database errors before the fix. They now
pass, alongside valid/missing-content behavior, unavailable module store and
encounter failure/retry tests. Logs `/var/tmp/idlequest-script-failure-before.log`
and `/var/tmp/idlequest-script-failure-after.log`. Full quest/world Go run still
has only the known Tundra Jack no-resolver matrix failure; world passes
(`/var/tmp/idlequest-script-failure-full-go.log`). Server restart was deferred
until the Caradon run finished; the later fresh-server six-test GPU regression
above now covers the successful dialogue/healing paths on this implementation.

Prerequisite read boundary corrected next: context_reads.go is shared by hail,
keyword, trade and NPC/player runtime events. Player identity, zone, globals
and actor-state failures now abort before script execution; task/activity/
inventory/faction query, scan and row-stream errors no longer produce partial
PlayerInfo. Actual empty collections and genuinely new actor state remain valid.
Real temporary-schema tests exercise eight failed stores plus actor identity
mismatch through all five entry points, proving execution is not reached.

Those tests also exposed an actual successful-read mapping bug: getZoneID
returned0 instead of123 because its anonymous result struct did not match Jet's
qualified column mapping. It now uses model.Zone; tasks use model.CharacterTasks
instead of the same anonymous-row pattern. Positive SQL assertions verify the
real zoneID, nonzero task42, activity42/3, inventory14372, stored faction=-100,
zone123 and zone0 globals while excluding zone999, and persisted actor stage2.
The deliberate Lua Ally policy remains separate from stored standings.

Focused SQL/script/Teydar tests pass:
`/var/tmp/idlequest-context-and-script-boundaries-final.log`.
Full quest/world Go run retains only the known Tundra Jack matrix failure;
world passes (`/var/tmp/idlequest-context-reads-full-go.log`). The later rebuilt
server passes the six-test dialogue/healing GPU regression above. Failure
injection remains SQL-tested rather than browser-injected. No migration or
rewrite of historical zone0 globals was
performed. Existing global-scope rows remain readable; historical intent cannot
be reconstructed merely from zone0. No cross-query isolation/atomicity claim.

Teydar's corrected greeting is now applied to the local runtime database and
verified through the real quest UI (September 6). The old DB script reproduced
the missing Shadow Knight greeting in GPU Docker; after the targeted canonical
import, both Shadow Knight and Enchanter cases pass. Only the Shadow Knight
receives the class-gated hail greeting; both receive the three sheath ingredient
directions despite stored faction404=-2000. Lhranc and Serena dialogue regressions
also pass: five tests including RX9070XT hardware preflight, serialized. Logs:
`/var/tmp/idlequest-teydar-dialogue-before-e2e.log` (expected failure),
`/var/tmp/idlequest-teydar-dialogue-after-e2e.log` (pass). This is UI/network
dialogue verification, not rendered NPC navigation or ingredient acquisition;
the shared setup pauses 3D rendering after zone readiness.

`import-quests --override zone/name` now dry-runs a single bundled override;
`--apply` updates an exact existing enabled row without modules/global fixups
or re-enabling content. Real temporary-schema SQL tests cover dry-run, successful
update, unrelated preservation, disabled/missing/case-mismatched rejection;
source selection rejects unknown/ambiguous keys. Teydar before SHA256:
7619711e95e1734ff8a40525a716fa05ae6f653d760857568f4cfc322957e4dc;
after: 2d64dc6670152876b334f37643264c3cd5a63698f11f0f927ffd3acb0a5de1c0.
Typecheck passes. No server restart, spawn reset, production change, commit or
push. The movement investigation identified a required scoped command/lifetime
boundary: spawn broadcasts reset actors and combat movement has different
ownership, so neither is a valid shortcut for escorts. Keep that work explicit;
prioritize the unfinished SK acquisition/hand-in connections before expanding
into a new movement protocol. No full-epic claim.

Movement/payment boundary corrected September 6. The parked raid TODO above
remains unchanged. MoveTo, GMMove, SetRunning, RandomRoam and eq.random_roam
now declare their unimplemented delivery through the shared capability registry.
MoveTo/GMMove no longer change the Lua proxy's observed coordinates as though
the unexecuted request had completed. Both hand-in preflight and runtime
execution reject unsupported captures before settlement or world mutations;
the executor also rejects directly constructed NPCMoves without diagnostics.
Compatibility capture remains available for auditing, not evidence of delivery.

Focused bridge/world tests pass, including real Lua capture, all five entry
points, follow/stop-follow, unchanged position reads, strict pcall rejection,
and rejection before timers can be scheduled. Full quest/world Go execution
still fails only the existing Tundra Jack no-resolver matrix case; the world
package passes. Evidence: `/var/tmp/idlequest-quest-movement-boundaries-go.log`.
Regenerated coverage through `npm run quests:build-lua-runtime-e2e-coverage`:
19 selected cases cover 41/101 target APIs; movement is explicitly deferred,
not counted as implemented. No browser test, server restart, database migration,
commit, push or deployment for this checkpoint. This prevents silent acceptance
of unsupported quest effects; it does not implement escorts or NPC movement.
Next: connect concrete actor movement to shared navigation with scoped ownership
and lifecycle handling, then prove an actual escort rather than captured calls.

Fresh-server rendered regression passes after scoped lookup and cross-NPC
inventory changes. Stopped only the owned dev session34456, then rebuilt with
`npm run dev:test`; current dev session13135, log
`/var/tmp/idlequest-scoped-quest-runtime-dev.log`. GPU Docker ran
quest-dialogue-discovery.spec.ts and quest-npc-healing.spec.ts serially:
four tests including hardware preflight passed in35.3seconds, RX9070XT.
Evidence `/var/tmp/idlequest-scoped-quest-regression-e2e.log`. Covers Lhranc's
reachable dialogue, actual Serena response clicks, unsupported cure donations
returning all money and actual NPC-attributed healing after a paid donation.
These are regression interactions, not a rendered cross-NPC AddItem test.

Source selection check found the converted Classic/Velious AddItem uses in
Kurron_Ni and lakeofillomen/#_ address self or a pending spawn, not an arbitrary
looked-up NPC. Do not modify P99 quest content simply to exercise the new path.
Cross-NPC delivery remains proven by actual Lua/population/SQL/corpse-builder
tests, with rendered integration still outstanding if a relevant source or an
explicitly isolated mechanics fixture is selected.

Movement investigation: the issue is broader than eq.follow. NPCProxy.MoveTo,
SetRunning, RandomRoam and eq.RandomRoam capture NPCMoves, but the world runtime
has no NPCMoves consumer. Several converted Overthere scripts use this path.
Do not claim captured moves are navigation. Follow implementation must share
an actual movement executor and preserve concrete actor identity, cancellation,
owner/instance scope and reconnect/lifetime behavior; do not implement it as
a one-off teleport or a second unrelated actor-navigation system.

Cross-NPC AddItem delivery is now implemented for resolved live actors.
The proxy captures ExternalNPCAddedLoot separately from the event actor's
NPCAddedLoot/ScriptState. The existing runtime executor delivers it before
signals/depops, and hand-in preflight checks item templates, actor visibility,
and stored inventory identity/corruption before accepting payment. All target
inventory writes share one SQL transaction with stable row ordering while the
existing population mutex prevents concurrent death/depop. Exact owner, zone,
instance, spawn and NPC type are revalidated; personal suppression is honored.
No type-wide fallback and no new table/protocol. Self and pending-spawn item
paths remain separate and unchanged. Null actor AddItem has no effects.

Real connection-local temporary-table tests pass:
`/var/tmp/idlequest-cross-npc-inventory-final.log`. They execute Lua through
the real scoped resolver, add items to two existing actors, prove preflight
does not write, reject missing templates, reload exact items/charges through
the normal death-inventory reader and corpse-loot builder, leave the quest
giver empty, and roll back the first target's addition when the second target
has a mismatched persisted NPC identity. Unit checks cover other owners,
instances, dead/replaced/suppressed actors and capture merging/clearing.
The SQL fixture supplies templates from its temporary items table; production
uses the canonical item-template file. This is not a rendered death/loot run.

Important remaining limit: the target-inventory batch is atomic internally,
but is not one transaction with the already-settled hand-in or all other world
effects. A post-preflight death/failure still needs durable effect/outbox work.
The full Go suite remains red only at the documented no-resolver Tundra Jack
matrix case; world package passes (`/var/tmp/idlequest-cross-npc-inventory-full-go.log`).
Movement/follow, removal and other guarded cross-NPC methods remain unfinished.
No local server restart, production change, commit or deployment in this batch.

Missing-actor lookup contract corrected against EQEmu Lua bindings, September6:
Lua_EntityList wraps missing pointers in Lua_NPC/Lua_Mob, and Lua_Entity
publishes valid/null properties. The previous checkpoint's plain Lua nil was
not sufficient for real `target.valid` guards. Scoped absence now returns a
null NPC wrapper: valid=false, null=true, GetID/GetNPCTypeID=0, IsNPC/IsMob=false.
Null Signal/Depop do not capture effects. Resolved actors expose valid=true
and null=false. Unsupported cross-NPC inventory remains rejected, including
after pcall. Tests use the actual bridge in both missing/resolved cases;
focused quest/world suite passes in `/var/tmp/idlequest-npc-null-lookup.log`.
Sources: https://github.com/EQEmu/Server/blob/master/zone/lua_entity_list.cpp#L79
and https://github.com/EQEmu/Server/blob/master/zone/lua_entity.cpp#L157
and https://github.com/EQEmu/Server/blob/master/zone/lua_ptr.h#L58 .
This supersedes the earlier nil-return statement, not the documented remaining
cross-NPC mutation and follow limitations. No server restart or rendered check.

Scoped lookup implementation checkpoint: dialogue/hand-in contexts and NPC,
player and registered runtime events now carry a server-owned QuestNPCResolver.
It resolves from the existing owner/zone/instance-filtered live population,
returns nil for genuine absence, uses stable concrete identity among duplicate
types, and copies actor metadata before exposing a Lua proxy. Read methods,
Signal and Depop now work on that resolved actor. Unsupported cross-NPC
methods reject the whole capture, including caught Lua pcall, rather than
writing into the event NPC's inventory or issuing type-wide movement.
Health/faction reads are not enabled for external proxies because current
projection fields are not sufficient proof of live combat health or primary
faction identity. These are explicit remaining capabilities, not completed
lookup parity. Registry entries remain deferred for contexts without a resolver.

Authoritative source check corrected the misleading GetNPCBySpawnID name:
EQEmu `zone/entity.cpp` GetNPCBySpawnID compares GetSpawnGroupId, not a spawn2
placement or entity ID; `zone/npc.h` exposes those as distinct fields.
Sources verified September6:
https://github.com/EQEmu/Server/blob/master/zone/entity.cpp#L1077 and
https://github.com/EQEmu/Server/blob/master/zone/npc.h#L219 .
The new internal QuestSpawnGroupID carries the real Spawn2.SpawngroupID;
QuestClass uses the already-loaded NPC metadata. Both are json-excluded and
require no client protocol change. No database query is added per lookup.

Focused Go evidence `/var/tmp/idlequest-npc-lookup-focused.log` passes:
exact type/group distinction, duplicate actors, missing actor, invalid returned
identity, resolution failure, exact Signal/Depop, owner/instance/dead actor
exclusion, cross-NPC mutation rejection and non-mutating dialogue clone with
the non-serializable resolver preserved. Not a rendered or deployed result.
The standalone database matrix still lacks live resolver context; do not
silently supply a fake actor just to turn its Tundra Jack case green. Actual
follow and cross-NPC inventory delivery remain the next implementation work.

Actor-state identity prerequisite repaired before enabling cross-NPC lookup:
the shared SQL writer previously validated identity only through inventory
entries. An empty-inventory state row could therefore be relabeled from NPC9001
to NPC9002 at the same owner/zone/instance/spawn key. A real temporary-table
regression reproduced the acceptance (`/var/tmp/idlequest-actor-state-identity-before.log`).
`PersistRuntimeScriptStateTx` now reads npc_type_id under the same row lock,
rejects mismatches and never rewrites the identity column. Both Lua-state and
death-inventory readers validate the stored NPC ID too, including empty rows.
Regression proves correct reads, wrong-actor reads/writes rejected, rollback
leaves stage/inventory/identity unchanged, and existing interleaved inventory
updates still work. SQL tests pass in
`/var/tmp/idlequest-actor-state-identity-final.log` using only connection-local
temporary tables. No migration, live data repair, restart or deployment.
This secures an existing persistence primitive; cross-NPC capture routing and
actual lookup are still incomplete. The full Go run remains red only at the
previously exposed Tundra Jack unsupported lookup; world package passes
(`/var/tmp/idlequest-actor-state-full-go.log`).

NPC lookup safety checkpoint: `GetMobByNpcTypeID`, `GetNPCByNPCTypeID` and
`GetNPCBySpawnID` previously ignored their argument and returned the event NPC.
That could misdirect AddItem/Signal/Depop and certify a reward after acting on
the wrong actor. The bridge no longer returns that proxy. These three still-
deferred capabilities now reject ordinary execution as well as strict audits;
`checkedResult` also rejects if Lua pcall catches the error. This is removal of
an unsafe stand-in, NOT completed NPC lookup support. Regression covers all
three APIs, both execution modes and reward/actor-effect suppression after
pcall. Focused checks: `/var/tmp/idlequest-unsafe-lookup-focused.log`.

Full quest Go package currently FAILS: the database runtime matrix exposes
`everfrost/Tundra_Jack event_signal` calling the unresolved lookup for Iceberg
NPC30062 before `eq.follow`. Previous compatibility output falsely treated
that branch as executable (follow is itself still deferred). Do not skip or
weaken that assertion. Evidence `/var/tmp/idlequest-unsafe-lookup-go.log`.
Next implementation boundary: obtain actual owner/zone/instance-visible actors
from the existing population; preserve concrete spawn identity and distinguish
spawn2 placement IDs from NPC type IDs; hydrate required NPC metadata; route
cross-actor loot/state writes to that actor rather than the event's ScriptState.
Existing `NPCProxy.AddItem` writes directly into capture.ScriptState, so merely
populating a lookup table would corrupt cross-NPC persistence. Signal/Depop
already retain concrete IDs and revalidate through resolveQuestActorTargets.
Keep the registry deferred until lookup plus its reachable effects really work.
No server restart, import or deployment performed for this checkpoint.

Remaining SK sword acquisition audits now have a serialized, opt-in GPU command:
`npm run test:e2e:quest-sk-swords -- --reporter=line`. Sources are exact NPC IDs
verified in the preserved P99 Dread/Fright/Terror and Gorgalosk/Protector of
Sky/Keeper of Souls pages and current loot records. The shared acquisition
helper supports multiple explicitly verified source types without substituting
arbitrary NPCs or changing loot. Typecheck passes.

First run is terminal: GPU preflight passes, both acquisition cases fail in
36.7 seconds because the ordinary drops did not occur. Actual 10-HP kills and
corpse receipts: Fright72004/13817, Terror72002/72020, Dread72000/250059 and
Gorgalosk71021/2641. All four produced ordinary corpse loot; neither11609 nor
5430 was awarded. Log `/var/tmp/idlequest-sk-swords-e2e.log`, typecheck
`/var/tmp/idlequest-sk-swords-typecheck.log`. This proves those death/loot
boundaries execute, not successful sword acquisition or a continuous epic.
Do not rerun repeatedly or reset long respawns to manufacture a green result.
Protector71059 and Keeper71075 have no static placements: their existing
`airplane/Key_Master.lua` signal/timer path spawns them. The audit uses them
only if genuinely present; it does not inject them. Resume shared runtime work
while rare acquisitions remain explicitly unverified.

The Teydar ranged camp is now terminal, not running: hardware GPU preflight
passed, but the connected case failed after 12.1 minutes, 14 actual placeholder
kills across seven placements and natural respawns. Rharzar did not appear and
no Drake Spine was granted. Log:
`/var/tmp/idlequest-teydar-ranged-camp-e2e.log`. This is a bounded acquisition
failure, not a passing Teydar chain or evidence of broken hand-in logic. Do not
restart the server or change spawn/drop probabilities to make it pass. The
shared helper now reports both actual kill count and distinct placement count,
plus NPC type per receipt, so a repeat kill is not confused with a new placement.

Next acquisition case uses Joren Nobleheart for Ghoulbane: preserved P99
`npc-pages/joren-nobleheart-7603489955.wiki` lists the drop, and the local DB
has NPC62000 -> item5403 with loot chance100/probability100. The new optional
`testing/e2e/quest-ghoulbane.spec.ts` uses the existing real corpse acquisition
helper, initial Enchanter setup, a landed real nuke and actual-NPC 10 HP. No
forced spawn or reward injection. Hardware GPU test passes in 14.8 seconds:
actual NPC62000, spawn8794 produced corpse items5403/9307 and Ghoulbane5403
was looted into carried inventory. Evidence:
`/var/tmp/idlequest-ghoulbane-acquisition-e2e.log`; typecheck also passes in
`/var/tmp/idlequest-ghoulbane-typecheck.log`. Reusable command:
`npm run test:e2e:quest-ghoulbane -- --reporter=line`.
This proves isolated real Ghoulbane acquisition, not the subsequent Duriek
hand-in or the continuous epic. The next unverified weapon acquisitions are
Soul Leech and Blade of Abrogation; preserve their natural loot probabilities.

Teydar's Shadow Knight hail was genuinely broken in the converted source.
The runtime already rewrites direct legacy string `Class()`/`Race()` equality
checks to name readers, so the 13 matching converted files are not all broken.
Teydar additionally used Perl spelling `Shadowknight` versus the hydrated
canonical `Shadow Knight`. The new actual-source regression failed with no
greeting before the fix (`/var/tmp/idlequest-teydar-class-before.log`). His
converted override now checks numeric `GetClass()==5`; upstream Perl remains
untouched. Tests prove Shadow Knight hail works, Enchanter hail stays silent,
and both can still ask for ingredient directions with stored faction-2000.
Full quest Go package passes (`/var/tmp/idlequest-teydar-class-after.log`).
This source edit has not been reimported into the running local database during
the active camp, and is not a live/deployed fix yet. The connected Enchanter
fixture uses the already-working explicit ingredient keyword, not this greeting.

Historical setup of the Teydar natural-camp extension (terminal result above): it restricts
placeholder kills to the seven verified current Rharzar spawn-group placements
58193/58197/58198/58226/58227/58228/58229, uses their actual600second respawn
time, and caps the run at14kills/30minutes. Dead/corpse actors and previously
killed placements before their cooldown are excluded. Each kill still requires
an actual server corpse message; no spawn reset or drop injection is used.

Two setup failures were corrected: memorizing leaves the character sitting,
so the helper now explicitly stands; roaming placeholders can leave manual
melee range before encounter initialization, so the caster uses its real nuke
as the opener and reduces HP after the real encounter starts. Neither changes
production combat policy. Current run log:
`/var/tmp/idlequest-teydar-ranged-camp-e2e.log`, exec session10432, hardwareGPU.
It has killed58193/58197/58198/58226/58227/58229 and entered a bounded650second
natural respawn wait. Check that exact process/log for completion; do not
restart it merely because no new output appears during camping. Typecheck
passes (`/var/tmp/idlequest-teydar-ranged-typecheck.log`).

Connected Teydar acquisition test authored, **not passing yet**:
`quest-teydar-chain.spec.ts` / `npm run test:e2e:quest-teydar` retains one
Enchanter through Rathe/Hate/Commonlands/Qeynos Aqueducts, checks all three earned
ingredients and requires their consumption plus Decrepit Sheath14366. The
standalone drop and platinum tests now call the same extracted
`questSkSheath.ts` helpers; no duplicate acquisition rules were added.

First connected GPU run earned a real spine from Rharzar58228, then the naked
Enchanter died in Hate before a corpse was delivered
(`/var/tmp/idlequest-teydar-chain-e2e.log`). The connected caster fixture now
prepares actual Enchanter nuke296 (Chaotic Feedback,2s,16mana) and restores test
HP between fights; the targets still have10HP and all damage/death/loot is real.
This fixture change is not yet verified through the whole chain: the next run
found no live Rharzar and explicitly failed without granting14372
(`/var/tmp/idlequest-teydar-caster-e2e.log`). No server/spawn reset or loot
alteration was used. Next extend bounded natural placeholder camping or wait for
an actual respawn before claiming continuity. Typecheck evidence:
`/var/tmp/idlequest-teydar-caster-typecheck.log`.

SK Drake Spine acquisition passes GPU Docker in14.3s: naturally present Rharzar
50324 at placement58226 was reduced to10HP, killed through normal combat, and
his actual corpse contained8330and14372; the spine reached carried inventory.
Evidence: `/var/tmp/idlequest-drake-spine-e2e.log`. This is not a forced spawn,
respawn reset or guaranteed test loot. Cached P99 Rharzar page supports the
guaranteed spine drop once he is present. Rare-spawn waiting is not proven.

The hide test was moved into shared data-driven
`quest-sk-drake-drops.spec.ts`; its two cases use the same kill/loot assertions
with different NPC/item IDs and bounded attempt counts. Existing
`test:e2e:quest-decrepit-hide` still targets the hide case; new
`test:e2e:quest-drake-spine` targets the spine. Both retain mandatory GPU
preflight and content-audit opt-in. The earlier hide pass predates this mechanical
parameterization; the spine pass exercises the shared implementation. All three
Teydar ingredient sources now have separate acquisition evidence, but a single
character earning all three and completing Teydar still needs a connected test.

SK enchanted-platinum procurement now verified in
`quest-enchanted-platinum.spec.ts`: initial Enchanter/spellbook/skills/money and
player travel are setup, but neither bar is seeded. Actual Noresa Sparkle21069
merchant entry in East Commonlands opens via the real Path To sidebar; real
purchase grants Platinum Bar16503. Actual memorized Enchant Platinum670 consumes
that bar and grants16507, with both inventory counts asserted. Spell data is
level32Enchanter,225mana,6second cast,1×16503 reagent and SPA32output16507.
P99 preserved epic instructions explicitly say to buy platinum and have it
enchanted. GPU Docker passes both tests in18.6s
(`/var/tmp/idlequest-enchanted-platinum-cast-e2e.log`); typecheck passes
(`/var/tmp/idlequest-enchanted-platinum-typecheck.log`). Earlier failures were
fixture navigation/ambiguous UI locators, not failed spell conversion. This is
ingredient procurement, not a completed Teydar/epic chain.

- [ ] Repair stale debug `nav merchant` lookup: it reads
  `MerchantStore.merchants`, which has no current producer; the real sidebar
  instead derives merchants from current zone NPCs and live placements. Reuse
  that authoritative query rather than reinstating a parallel stale list. The
  procurement test uses the real UI and does not depend on this command.

SK Decrepit Hide acquisition now verified against a naturally spawned
ashenbone drake76002 in Hate. The hide case (now in `quest-sk-drake-drops.spec.ts`) starts with no hide,
uses normal damage/death/corpse loot after reducing the exact NPC to10HP, and
asserts item14371 reaches carried inventory. GPU Docker passes both tests in
14.0s: actual placement1844 dropped14371 on the first kill
(`/var/tmp/idlequest-hide-acquisition-e2e.log`). Initial level/skills and player
travel are debug setup; no NPC, death, loot or intermediate item is fabricated.

The optional `npm run test:e2e:quest-decrepit-hide` checks at most three existing
drakes. It can honestly fail when the natural25percent hide drop is absent;
do not reset spawns or increase drop rates to green the audit. Local source
read verified three placements1844/1845/1846 and item14371 loot association;
P99 source is preserved `shadow-knight-epic-quest-ee3595791b.wiki`, lines219–223.
This proves hide procurement only, not Teydar's complete three-item acquisition
or a continuous full epic. Next extend through Rharzar's spine and the enchanted
platinum bar before the actual Teydar hand-in. Cure delivery remains recorded
below as unfinished broader effect work, not a prerequisite for this SK branch.

Real casting/buff-update boundary now covered by GPU Docker
`debug-real-buff-effect-isolation.spec.ts`. A test-mode Druid in Surefall Glade
receives an explicitly seeded canonical poison record with2remaining counters,
then casts actual memorized Skin Like Wood on self. The test requires the buff
to be absent initially and present after completion, while the exact poison
record survives. Finally removes only its seeded effect and camps. This is not
natural poison acquisition, ticking combat, quest cure delivery or reconnect
proof. Rendering remains enabled; hardware preflight confirms RX9070XT.
Both tests pass (`/var/tmp/idlequest-buff-isolation-final-e2e.log`); typecheck
passes (`/var/tmp/idlequest-buff-isolation-typecheck.log`).

Client buff-writer isolation fixed after a failing regression. Ordinary
`commitLocalCharacterBuffs` previously replaced the entire shared effect
component with player-buff records, erasing runtime DoTs/debuffs and partial cure
counters whenever the buff list changed. Runtime and companion writers already
preserve other owners' effect kinds. The player writer now likewise replaces
only `player-buff` records. Initial character hydration remains an explicit
whole-component reset; this change does not invent reconnect persistence.

Failure before fix: `/var/tmp/idlequest-quest-buff-overwrite-before.log`.
Regression covers adding/replacing/removing buffs while retaining the exact
poison effect, remaining ticks, next tick deadline and2remaining counters, then
checks initial-load reset still clears it. Focused registry/external-cure tests
pass (`/var/tmp/idlequest-quest-buff-overwrite-after.log`); typecheck passes
(`/var/tmp/idlequest-quest-buff-overwrite-typecheck.log`). This is a canonical
state test, not a rendered cure/reconnect claim. Cure network delivery and
durable per-kind detrimental-effect synchronization remain unfinished.
Expanded verification including all488combat-runtime mutation tests passes:
526tests total (`/var/tmp/idlequest-quest-buff-overwrite-final.log`).

Server buff counter preservation repaired: `entity.Buff` now retains the
existing scalar DB counter internally. Shared `BuffFromRecord` /
`PersistenceRecord` conversions replace the duplicated client load/save and
transactional spell-settlement mappings, so neither silently zeroes a saved
partial cure. Counter values are not re-derived from spell templates. The field
is explicitly excluded from JSON until the client per-kind synchronization
contract is implemented; no wire format or migration change is claimed.

Entity round-trip tests cover zero/partial/full counters with both rune kinds.
Quest/world/client/entity Go packages pass
(`/var/tmp/idlequest-buff-counter-persistence-go.log`). Guarded temporary-table
SQL coverage verifies an existing2-counter row survives load and transactional
spell buff persistence, alongside the NPC heal/pending-caster regression
(`/var/tmp/idlequest-buff-counter-persistence-sql.log`). This does not yet fix
controlled-character snapshot replacement, deliver cures, or demonstrate a
browser reconnect restoring client detrimental effects. Those remain next.

Pending-caster preflight regression now covers real Lua `eq.spawn2` returning
a proxy and calling `CastSpell` on it. Guarded SQL test proves validation does
not create an NPC or change persisted HP, rejects negative/out-of-bounds spawn
references, then actual world capture execution creates exactly one NPC and
persists its heal. Pass: `/var/tmp/idlequest-pending-spell-preflight-sql.log`.
This uses the existing in-memory test population plus connection-local temporary
character tables; it is not a rendered spawn/cast check or payment atomicity test.

Reconnect investigation: the existing generated `CharacterBuffs` DB model has
a scalar `Counters` field, and `SaveCharacterBuffsTx` already writes it. However,
`entity.Buff`, `Client.LoadBuffs`, `Client.SaveBuffs`, `persistPlayerBuffs` and
`BuffRecord` do not carry it. Merely adding a client cure packet would therefore
not establish durable counter state. Do not invent a new counter table before
evaluating this existing column, its single-value versus canonical per-kind
semantics, and which detrimental effects currently enter the saved buff path.
No cure packet or persistence-format change has been enabled by this test work.

Quest hand-in effect preflight now runs before inventory/currency settlement.
Reached deferred effects and uncorrelated legacy self-casts are rejected;
typed NPC casts are planned against the actual owner, zone/instance, exact
caster (or validated pending spawn), target and supported spell effects without
applying them. Execution revalidates afterward. Soulbinder compatibility keeps
its real typed Bind action and no longer records an additional unexecuted spell.
This is protection against known unavailable effects, **not atomic payment and
effect delivery**: failures after preflight still require durable settlement work.

GPU Docker Ulazia regression passes both tests in13.2s on the RX9070XT
(`/var/tmp/idlequest-quest-preflight-e2e.log`). Real Give-window8gold and6gold
cure donations fail and return all money;10gold healing succeeds, consumes the
payment and delivers an NPC-attributed heal. Initial travel, level, health and
money are debug setup; the NPC, dialogue, hand-ins and heal are real. Cures are
still unsupported, not silently declared repaired. Guarded temporary-table SQL
test passes (`/var/tmp/idlequest-quest-preflight-sql.log`), proving preflight
does not change saved HP and execution persists the heal; invalid targets fail.
Typecheck passes (`/var/tmp/idlequest-quest-preflight-typecheck.log`).
Full quest/world Go packages pass, including unsupported-effect preflight checks
(`/var/tmp/idlequest-quest-preflight-final-go.log`). Next: finish actual cure
delivery and payment/effect failure recovery; raid work remains parked above.

External cure adapter now reaches canonical player effects without an NPC
combat session. `runtimeExternalCounterCureSystem.ts` adapts canonical effect
reads/writes/removal to the same `cureTrackedTargetCounters` used by combat
spells. It preserves non-tick effects when updating tick lists and refreshes
any existing encounter effect-ID caches, but never creates a fake encounter.
It returns unavailable (player actor not loaded), unchanged (no applicable
counters), or applied. A new canonical-runtime test starts with no NPC/session,
checks unavailable before actor loading, partial/full poison and disease cures,
retained unrelated buff, unchanged redundant cure and no new NPC/session.

Both external/target-boundary tests pass
(`/var/tmp/idlequest-external-cure-adapter.log`); typecheck passes
(`/var/tmp/idlequest-external-cure-typecheck.log`). No network caller has been
enabled yet. Do not conflate this adapter with server authorization or delivery
proof. Next integrate correlated character-scoped delivery/receipts and replay
rules with real session lifecycle; an unavailable actor must not acknowledge
application, and replay after a player-effects reset must not cure a newly
acquired poison accidentally. Client/server durable counter state and atomic
payment/effect delivery remain unresolved. No new protocol, browser run,
migration, commit or deployment in this checkpoint.

Partial-cure root cause repaired before quest delivery is enabled. Runtime
effect-list readers return projected copies. Counter curing previously mutated
a copied debuff's counterRemaining and returned success without committing the
reduction to canonical actor state. A new real-runtime regression failed with
2poison counters remaining after a1-counter cure (expected1):
`/var/tmp/idlequest-partial-cure-before.log`. Complete removals were already
explicit writes, which explains why the previous full-cure test passed.

The shared cure host now requires `commitCounterRemaining`; partial reductions
update matching spell effects through the canonical actor-effect setter, keeping
tick/debuff representations consistent and publishing state changes. New checks
verify both player debuff and companion DoT partial counters via canonical state
and freshly read host projections, then verify normal complete removal. The
old runtime.playerDebuffs backing array is not the canonical reader and was
not used to certify the fix. No alternate quest-specific cure math was added.

Focused counter/cure/dispel tests22pass467unselected
(`/var/tmp/idlequest-partial-cure-final-tests.log`). Typecheck passes
(`/var/tmp/idlequest-partial-cure-final-typecheck.log`). This fixes in-memory
canonical runtime state, not server persistence/reconnect or donation delivery;
those remain next. No browser test, migration or deployment in this checkpoint.
The full combat-runtime mutation suite also passes all488tests
(`/var/tmp/idlequest-partial-cure-full-mutation.log`).

Cure ownership audit and reusable target boundary: poison/disease/curse counters
are tracked in client `counterRemaining` state on tick effects/debuffs. The
server `entity.Buff` representation has no counterRemaining field, and current
NPC quest spell execution cannot cure that client state by editing saved buffs.
The existing SpellCommand entry point also requires an NPC combat session;
using it unchanged for a healer donation after combat would silently do nothing.

Extracted the existing counter-cure operation behind
`RuntimeCounterCureTargetHost` / `cureTrackedTargetCounters`. Ordinary combat
cures adapt to this same implementation; target-specific debuff selection and
refresh replace three repeated actor-kind loops. The core needs only the
target's effects and callbacks, not an active NPC encounter or a fabricated NPC.
Counter formulas, budgets, logging and removal behavior remain shared. A new
test with no encounter cures4 of6 poison counters, preserves the remaining2
and separate disease counters, then removes each with the appropriate cure.
It also checks a redundant poison cure changes nothing. This is not persistence
or network-delivery proof.

Focused Vitest passes: new boundary1test
(`/var/tmp/idlequest-counter-target-boundary.log`), existing counter/cure/dispel
regressions21passed467unselected (`/var/tmp/idlequest-counter-existing-regressions.log`).
Typecheck passes (`/var/tmp/idlequest-counter-target-typecheck.log`). No browser
test or dev-server rebuild in this checkpoint. Next: server-authorized,
character-scoped cure delivery into this core, correlated application receipts
and reconnect handling; tie those receipts to durable donation/effect delivery.
Do not remove cure support from the deferred list or promise working donation
cures before that path and a real poisoned-player Give test pass. No new Go
cure simulator should be written that ignores the authoritative client effects.

Quest-targeted player healing is now connected, not just captured. Typed
`QuestSpellCast` retains source NPC type/concrete or pending spawn and a target
actor reference. NPC GetID now exposes the concrete spawn rather than its type;
actor references are registered separately from numeric IDs, with collisions
left unresolved rather than guessed. Pending target GetID remains unsupported.
When captures merge, pending spell/signal/depop references are rebased so an
encounter's child cannot accidentally refer to an earlier capture's spawn.

World execution verifies the owning session, zone/instance and exact living
NPC source, then applies targeted beneficial heals/buffs through the shared
spell-effect settlement code. Other characters, unresolved/NPC targets,
detrimental and unsupported instantaneous effects are explicit errors. The
CastSpell capability remains partially deferred: cures, utility and self-cast
families, NPC targets and durable payment/effect coupling are still outstanding.
The hand-in commits before runtime spell delivery; this is not an atomic
donation-plus-heal transaction and a failed delivery currently has no outbox.
Do not describe this as complete quest spell support.

Actual Ulazia healing donation GPU test passes in11.9s including hardware
preflight (`/var/tmp/idlequest-quest-healing-e2e.log`): real Give-window10gold
donation, actual spell17 receipt with positive healing, NPC caster attribution,
updated player HP and consumed gold. Initial health/money, level and player
travel are debug setup; neither the NPC nor heal is injected. Local SQL test
separately follows Lua capture through world execution and verifies HP persisted
to the actual temporary character schema; wrong target and stale-zone attempts
are rejected (`/var/tmp/idlequest-quest-heal-final-sql.log`). The stale-zone guard
was added after the browser run and verified by that SQL test. Typecheck passes
(`/var/tmp/idlequest-quest-healing-typecheck.log`). Dev session42953 currently
runs the heal build before the final stale-zone guard
(`/var/tmp/idlequest-quest-healing-dev.log`). No migration, commit or deployment.

Shared player-target spell effects now separate caster identity from a client
session. The existing heal/buff implementations were mechanically extracted
from `world-spell-handlers.go` into cohesive248-line
`world-spell-player-effects.go`; ordinary player callers retain their adapters.
The core accepts source name/level/optional character ID and an optional
caster-notification session, so NPC effects can use the same calculations,
stacking, persistence and target projection without inventing a player caster.
Self-message selection now compares actual character identities rather than
session equality, also correcting a controlled companion healing its owner
being described as self-healing. Caster notifications still use the real
session, avoiding duplicate updates when owner and target share one connection.

Full quest/world Go suites pass (`/var/tmp/idlequest-spell-source-tests.log`).
New tests cover a30-point NPC heal and correct NPC attribution, no live-vitals
publication after failed settlement, buff publication only after commit, and
controlled-character identity despite a shared owner session. These are shared
effect tests, not a claim that a Lua quest can cast yet. Typed quest source and
target capture/resolution, cures and other effect families, durable hand-in
coupling and rendered donation verification remain outstanding. Do not remove
the CastSpell deferred flag until those paths actually execute. No migration,
dev-server rebuild, browser test or deployment in this extraction checkpoint.

Quest spell execution gap confirmed: `NPCProxy.CastSpell` ignores its target
argument and appends only an integer to `QuestCapture.Spells`. No world executor
reads that list; `applyRuntimeCapture` never applies its spells. The same list
also receives self_cast/selfcast/SelfCast and soulbinder compatibility calls.
Soulbinder binding separately captures a real Bind request, so that convenience
is not evidence that the spell executor exists. NPC GetID still returns its
type ID rather than concrete actor identity. Do not enable general NPC lookups
or claim donation healing/cures work until these boundaries are addressed.

NPC CastSpell is now explicitly deferred in strict verification, preserving
legacy capture outside strict tests. Canonical runtime-coverage generation
finds29 enabled Classic/Kunark scripts referencing it and removes it from
implemented-effect coverage (18 selected cases,42/105 eligible APIs;23 deferred
APIs total). Source-backed Divine Duty tests exercise Ulazia's10/8/6gold healing,
poison-cure and disease-cure branches: nominal spell IDs17/203/213 are captured,
but strict verification rejects each; ordinary hail dialogue still succeeds.
This checkpoint identifies and guards a real missing behavior; it does not
implement spell effects, refund existing gameplay donations or certify quests.

Next implementation packet: preserve source/target actor identity in a typed
quest spell request, then connect it to shared authoritative spell application.
Existing `applyPlayerBuffWithSettlement` / `applyPlayerHealWithSettlement` provide
durable effect primitives but assume a player caster session; passing the owner
session as if it were the NPC would misattribute the spell and self-heal text.
Extract caster metadata/presentation from that session assumption rather than
copying heal/buff mechanics. Explicitly cover cures, utility/self-cast and
detrimental/NPC-target effects; do not label all casts implemented after only
heals work. Keep unsupported branches visible until their executor exists.

Pending-proxy Signal/Depop identity is now implemented as well as AddItem.
Before world creation assigns a concrete ID, these methods retain the same
one-based spawn-request reference as inventory. Runtime delivery maps it to
the exact request result, including a reused unique_spawn actor. Missing or
malformed references error instead of becoming type-wide effects. The existing
live-population resolver still makes a disappeared exact actor an idempotent
no-op; explicit type-wide eq.signal remains a broadcast within owner scope.

Lua-through-world tests create two same-type children alongside a same-type
existing sibling and another owner's actor: only the second child receives the
signal and only the first child depops. A second test exercises unique reuse
without inventing selection order among multiple eligible actors. Invalid
indices, conflicting concrete/pending IDs and mismatched types are rejected.
Full quest/world Go tests pass
(`/var/tmp/idlequest-pending-actor-effects-go.log`). No migration or browser
verification in this checkpoint; local dev session46148 still runs the preceding
inventory build. This preserves existing grouped effect delivery order; it does
not prove general Lua source-order semantics, pending actor GetID, arbitrary
NPC spell targeting, movement or durable/replay-safe world effects.

Pending-spawn inventory routing is now implemented. Previously,
`eq.spawn2(...):AddItem(...)` stored the item in the summoner's script state,
even for a different NPC type. Returned proxies now carry a one-based pending
request index (safe when the spawn slice grows); their item additions travel
with that exact request rather than the summoner's inventory. New spawn rows
and initial inventory commit together. An owner-scoped `unique_spawn` that
reuses an existing living actor appends to that actor's exact inventory under
the same row-locking writer, without erasing Lua progress. Other-owner,
wrong-instance and dead actors cannot receive that append. No migration.

Focused Lua/population tests cover same-type siblings, slice growth, retained
proxy references, unique reuse after population reconstruction, and unrelated
owners. The opt-in local SQL test follows Lua capture through actual spawn
storage and the real NPC inventory reader, checks that the summoner has no
child inventory, preserves an existing actor's Lua stage and proves failed
inventory binding rolls back the new spawn row. Both local SQL suites pass:
`/var/tmp/idlequest-spawn-inventory-sql-final.log`. A shared test-only temporary
schema helper retains the existing loopback-only opt-in, one connection and
no-reconnect protections; no persistent character or spawn rows are written.
This is not a full cross-NPC rendered quest playthrough or a durable outbox.
General lookup/enumeration remains deferred: pending Signal/Depop ordering,
other mutators, GetID identity and movement still need explicit handling.
Full quest/world Go suites pass
(`/var/tmp/idlequest-pending-spawn-inventory-final-go.log`). Rebuilt local dev
session46148 (`/var/tmp/idlequest-pending-spawn-inventory-dev.log`) includes this
change. GPU Docker Lhranc regression passes both tests in13.4s
(`/var/tmp/idlequest-pending-spawn-lhranc-e2e.log`): the seeded final hand-in
creates actual actor5000000000339, its normal10-HP defeat yields the real corpse
sword. This verifies normal spawning still works, not a rendered AddItem-on-child
quest or complete epic acquisition. No commit, push or deployment performed.

Quest NPC inventory saves now share a transactional merge instead of replacing
the physical inventory from a callback's stale Lua snapshot. The helper locks
the exact owner/zone/instance/spawn row, reads its latest inventory and appends
only the current event's AddItem delta. Ordinary callbacks and atomic turn-ins
use the same writer. Inventory-only updates preserve Lua variables; invalid
actor deltas and malformed inventory fail explicitly. Previously ignored
ordinary callback state-save errors now propagate.

Verification: full quest/world Go tests pass
(`/var/tmp/idlequest-inventory-state-sql-compile.log`). The opt-in local SQL
temporary-table suite passes stale-snapshot preservation, commit and rollback
checks, alongside the existing ground-pickup
atomicity tests (`/var/tmp/idlequest-inventory-state-sql.log`). The SQL test uses
one physical connection and does not prove concurrent scheduling. No persistent
game rows or migration ledger entries are changed by that suite. This is not
general Lua-variable conflict resolution or a durable world-effect outbox.
Pure Go tests additionally preserve deliberate identical AddItem calls.
Cross-NPC/pending-spawn AddItem delivery is still the next prerequisite before
enabling general NPC lookup APIs. Raid work remains parked above.

The first GPU rerun of this merge reached the normal quest encounter but
timed out awaiting death: exact Kurron17925 remained alive at10HP, fleeing
75units away while the player had AutoAttack on and navigation inactive.
No corpse receipt existed (`/var/tmp/idlequest-inventory-state-kurron-e2e.log`).
The fixture now explicitly repositions only the player beside the exact living
NPC during the bounded kill wait. This discloses an additional test travel aid;
it is not a navigation fix, fabricated death or bypass of corpse loot.
- [ ] Separately investigate manual `/nav target` completion followed by
  low-health fleeing: a one-shot route can finish before the NPC moves away.
  Do not make quest verification depend on finishing that navigation project.

Final positioned Kurron regression passes in31.8s (both hardware-GPU preflight
and quest test): `/var/tmp/idlequest-inventory-state-kurron-positioned-final.log`.
The same explicit player-positioning aid also covers the incoming-hit check;
the intermediate rerun failed there before reaching the kill section
(`/var/tmp/idlequest-inventory-state-kurron-positioned-e2e.log`). Final checks
still require one server-origin encounter, real incoming damage without enabling
player melee, normal10-HP death, exactly one carried letter and its consumption
by Duriek. Typecheck passes
(`/var/tmp/idlequest-inventory-state-typecheck-final.log`). Current dev server is
session83540, `/var/tmp/idlequest-inventory-state-dev.log`, rebuilt with the
transactional merge. No migration, commit, push or deployment in this checkpoint.

Quest NPC inventory identity/decoder hardening is implemented. Existing
inventory lookup already reads the exact owner/zone/instance/spawn state key
and strips inventory from type-scoped legacy state fallback; no parallel loot
store was needed. New AddItem records also retain concrete SpawnInstanceID
through JSON persistence, rejecting delivery to a different same-type actor.
Older records lacking the embedded ID remain valid only through that existing
exact database key. Malformed inventory previously decoded as nil, silently
turning corruption into an empty corpse; decoding and invalid item/charge
records now return errors before death settlement. AddItem cannot overwrite a
malformed prior inventory. Full quest/world Go tests pass
(`/var/tmp/idlequest-npc-loot-identity-full.log`), including round-trip identity,
legacy data and malformed-state preservation. No migration needed.
Local server rebuilt as session34292
(`/var/tmp/idlequest-exact-npc-effects-dev.log`) with these changes and the
earlier exact Signal/Depop targeting. Kurron real-letter GPU regression passes
both tests including hardware preflight in25.0s; session44636 terminal0,
log `/var/tmp/idlequest-kurron-exact-inventory-e2e.log`. Real Give, stored NPC
letter, normal10-HP death, corpse pickup and Duriek consumption remain intact.
Typecheck passes (`/var/tmp/idlequest-exact-inventory-typecheck.log`).
This does not yet route AddItem from a newly spawned/lookup proxy into another
actor's state; general lookup remains deferred until that delivery is correct.

Concrete NPC-method effects are now preserved end-to-end for Signal/Depop.
The old `NPCProxy.Signal` emitted only a type ID (broadcasting to siblings),
and `NPCProxy.Depop` emitted only a type ID (removing the first match rather
than necessarily itself). The event's actual spawn ID now enters its proxy
and both captures. Shared `resolveQuestActorTargets` resolves against the
owner/zone/instance's alive runtime view, including hidden controllers and
owner-specific suppressions. Missing, changed-type or other-owner exact
targets are idempotent no-ops, never redirected to a same-type sibling.
Explicit `eq.signal(type, signal)` retains type-wide delivery. Tests cover
Lua capture, world signal dispatch to only the second of two same-type actors,
explicit broadcast, exact depop, repeated depop and unchanged other-owner
views. Full quest/world Go suites pass
(`/var/tmp/idlequest-exact-actor-effects-tested.log`). No migration/protocol
change. Dev session48855 still runs the preceding timer-context build; rebuild
before browser verification of this newer effect-target change.
General NPC lookup/enumeration remains deferred: GetID semantics, AddItem,
CastSpell and movement capture still need exact actor handling before returned
proxies can safely expose the complete method surface. Do not remove the
capability flags merely because Signal/Depop are now ready.

Elixir-to-Tome connected extension now passes GPU Docker in3.1minutes,
including the natural respawn wait and renderer preflight:
`/var/tmp/idlequest-elixir-tome-natural-camp.log`. Smaka999pp is rejected and
refunded;1000pp buys14365, Duriek consumes that earned elixir, actual naturally
respawned guard15782 drops14382 after a normal10-HP kill, and Duriek consumes
the looted Tome and names all four next ingredients. Initial money/level/skills
and player travel are debug setup; no items, NPCs, timers or loot are injected.
Kurron's letter and later weapons remain separate segments, not one full epic.

Shared timer dispatch correction: NPC timers now use the same event-context
and effect-delivery path as ordinary spawn/combat/signal callbacks. Previously
timers omitted live NPC-presence context, and could execute the old NPC's
script after its static placement had respawned a different type. Tests cover
server-only actors, owner-filtered presence, wrong owner/instance, dead actor,
replacement type and non-execution on rejection. Even an empty authoritative
presence list now overwrites caller-supplied fields without mutating them.
Focused and full quest/world Go tests pass (`/var/tmp/idlequest-timer-context-full-go.log`).
Dev session63291 was stopped only after the acquisition test finished, to
rebuild this Go change; new session48855 logs to
`/var/tmp/idlequest-timer-context-dev.log`. Garzicor timer regression passes
all three tests including GPU preflight in3.0minutes
(`/var/tmp/idlequest-garzicor-shared-timer-e2e.log`, session42315 terminal0).
Actual speech, timed ground delivery and authorized single pickup are intact
under shared timer dispatch. Empty private presence-field precedence also passes focused
Go regression; it must not fall back to caller-supplied public presence IDs.

Exact lookup provenance: local EQEmu revision
`584320202faf911bbb531f62782271ca964e11cb`, `zone/entity.cpp:1133`, implements
`GetNPCBySpawnID` by comparing `GetSpawnGroupId()`, not entity ID or spawn2
placement ID. Preserve this distinction when implementing the still-deferred
lookup/enumeration boundary; imported call sites also pass spawn-group IDs.
`NPCProxy.GetID` currently returns a type ID, and several mutations are only
type-addressed. Do not expose many resolved proxies until mutations preserve
the exact intended actor rather than applying to every NPC of that type.

NPC population enumeration was another unreported compatibility stand-in:
`GetNPCList` and its normalized `GetNPCEntries` iterator return only the event
NPC. Both now record deferred capability use; strict verification rejects a
reward branch that assumes this singleton means all other enemies are gone.
Normal compatibility behavior is unchanged. Full Go quest/exporter tests pass;
canonical coverage generation reports19cases covering44/106target APIs and
six enabled Classic/Kunark source scripts using `GetNPCList`. This does not
implement population lookup or mark those quests playable. Keep enumeration
with exact actor lookup in the next shared runtime boundary; return actor
identity from the owner/zone/instance population, never substitute the current
NPC for a missing requested actor. Logs: `/var/tmp/idlequest-enumeration-full-tests.log`
and `/var/tmp/idlequest-enumeration-coverage.log`.

Elixir-to-Tome extension is running in GPU Docker session41151 at
`/var/tmp/idlequest-elixir-tome-natural-camp.log`. Earlier extension already
verified real Smaka999pp rejection/refund,1000pp payment for14365, its actual
Duriek consumption and searching dialogue; remaining guard58661 died normally
but dropped nothing, and no other guard was alive. That terminal31.7s run did
not complete Tome delivery (`/var/tmp/idlequest-elixir-tome-e2e.log`). The new
fixture retains the same character and waits up to700s for a natural guard,
pausing rendering while waiting. No restart, spawn reset or loot reroll. Its
full extended chain is not yet certified; the earlier Tome-only pass below
remains valid only for that narrower segment.

Dusty Tome acquisition segment passes GPU Docker in22.4s including preflight
(`/var/tmp/idlequest-dusty-tome-navigation.log`): Duriek's searching response,
real ratman guard39024 at placement58660, normal10-HP death, manual corpse
pickup of14382, actual Duriek consumption, then correct four-item directions.
No starting or intermediate item grants. Only player preparation/travel and
exact NPC HP are debug-assisted; normal target navigation follows fleeing.
The fixture is bounded to three distinct existing guards, preserving actual
loot rolls (local raw entry35%, not a guaranteed drop). This run got the Tome
from its first guard; exhausted natural rolls must fail explicitly, not reroll
the population. Earlier letter/elixir steps are separate; their faction-only
gates are deliberately waived. Run `npm run test:e2e:quest-dusty-tome --
--reporter=line`; excluded from normal discovery. File-backed receipt records
the actual source, inventory and dialogue. Typecheck and diff whitespace check
pass. Complete SK weapon acquisition/continuous epic remains unverified.

Kurron fixture now follows the user-directed reduced-HP policy: no companion
party or full-health kill. GPU Docker passes in23.6s including hardware
preflight (`/var/tmp/idlequest-kurron-ten-hp-navigation.log`): actual Give UI
consumes the three seeded entry pieces and900pp, mission dialogue starts one
server-owned encounter, incoming damage leaves player melee off, repeated
dialogue does not restart combat, then the10-HP actor dies normally and its
real Letter is looted and consumed by Duriek. Normal `nav target` is needed
after lowering HP because the NPC legitimately flees; stationary manual melee
had timed out. A diagnostic rerun found that wounded live actor75units away.
The incoming-hit setup explicitly restores this exact actor's max HP before
testing damage, then lowers it for the kill; no respawn/loot reset occurs.
Failure-state capture is file-backed. This supersedes older full-health
Kurron timings and group-setup instructions below.

Post-boundary GPU Docker regressions also pass on the rebuilt server:
`quest-chain-smoke` (two tests including renderer preflight, 12.4s) earns Marl's
Seal, trades it to Gerot for the Note and returns the Note to Marl without
granting intermediate items, despite deliberately hostile quest faction.
`debug-real-ground-item-pickup.spec.ts` (two tests, 11.2s) verifies Book of Souls
pickup and lore rejection. Logs: `/var/tmp/idlequest-post-actor-quest-chain.log`
and `/var/tmp/idlequest-post-actor-ground-pickup.log`. These are command-driven
mechanics checks, not full rendered quest playthroughs. The Garzicor review
ledger now records partial Velious coverage and the unresolved timing mismatch,
replacing its stale Classic/Kunark-only out-of-scope label.

Server-only actor boundary implemented; focused Go/typecheck and both Garzicor
GPU Docker cases pass (three tests including hardware preflight, 2.9 minutes;
`/var/tmp/idlequest-garzicor-server-actors-e2e.log`). Real nearby say spawns the
owner's ghost; remote say and ooc do not. The actual 60-second pause and fourteen
six-second callbacks produce speech and both source-linked ground items.
Authoritative listing retains the items, remote pickup fails, each local pickup
grants exactly one item, and repeat pickup fails. No timers, NPCs or rewards are
injected; player travel and pickup requests are debug-assisted, not rendered
ground-mesh clicks. This verifies the bones segment, not the complete quest.
One important data
correction to the earlier diagnosis: bones123192 has race127/untargetable1,
but ghost123193 has race127/untargetable0. Race127 also includes legitimate
shadowed-man enemies. `IsClientVisibleNPC` now uses the explicit untargetable
field rather than model race; the two old NPC-ID exceptions are no longer
needed, and their targetable behavior has regression coverage. This also
restores other targetable race127 actors to normal projection, not just
Garzicor; content-specific bogus targetability must be corrected in data rather
than hiding every actor with that model.
Population loading retains the full content-filtered server pool. Visible
discovery/projection excludes untargetable actors; runtime lookup, spawn,
signal, timer and speech keep them. Spawn initialization still calls the
existing enabled-script handler resolver, not invented trigger behavior.
Central quest spawn projection suppresses hidden controllers, and combat
ownership/client-observed runtime events reject them. Tests prove hidden
spawn/signal delivery, visible-only packets, exact actor lookup, and rejected
combat/client observations. The dependency auditor now supports
`-include-server-actors`; Garzicor263911 is selectable100% in that runtime view
(`/var/tmp/idlequest-garzicor-server-actor-audit.log`).
Garzicor E2E now correctly asserts bones are absent from client spawn packets
and observes the resulting targetable ghost, including incremental respawn
packets. This is the required outcome under the new boundary, not a weakened
requirement that permits an absent server listener.

Atomic static ground pickup GPU regression passes: Book of Souls acquired
through the real pickup request, removed from authoritative ground listing,
lore-conflicting second pickup rejected without consuming the reset object,
then pickup succeeds after test inventory clear. Two passes including hardware
renderer preflight in11.4s (`/var/tmp/idlequest-atomic-static-pickup-e2e.log`).
The fixture explicitly resets the initial static ground source and uses debug
travel/pickup commands; it does not certify rendered ground-mesh clicking.
Quest-created Garzicor ground delivery now also passes with the server-only
actor boundary, as recorded above. Earlier blocked runs below are historical.

Garzicor GPU run exposed a preceding spawn-filter defect. The first case failed
before speech because NPC123192/placement263911 is absent from the real zone
response. Runtime selector audit confirms "no eligible static entry" despite
the DB placement having100% weight, valid zone/version and no content flags.
`db/zone/zone-spawn.go` excludes race127 wholesale except MonkEpicPresence and
Ssynthi, and excludes untargetable NPCs. Garzicor's invisible trigger is race127.
This prevents server quest initialization, not merely rendering. Stopped the
exact second-test container7ff32dcaf385 after confirming the shared missing
prerequisite; do not call its timer path a timed failure or a pass. Evidence:
`/var/tmp/idlequest-garzicor-speech-e2e.log`,
`/var/tmp/idlequest-garzicor-spawn-audit.log`.
Next systemic fix: retain server-side quest-trigger actors separately from
client-visible/targetable NPC projection, using actual runtime handler
eligibility. Do not add a third arbitrary NPC-ID exception or expose every
invisible/untargetable actor to player targeting/combat. Existing monk/Ssynthi
interaction behavior must remain intact. Then update the Garzicor test to
observe the appropriate server-boundary proof rather than requiring an invisible
trigger to be presented as an ordinary rendered NPC.
The new server is running in dev session2197, with136 applied and atomic ground
pickup active. Static Book of Souls GPU pickup regression is now running at
`/var/tmp/idlequest-atomic-static-pickup-e2e.log` to verify that independent path.

Caradon/Soulcase run ended after1h with a bounded-camp failure: three real
placeholder kills plus adds, then another placeholder on the final natural
respawn. It never reached Caradon/Kyrenna or the connected combine. GPU preflight
passed and the repeated static-ID loot receipt boundaries were exercised, but
the connected chain remains unverified. Full terminal evidence:
`/var/tmp/idlequest-caradon-heart-container.log` (container exit1). Original
wrapper exit143 was not the test outcome. Do not restart solely to reroll it.

After that terminal result, stopped the exact owned dev session24739 normally
and applied136 locally. No matching Garzicor rows existed in the preimage.
Ledger checksum now immutable:
949bf296c9d2a94a51cef58e170a402fc49516ccf836f1156cf3ba29db245866.
Receipt: `/var/tmp/idlequest-local-migration136-receipt.log`.
Fresh `npm run dev:test` build is starting with speech and atomic pickup changes
at `/var/tmp/idlequest-quest-speech-dev.log`; browser verification is pending.
No production data, deployment, push or commit was performed.

Migration136 upgrade edge corrected before application: persisted
spawn_event_fired prevents old characters from repeating Garzicor's timer
initialization on login. Defaultfalse alone would therefore strand already
initialized bones listeners. The still-unapplied migration now enables only
the reviewed necropolis/NPC123192 rows with fired spawn and all six existing
bounds. Other proximity triggers remain disabled; no spawn handler is replayed.
Old disable_proximity_say was unbound, so there was no successfully persisted
listener-disable state to recover from that version. Rehearsal now includes
canonical037 plus039, preserves spawn claims/bounds and excludes unrelated NPCs:
`/var/tmp/idlequest-quest-migration136-upgrade-rehearsal.log` passes.
This is content-qualified data backfill, not a runtime NPC-ID exception.
Local read-only inspection found no existing initialized Garzicor rows; do not
extrapolate that local result to production. Speech users in other/later-era
scripts still need content review before any similar data backfill.

Temporary-table atomicity tests now refuse any replacement physical connection,
so loss of their sole connection cannot silently expose persistent table names
to subsequent test writes. Guarded rerun passes:
`/var/tmp/idlequest-atomic-ground-sql-guarded.log`.

Atomic ground-item settlement implemented, not yet loaded/browser-verified:
the old world handler committed ground Claim before DeliverRuntimeRewards,
whose inventory grant is a separate transaction and cannot report failure to
the caller. A grant failure could permanently consume the ground source.
Static and runtime ground stores now expose ClaimTx requiring the caller's
inventory transaction. `SettleRuntimeItemClaim` shares extracted inventory
snapshot locking and plan application with ordinary quest hand-ins; source
claim, item-instance creation and inventory insertion commit together. Session
inventory and ground despawn/success projection happen only after commit.
Runtime reward planning leaves unrelated Give-window items untouched.
Full quest/world/importer Go suites pass
(`/var/tmp/idlequest-atomic-ground-full-tests.log`). Opt-in local MySQL tests
using connection-local temporary tables prove rollback after source error,
rollback of claim plus partially inserted rewards after unique-slot failure,
stale-inventory rejection, successful commit and repeated-claim rejection
(`/var/tmp/idlequest-atomic-ground-sql-rerun.log`). The fixture copies actual
columns/indexes but omits foreign keys unsupported on temporary tables; it
disables statement caching on its single test connection only. No persistent
game tables are written by those checks. This does not simulate connection
loss exactly during COMMIT or verify client reconnect projection.
No additional migration is required for atomic pickup; the pending browser
run still requires speech migration136 and a rebuilt server. Re-run the static
Book of Souls pickup regression as well as Garzicor after that restart.

SK acquisition dependency audit (local, read-only): the runtime spawn-pool
selector finds positive eligible sources for ratman guard39024/Dusty Tome14382,
chest39056/Cell Key14373, Shin Lord65128/Ghoulbane5403, Dread72000/Soul Leech11609,
Spiroc Lord71012/Blade5430, Rharzar50324/Spine14372, and ashenbone76002/Hide14371.
All seven expected item rows join through those NPCs' actual loot tables, with
positive table/item chances and multipliers. Their loot-entry expansion bounds
are -1/-1, NPC bounds0/0 and content flags null. Raw SQL evidence is
`/var/tmp/idlequest-sk-acquisition-loot-audit.json`; selector logs are
`/var/tmp/idlequest-sk-{hole-acquisition,ghoulbane,soul-leech,abrogation,spine,hide}-audit.log`.
Do not interpret a raw loot-entry chance as the final drop probability: group
minimum/maximum drops and other entries affect the selection. This is not a
live-presence or real-kill proof. Notable waits: chest50% per640s, Shin Lord25%
per960s, Dread259200s respawn, Spiroc Lord14400s, and several low-weight Rharzar
placements. Cached `npc-pages/dread-70d5104bbd.wiki` explicitly lists Soul Leech;
the epic page's Cazic-Thule description is not grounds to remove Dread's drop.
Next reference-chain acquisition test should retain real drops and bounded
camping, report absent prerequisites distinctly, and not pretend the legacy
fixture's fabricated defeat/reward path proves procurement. No loot/spawn
data changed in this audit.

Garzicor timed-speech/ground-pickup E2E is authored and typechecked, not run:
the second case in `quest-proximity-speech.spec.ts` uses real chat, the actual
60s pause plus fourteen6s timers, captured final speech, both1888/1889 objects
from placement263911, authoritative re-listing, remote pickup rejection,
successful nearby pickup and duplicate-claim rejection. Only player travel is
debug-assisted; pickup uses the real client/server request through the debug
command, not a rendered mesh click. No timers or items are injected. Evidence:
`/var/tmp/idlequest-garzicor-timed-e2e-typecheck.log`. Browser execution still
waits for migration136/new Go server after the live Caradon camp terminates.
Current Caradon run has defeated three natural placeholders and their adds;
it is on its last allowed natural1200s respawn wait, not a completed chain.
The exec wrapper90226 subsequently exited143, but Docker inspection confirmed
its exact container9d53793eb305 (`idlequest-playwright-432009`) still running the
Caradon spec, started02:56:35UTC September6. Do not restart the server or test
because the wrapper ended. Follow authoritative container logs at
`/var/tmp/idlequest-caradon-heart-container.log` and its `docker wait` result.

Registered encounter speech audit: actual NPC/player speech-only handlers
capture responses plus built-in Lua globals in ScriptState. Therefore the
existing service side-effect/state filter does not currently discard these
handlers. A proposed filter removal was reverted after the executable probe
contradicted that diagnosis. Keep this distinct from the confirmed missing
runtime-to-chat delivery repaired below. Future script-state serialization
cleanup must preserve speech-only output explicitly rather than relying on
built-in globals to make the state nonempty.
NPC/player speech-only Lua regression and full quest/world Go suites pass
(`/var/tmp/idlequest-registered-speech-tests.log`). This is bridge/capture
coverage, not an end-to-end registered encounter playthrough.

Runtime speech delivery checkpoint: full Go quest, world and importer tests
pass (`/var/tmp/idlequest-runtime-speech-delivery-go.log`). Runtime-event
responses now reach the owner's chat through the existing reward-delivery
boundary, with ordinary dialogue/hand-in responses left on their existing
UI path. Runtime responses use the existing player-placeholder formatter.
Optional proximity-listening state survives capture merging, including an
explicit false; switch-only captures are retained as runtime effects.
Focused world regressions additionally prove a stale listener cannot dispatch
to a mismatched NPC type or a removed personal spawn. These are server tests,
not yet proof of the normal-say browser/DB boundary. Migration136 and the
rebuilt server remain pending while the connected Caradon test camps naturally.
The raid TODO above remains parked; no additional raid implementation is needed
for these quest checks.

Migration136 rehearsal passes in a connection-local temporary copy of the
canonical migration037 schema: existing owner/instance/bounds preserved,
listener defaultfalse, duplicate ALTER rejected rather than resetting state.
Added to `scripts/quests/test-sk-content-migrations.mjs`; no live table was
altered (`/var/tmp/idlequest-quest-migration136-rehearsal.log`).
Actual Garzicor Lua focused sequence also passes: timer registers bounds and
enables listening, Remember phrase disables it, pause plus14 help callbacks
capture two ground objects1888/1889 and depop. This manually advances handlers,
not real scheduler/durable ground pickup E2E.
`quest-proximity-speech.spec.ts` is authored/typechecked for real chat input:
remote say and local ooc do not spawn a ghost; local say at actual263911 creates
owner-scoped123193. Initial travel only is debug-assisted. Browser run remains
pending migration136/rebuilt server; do not run against the old camp server.

Normal-say proximity routing implemented (still not loaded live): after existing
chat rate limiting, only say consults registered trigger listeners. The server
uses current live position, checks active zone/instance, owner-scoped enabled
bounds, finite coordinates and exact surviving actor/NPC identity before Lua
dispatch. Client-observed proximity_say is now rejected; there is no legitimate
current client sender to preserve. Other channels do not trigger quests.
Focused world tests pass for inclusive/outside/vertical bounds, disabled/cleared
listeners, owner/zone/instance mismatch, nonfinite values, rehydrated personal
spawn dispatch and direct-observation rejection. Tests invoke the server
dispatcher, not yet the real chat packet/DB/E2E boundary. Migration136 remains
unapplied; server restart waits for the active Caradon browser run. Current
evidence: `/var/tmp/idlequest-speech-scoped-tests.log`.

Proximity speech implementation started, not live/complete:
Lua enable/disable calls now capture an explicit optional bool, including
last-call-wins behavior, and capture reset discards it. Existing trigger-store
Apply persists the bool on the same owner/zone/instance/spawn identity rather
than introducing a separate listener system. Pending migration136 adds
proximity_say_enabled defaultfalse. It has NOT been applied; do not restart
the rebuilt server without it. Focused Lua switch/capture tests pass
(`/var/tmp/idlequest-proximity-switch-tests.log`). Still required: normal say
dispatch, authenticated listener range/ownership filtering, direct-observation
validation, migration verification and actual phrase/timer/ground-drop E2E.
The currently running server/camp remains on its prior build.

Garzicor proximity-speech root cause established (not repaired yet):
`lua_bridge.go` registers enable_proximity_say as a no-op and has no
disable_proximity_say binding. Registered proximity bounds currently deliver
enter/exit transitions only; no normal client/server say path dispatches
proximity_say. The direct client quest-runtime request nevertheless accepts
proximity_say without checking those bounds/enabled state. Existing tests
calling the Lua handler directly do not prove normal speech works.
Cached `the-spirit-of-garzicor-1197223212.wiki` requires actual say at the bones
for both remembered-spirit ground drops and the ghostly-presence spawn.
Next systemic implementation: persist proximity-listening state alongside
existing trigger bounds, implement enable/disable, dispatch normal local say
through owner/instance/range/enabled validation, reject spoofed remote direct
observations, and test actual phrase -> timed ground-drop/spawn delivery.
Keep this separate from dialogue-button discovery and later-era mirror events.

Import-directory hygiene fixed: one shared non-quest directory list now covers
both discovery and legacy-row disabling (.git,lua_modules,plugins,utility).
Source text is retained; encounter modules are deliberately not included.
Importer unit tests pass. Local preflight found exactly one enabled matching
row: quests.id12299, utility/comments-helper-generator, enabled1, source SHA256
85c0b4e7501110a0b0dd78369acdd667cb96caeb50ba6df6f90badfa2c5acdef.
Only that local row was disabled transactionally; source retained, recoverable
by restoring enabled1. The enabled-DB audit now parses all4799 enabled rows
with no failures (`/var/tmp/idlequest-enabled-dialogue-clean.log`). No server
restart/reimport or production change occurred. Future normal imports apply
the same directory cleanup, so this is not a one-off NPC-name exclusion.

Enabled local DB dialogue inventory now available through read-only opt-in
`TestAuditLocalEnabledDialogueShapes` (requires both content-audit and
`IDLEQUEST_LOCAL_DB_AUDIT=true`, loopback DB host,30s query deadline). Current
result:4800 enabled rows,2273 named say handlers, no assigned handlers, the same
two nested handlers and66 exceptional message-read scripts. These include
non-zone encounter modules and later-era zones; enabled row is not proof of
P99 applicability or a live placement. Log:
`/var/tmp/idlequest-enabled-dialogue-shapes.log`.

- [ ] Import hygiene: exactly one parse failure, utility/comments-helper-generator,
  whose DB text starts with the original Perl shebang/tool description.
  Current importer accepts only .lua, but leaves stale DB rows. Audit and retire
  non-runtime/non-zone legacy rows through a reviewed data change; do not claim
  a current Lua conversion error or blindly disable every encounter module.
- [ ] Proximity-speech content: necropolis/123192 is Garzicor's timed phrase
  sequence; frozenshadow/You_ is a Monk-prequest state/proximity handler;
  tox/#wall_echo is the paired scripted mining event. Verify era, real
  placement, runtime proximity/signal/timer delivery before enabling repairs.
  They are not missing ordinary event_say option branches.
  Guard_Drath's empty literal findi matches everything intentionally; no useful
  response keyword can be inferred from it. Soulbinder wrappers remain a
  plugin path with explicit bracketed response text.

Dialogue syntax audit extended before further runtime inference work:
`TestAuditOverrideDialogueShapes` now identifies message reads not belonging
to a direct literal `findi` inside the named say handler. A focused classifier
test covers helper, dynamic argument, equality and local alias shapes.
Current override corpus:1234 files,966 named say handlers, no parse failures or
assigned handlers; the same two nested handlers remain. Exceptional reads are
15 `plugin.soulbinder_say(e.message)` wrappers (including Romi) and tox/#wall_echo
in `event_proximity_say`, not ordinary dialogue options. Soulbinder plugin
already emits `[bind your soul]` and implements bind behavior. No new general
dynamic-keyword inference is justified by this override inventory. This is not
a census of every enabled DB/upstream script, nor proof that proximity behavior
works. Local wall_echo and38139 rows are enabled; timeline/actual placement and
paired signal/proximity behavior need separate review before any change.
Evidence: `/var/tmp/idlequest-dialogue-message-shapes.log`, focused classifier
and opt-in audit pass. No production dialogue behavior changed.

Connected Caradon/Soulcase continuation is running in
`/var/tmp/idlequest-caradon-heart-chain.log`. The Caradon spec now uses a
level60 Warrior and 10-HP normal fights, earns Heart/Blood, gives Blood to Marl,
then takes the same Heart to Knarthenne's earned Soulcase/real Combine UI.
`questSoulcase.ts` mechanically extracts the passed standalone combine and
requires an already-present Heart; neither caller can silently repair it.
Typecheck passed. Current run killed the real placeholder and two adds, then
entered its natural1200s respawn wait. Do not report connected completion yet.
The Caradon completion receipt check was additionally tightened after this
run loaded: fresh receipt slice plus inactive runtime actor. Reverify that
latest assertion version separately; old placeholder receipts share its ID.

Soulcase browser verification now passes on hardware GPU in 11.2s including
preflight (`/var/tmp/idlequest-soulcase-combine.log`): earned container dialogue,
Advanced rejection with unchanged inventory, real portable Combine UI,
consumption of Heart14380 and Soulcase17051, output14368. Entry Heart is seeded;
this is not yet connected to Kyrenna's earned Heart in one continuous run.
`test:e2e:shadowknight-epic-recipes` now runs this verified container path instead
of the obsolete Advanced fixture; the JSON remains a labeled historical ID
inventory. No gameplay migration or authorization relaxation was needed.

Glohnor positioned rerun completed successfully: two passes including GPU
preflight, 9.3m (`/var/tmp/idlequest-glohnor-positioned.log`). This run waited
for the already-killed placement's natural respawn and received the Ghost;
no new placeholder/add fight was needed, so the new debug-positioned add
branch remains unverified. Actual mummy death/loot and both follow-up hand-ins
passed with only the initial Shroud seeded. No corpse rewards were replaced.

Soulcase acquisition/combine review: local recipe9825 is enabled/no-fail,
`replace_container=1`, with heart14380 -> innocent heart14368 and exact
container17051 (bagtype13, two slots). Effective Knarthenne dialogue grants
17051 for `heart of an innocent`, matching the preserved epic page. The legacy
`shadowknight-epic-recipe-cases.json` runner only invokes Advanced crafting;
current shared access correctly rejects quest-only containers there, so it
cannot certify this path. New `quest-soulcase-combine.spec.ts` earns the case
through dialogue, asserts direct Advanced rejection without inventory change,
then uses the actual portable Combine button and checks both heart and case
consumption. It seeds only the entry Heart of Kyrenna: isolated combine segment,
not continuous acquisition. Browser verification is queued after the live
Glohnor camp; do not mark the new spec passed or retire the old runner before
that result. No production recipe or authorization change is needed so far.

Glohnor continuation: `test:e2e:quest-glohnor-chain` now seeds only the Shroud,
requires a real Ghost, follows its actual mummy spawn, uses 10-HP normal combat,
and carries both corpse items through Gerot/Marl without replacement grants.
The initial run rejected the absent natural Ghost, correctly. The new bounded
camp uses existing placement15964 (EQ450,762,-653.25), actual eligible
placeholders39137/39164, 640s respawn and at most three kills. The shared camp
helper accepts an optional reduced combat HP after the encounter starts,
including social adds; ordinary callers are unchanged. Typecheck passes.
GPU rerun log: `/var/tmp/idlequest-glohnor-camp.log`; completion remains pending.
The cached epic page explicitly corrects the older charging-mummy description:
P99 requires fighting it in the crypt. No automatic aggro script was added.

- [ ] Separate navigation follow-up: Hole add15989 remained at Babylon
  Y=-641.14 while `/nav target` left the player at Y=-680.12 (39 units below,
  horizontally0.56 apart). Reduced-HP camp killed placeholder15964 normally
  but could not melee this add. Evidence is the file-backed Glohnor failure
  snapshot and `/var/tmp/idlequest-glohnor-camp.log`. Diagnose vertical route
  arrival/actor navigation separately; do not claim navigation coverage from
  the quest test. Reduced-HP quest camp now uses disclosed debug travel to
  the actual actor position, retaining ordinary combat/death/loot.

Focused `TestP99GlohnorRequiresShroudAndSpawnsMummyWithoutGrantingDrops`,
Lhranc encounter capture and SK direction tests pass
(`/var/tmp/idlequest-sk-current-focused.log`). These execute the effective Lua
with strict unsupported-effect rejection and hostile stored faction. The new
Glohnor test proves unmatched-item return, required-shroud consumption, exactly
one mummy spawn, ghost depop and no direct head/wrappings grant or forced attack.
It does not prove corpse loot or the browser chain. The positioned browser
rerun is `/var/tmp/idlequest-glohnor-positioned.log`; reuse its live session
rather than restarting the server to reroll an absent natural spawn.

Latest focused quest verification: `npm run typecheck` passed;
`npm run test:e2e:quest-lhranc-encounter -- --reporter=line` passed with the
hardware GPU (RX 9070 XT), one quest test plus renderer preflight. Evidence:
`/var/tmp/idlequest-lhranc-low-hp-rerun.log`. The initial reduced-HP run waited
on the selected-target UI snapshot, which still showed 19000 while the exact
combat actor correctly had 10 HP. The fixture now checks that actor's runtime
HP before normal combat. No death or sword grant is fabricated.

- One quest-only faction policy handles ranked and numeric checks consistently.
  Stored faction and earned faction rewards remain real. Tests include actual
  SK dialogue and Shaman epic turn-ins with hostile standings, plus independent
  class/level/race/quest-state rejection cases.
- A shared `deferred_runtime_apis.json` identifies 17 known compatibility stubs.
  Normal captures report reached stubs once each; strict Go behavior tests can
  reject them. This is deliberately not an exhaustive runtime certification.
- The turn-in exporter and API-based fixture selector no longer present these
  known deferred effects as runnable behavior coverage. The generated report is
  explicitly a static selection inventory, not a list of effects proven live.
- The command-driven quest harness distinguishes `isolated-steps` from
  `continuous-chain`. Continuous mode seeds only declared initial requirements,
  rejects debug combat/acquisition shortcuts, preserves inventory/currency
  between steps and checks exact hand-in settlement. Quantity-aware snapshots
  include general slots, bag contents and cursor, not bank/equipment/trade.
- `quest-continuous-chain-smoke.json` carries the actual Note to Marl earned
  from Gerot across zones and hands it to Marl. It starts with a debug-granted
  Seal of Kastane, uses command-driven targeting/zoning, and pauses rendering.
  This is a two-step continuity test, not a full epic or visual test.

Verification at this checkpoint:

```bash
go -C server test -p 4 ./internal/quest ./cmd/export-quest-turnin-e2e -count=1
go -C server test -p 4 ./internal/world -run Quest -count=1
npx vitest run testing/unit/questFlowContract.test.ts testing/unit/questInventorySnapshot.test.ts --minWorkers=4 --maxWorkers=4
npm run typecheck
npm run quests:build-lua-runtime-e2e-coverage
npm run quests:content-audit
# With npm run dev:test running against the local database:
npm run test:e2e:quest-chain-smoke -- --reporter=line
IDLEQUEST_REAL_GAME_E2E=true npm run test:e2e:docker -- quest-give-ui-hardening.spec.ts --grep 'short epic sequence|items and currency settle atomically|lore-conflicting reward' --reporter=line
```

The 13 focused Vitest tests, Go quest/exporter packages, world quest tests, typecheck and Docker
chain smoke passed. Hardware preflight reported AMD Radeon RX 9070 XT. The
smoke's paused rendering means this is not visual evidence. No migration,
runtime asset release or production change is needed for this checkpoint.
The three existing Give-window regressions above also passed, as did the
static content gates. Those gates still report known, ledger-listed missing
content; a green result does not mean all quests match P99 or are playable.

## High-judgment systemic work next

### Continued checkpoint: owner-scoped quest combat

`eq.attack(playerName)` now captures an explicit request and uses the existing
server combat-start path, including exact live spawn locking, NPC stats,
ownership generation, combat initialization and combat-event dispatch. It is
restricted to the event's owning character, zone and instance. It does not
allow a personal quest script to attack arbitrary other players. Corpse,
missing/replaced actor and stale owner contexts fail. Repeated calls on an
already owned encounter do not recreate it or recursively fire combat start.

The client receives `questInitiated`, `questOwnerCharacterId` and `questZoneId`
in the generated CombatInit type. It starts hate on the player rather than
borrowing an unrelated pending tank/pet pull. Player melee remains under its
existing toggle. Stale owner/zone packets and duplicate quest-related ownership
generations are rejected. Ordinary manual-start behavior is retained. Quest
startup failures do not masquerade as errors for a pending client pull.

Kurron's 900 platinum is now part of `item_lib.check_turn_in`, so the transaction
consumes it along with the three Darkforge pieces and returns extras. The
original Perl used a separate cash predicate; preserving that predicate during
conversion was insufficient for IdleQuest's explicit-consumption Lua matcher.
The override corpus search found Kurron as the split positive requirement;
Hasten's remaining direct currency reads handle rejection/returns and are not
the same defect. Do not introduce automatic consumption of all offered cash.

Evidence:

- Full Go quest/world/exporter suites pass, including real Kurron and Caradon
  Lua, cash shortage/exact/excess cases, actor ownership and duplicate/stale
  attack checks. Caradon's browser encounter/loot sequence remains unverified.
- Eight focused client initiation-policy tests cover owner/zone staleness,
  interleaved quest/manual replies, new incarnations and independent adds.
- `quest-triggered-combat.spec.ts` uses the ordinary spawned Kurron in Overthere,
  real Give UI handlers, server currency/inventory settlement, mission dialogue,
  real NPC damage with player melee off and repeated-dialogue idempotency.
  Initial player level/items/cash/position/HP are debug setup. No NPC or death
  outcome is fabricated. The initial verified version stopped before killing/
  looting Kurron; the continuous extension is tracked below.

Run it with the GPU wrapper and a test-mode server:

```bash
IDLEQUEST_REAL_GAME_E2E=true npm run test:e2e:docker -- quest-triggered-combat.spec.ts --reporter=line
```

The local quest database was refreshed through `go -C server run
./cmd/import-quests` with the local `.env` loaded. No production writes occurred.
Release needs the ordinary quest import and matching client/server builds; no
SQL migration or asset publication was added here. Check stale-client release
policy before deployment: old clients do not interpret the new origin fields.

There were 16 known deferred APIs at this checkpoint. `eq.attack` is no longer one of them, but
isolated hand-in fixture generation still excludes attack branches because it
cannot prove their encounter outcomes. `activated` is still not proof that all
world effects executed. Persistence of item/quest rewards and world-effect
delivery is not one atomic transaction; a durable world-effect retry/outbox is
separate future work, not something this change claims to solve.

1. **Quest-triggered encounter completion.** Owner-scoped `eq.attack` startup is
   implemented above. Extend it through actual death/loot and continuation.
   Entry points: `server/internal/quest/lua_bridge.go`,
   `server/internal/world/world-quest-spawns.go`, `quest_runtime.go`, and
   `world-combat-handlers.go`. Resolve the exact live source NPC and intended
   player, handle existing encounters, owner/instance scope, stale targets,
   duplicate events and cleanup. Test actual attack initiation and death/loot,
   not only a captured request. Kurron Ni and Caradon are useful SK examples.
2. **Dialogue discovery checkpoint implemented.** `dialogue_discovery.go`
   replaces the regex scanner with parsed Lua branch probes. Literal message
   `findi` conditions inside a named `event_say` function are evaluated in the
   real VM against isolated copies of the player's context. Entering the first
   message branch stops the probe before its body; preceding captured effects
   are discarded. No discovery capture reaches persistence or world execution.
   A shared 100ms execution deadline and 64-candidate limit bound each discovery;
   errors return no inferred options and log the NPC/cause. Process/file IO
   libraries are unavailable in preview. Quest modules still use the existing
   loader. Saved script state and newly captured globals feed response options.
   Both hail and keyword events now receive the player's inventory, previously
   omitted even for actual dialogue execution.

   Focused Go tests cover Lhranc with hostile faction, class/level/item/global
   gates, saved state, comments, aliases, isolation, errors and timeout. The
   Docker `quest-dialogue-discovery.spec.ts` passes against the actual local
   server: Lhranc advertises `curse`/`cure`, both reach their intended text, and
   an invalid phrase does not repeat hail. Setup uses guest/debug commands and
   paused rendering; this is client/server dialogue evidence, not a visual or
   full-epic test. The old fixture ID 90093 was not targetable during this run;
   selecting the live Lhranc by name worked (DB also contains type 90221).

   Remaining scope: helper-generated/dynamic phrases, assigned rather than
   named event functions, nested message branches past an earlier message
   branch, and gates inside the selected response body are not certified by
   these probes. Explicit bracket prompts remain supported; an unrecognized
   bracket is not thereby proven actionable. Reachability does not certify
   reward eligibility or supporting quest content. Inventory/task/level gates
   use the request's initial character snapshot; a dialogue reward changing
   those fields is reflected on the next request, not projected speculatively.
   Follow up with corpus classification before broadening candidate extraction.
3. **NPC movement and encounter mutation.** Wire escort/follow/grid movement
   and NPC stat/hate changes through existing authoritative owners. Capturing
   `NPCMoves` is not enough: inspect its world consumer before claiming support.
   Test waypoint/timer events, cancellation, zoning, persistence and exact NPC
   identity. Retire each registry entry only after actual effect tests pass.
4. **Whole SK epic as the reference complex chain.** Build independent P99
   expectations, verify acquisition/recipes/spawns, then test real encounter
   starts, combat, loot and continuation without replacement items. Resolve
   Lhranc's contradictory direct-sword versus token-to-Marl documentation
   before changing rewards. The current two-step smoke and older 20-case
   fixture do not prove the full epic.

Maintain a small number of cohesive domain modules. Do not make the Lua bridge
or existing 1,200-line browser harness larger for every content exception.
Extract the next substantive responsibility when extending those files.

## Bounded tasks suitable for a less expensive model

These are prepared work packets, not tasks already delegated or completed.
Take one packet at a time. Each result must include evidence paths, exact
changes, focused verification and remaining uncertainty.

| Packet | Inputs and concrete output | Acceptance / stop condition |
| --- | --- | --- |
| SK dialogue directions | Compare the cached `raw-pages/shadow-knight-epic-quest-ee3595791b.wiki` and metadata with effective Duriek, Caradon, Marl and Gerot Lua. Restore missing directions in one small batch and update the review ledger. | Typed phrases and displayed response options must reach the intended response. Do not replace scripted faction gates individually. Stop and report a runtime option-discovery defect rather than adding an NPC-specific bypass. |
| SK hand-in accounting (initial packet completed) | Kurron's split 900pp requirement is repaired using the existing matcher, with shortage/exact/excess Go tests and a real UI debit check. The override corpus was checked for equivalent direct currency predicates. Further audits should include variable aliases and upstream effective scripts. | Preserve the shared matcher. Do not repeat the completed fix or invent global cash consumption. Full quest completion still requires combat/loot and subsequent steps. |
| Item/NPC dependency sheets | For 5–10 simple reviewed pages per batch, resolve every item/output/NPC/recipe/loot ID against the local DB and effective Lua. Record canonical IDs and actual missing records, not just name mismatches. | Read-only data audit first. Output a concise reviewed JSON/Markdown manifest with source paths and queries. No invented IDs or production writes. NPC 90187's level/HP is a flagged SK record to verify against P99, not a value to copy blindly. |
| Small continuous-chain fixtures | Use `testing/fixtures/quest-continuous-chain-smoke.json` as the contract example. Choose short delivery/exchange chains requiring no unimplemented effects. Derive requirements from the P99 page, not by copying current script outputs as the oracle. | Explicit initial inputs; no mid-chain grants or cash resets; exact output quantities and consumption; named GPU Docker run. Label the tested segment precisely. Keep fight/drop/UI assertions separate until actually exercised. |
| Velious review-scope repair | Inspect `content_exclusions.json` entries excluded under the older Classic/Kunark-only policy and the preserved cache. Produce a reviewed list of genuinely Velious pages and existing exclusions. | Reclassify documentation/ledger deliberately, preserving unrelated later-era exclusions. Do not blanket-enable quests, zones or all imported Velious-looking scripts. Runtime/data enablement is a separate reviewed change. |
| Evidence/coverage ledger cleanup | Compare `p99_audit` records and historical reports with current tests. Add precise evidence levels and open issues in notes: static, isolated hand-in, continuous segment, rendered playthrough. | Do not mark a page complete based on source execution, `activated`, generated API references, or a debug-defeated NPC. Preserve provenance and historical snapshots. |

All cache paths above are relative to `data/p99wiki-project1999-api-cache/`;
quest Lua paths are relative to `server/internal/quest/`. Read matching metadata
alongside raw wiki text. The cache is gitignored: never delete it as disposable
test output. Read `content_exclusions.json` and the importer to resolve effective
overrides rather than assuming the upstream same-name script is active.

## Batch completion checklist

1. Inspect branch/dirty state, current docs, effective source and local DB.
2. Record source page/revision, differences and the intended supported behavior.
3. Prove shared/runtime support before proposing content-specific code.
4. Change only the bounded packet; update ledger notes alongside content.
5. Run focused Go/Vitest checks first; real browser tests only through Docker.
6. Report exact scope tested and remaining blocked mechanics. Never weaken an
   assertion, silently grant missing intermediates or relabel an unimplemented
   effect as supported to make the batch green.

### Continued checkpoint: death loot and missing directions

The continuous Kurron test exposed two client boundaries missed by the earlier
incoming-hit check: GameEngine treated the incoming attack as manual melee and
cleared encounter tracking with AutoAttack off; a later manual join received a
duplicate init without the acknowledgement needed to clear its pending start.
Quest attacks now use `npc-attack` lifetime, independent of the melee toggle.
Duplicate joins acknowledge the existing runtime without resetting its actors.
`questCombatLifecycle.test.ts` covers acknowledgement and toggle independence.

`NPC:AddItem` persisted inventory was previously consulted by debug loot
validation only. Normal victory deleted the state before generating the corpse.
`quest_loot.go` now materializes that inventory before death/depop callbacks,
validates templates before marking the NPC dead, and includes it in ordinary
corpse/AutoLoot generation without a drop-rate multiplier. Inventory reads require
an exact owner/zone/spawn; type-scoped legacy progress must not clone physical
inventory across NPC incarnations. EQEmu's `zone/lua_npc.cpp` establishes that
`NPC:AddItem(item_id, charges)` adds one item with those charges, not that many
copies. The historical persisted `count` key is retained with its corrected
charge meaning; zero and unlimited charges are preserved. Focused Go tests
cover this conversion and reject missing actor identity/templates. Source:
https://github.com/EQEmu/Server/blob/master/zone/lua_npc.cpp

This is the inventory
present when death begins; adding new inventory inside a death callback is not
covered. Durable atomic world-effect delivery remains separate work.

Duriek's elixir/tome/letter objectives and direction to Lhranc, Marl's direction
to Gerot in Paineel, and Gerot's physical-head requirement are restored as
condensed P99 dialogue. `sk_directions_test.go` checks the meaningful objectives,
consumption and unchanged outputs. The local DB was refreshed with the canonical
quest importer; production was not changed.

The extended `quest-triggered-combat.spec.ts` now attempts real party combat,
exact-spawn loot receipt, carrying the earned letter across zoning and handing
it to Duriek. Initial armor/cash/level/skills/HP and three ordinary companions
are test setup; NPC HP and loot are not overwritten. The untouched local Kurron
has 28,750 HP; the first stable 180-second run reached 18% HP and fleeing.
The expanded time limit is 300 seconds for combat with Warrior/Rogue/Cleric.
The debug helper supports only those three synthetic classes; a proposed Monk
fixture was rejected and removed, not added to production to suit the test.
The full Kurron -> earned Letter to Duriek -> Duriek hand-in passed through the
hardware GPU Docker runner in 4.1 minutes, with one encounter initialization.
The final charge-argument, exact-identity and duplicate-init autoloot hardening
were subsequently reverified on a freshly built local server: hardware GPU
Docker passed both renderer preflight and the complete segment in 4.2 minutes.
This remains one optional epic segment, not the whole epic.
Logs: `/var/tmp/idlequest-kurron-chain-e2e-verified.log` and
`/var/tmp/idlequest-sk-current-kurron.log`.

The separate delivery smoke now starts with no items: Marl's prophecy dialogue
earns the seal before the existing Gerot -> Marl sequence. Verification of this
expanded smoke passed hardware GPU Docker in 13.9 seconds, separately from the
original seeded-seal checkpoint. No initial or intermediate items are granted.

### Caradon continuation: authored, not yet passing

`npm run test:e2e:quest-caradon-chain -- --reporter=line` is a content-audit
opt-in, outside normal mechanics discovery. It starts with only the Cell Key,
requires both released opponents to engage, kills/loots the exact Kyrenna spawn,
then carries her Blood to Marl for the Dark Shroud while retaining the Heart.
Initial player setup and travel are debug-assisted; NPCs and intermediate
rewards must not be fabricated. This is not certified coverage yet.

The current hardware-GPU run stops before the hand-in: Caradon is not alive in
this zone population. Local `spawn2.id=15892` / `spawngroupID=10186` selects
Caradon 39069 or elemental warrior 39000 with 50% weight each, respawn 1200s.
The target-by-type helper falls back to a catalog record without a spawn ID or
position; the test now explicitly rejects that fallback. Do not "fix" this by
granting Kyrenna's drops or silently skipping the failed precondition.
The test now uses `questSpawnCamp.ts` to kill the exact documented placeholder
through normal combat and wait for the natural respawn (up to three kills).
Its manual timeout allows those real 20-minute cycles; rendering pauses only
after combat is clear, during the idle wait. This helper is not yet certified.
Latest diagnostic log: `/var/tmp/idlequest-sk-caradon-nearby.log`.

The first camp run killed the actual elemental placeholder and encountered
two real social adds (Ikurenm 39037 and elemental harvester 39144). It failed
the no-active-combat prerequisite for pausing, rather than hiding those adds.
The helper now explicitly fights up to six active adds before pausing. The
follow-up `/var/tmp/idlequest-caradon-camp-adds.log` run is awaiting the ordinary
respawn of that already-killed placement; inspect its terminal result before
claiming the camp or Caradon encounter passed. Do not restart the local server
to reroll the placement. The first failed camp also corrected fixture-only
EQ X/Y ordering and the `/nav target` command-result expectation.

Separately, source inspection found `NPCProxy.AddToHateList` was a silent no-op
and entity-list `GetNPCByNPCTypeID` / `GetNPCBySpawnID` return the current actor
without resolving their arguments. These are unimplemented capabilities, not
safe tools for making a spawned NPC attack. Caradon currently captures only
his own `eq.attack`; Kyrenna has no effective local script. Her ordinary social
assist is not proven (the local NPC faction template IDs differ: 637 vs 79).
The registry now explicitly includes those three lookups and `AddToHateList`
(20 deferred APIs total). Normal compatibility behavior is unchanged but
captures report the missing capability; strict execution rejects it even on a
returned spawn proxy. Tests exercise every registered binding, and the static
selection report was regenerated. These diagnostics do not implement hate or
repair the misleading production lookups; both remain open work.
Full Go quest/world/exporter suites passed after these registry changes
(`/var/tmp/idlequest-quest-capabilities-final-go.log`).
An exact returned-spawn handle and actor-aware effect execution are a likely
shared next boundary; first verify the actual encounter rather than encoding
a Kyrenna-specific world exception.

Recommended next implementation: resolve the natural Caradon precondition,
then continue the encounter/death/loot chain and exact spawned-actor effects.

The natural camp run subsequently ended after 19.3 minutes: Caradon appeared
on the real respawn, accepted/consumed the key and attacked, while concrete
Kyrenna spawn 5000000000325 remained idle/unowned with no CombatInit. No
intermediate drops were granted. This confirmed the released-attacker defect.
The new `idlequest-authored/hole/Kyrenna.lua` expresses P99's attack-on-release
through the existing `event_spawn` -> owner-scoped `eq.attack` lifecycle. That
world event already supplies the exact newly created actor and checks its
owner/instance; no type-lookup or NPC-ID exception was added to world code.
This is explicit quest content policy, not general native KOS AI or a claimed
implementation of the deferred hate APIs. Strict Go capture tests pass.

The terminal camp allowed a normal local quest import and a fresh-server
restart to load Kyrenna's previously cached-missing handler plus the new Go
dialogue logic. The restart was for implementation changes, not repeated
lottery rerolls. The fresh local DB row is enabled and contains the expected
spawn handler. Reverify the chain; its bounded natural camp remains mandatory
if the next population selects a placeholder. No production change occurred.

### Nested dialogue checkpoint

The opt-in `TestAuditOverrideDialogueShapes` parses all 1,231 override Lua files
(965 named say handlers, no parse failures or top-level assigned handlers).
Two contain nested literal message conditions: Madame Serena and Runethar
Hamest. This is an override-source inventory, not an enabled-DB or whole-upstream
certification. Log: `/var/tmp/idlequest-dialogue-shapes.log`.

Madame Serena requires both `follow` and a deity phrase. Discovery previously
offered the outer `follow` but could not discover the working deity responses.
The shared probe now composes ancestor/child literal phrases, avoiding duplicate
substrings, and traverses ancestor gates inside the isolated preview. It still
stops before executing the candidate's response body; its copy, IO restrictions,
total deadline and 64-candidate cap remain. The VM, not phrase concatenation,
decides whether the composed phrase reaches its intended branch.

Focused tests prove `follow tunare`, `follow marr erollisi`, and
`follow marr mithaniel` reach the actual Serena replies, plus nested level gates
and discarded ancestor side effects. No NPC-specific dialogue override was
added. The live camp server was not restarted for these Go edits; rendered
dialogue verification must wait for that running test to finish. Dynamic/helper
phrases, meaningful-response validation for routing-only parent branches and
post-response inventory projections remain open.

Follow-up: routing-only message prefixes are now excluded from inferred options
when their bodies contain only further choices, with no statements of their
own. Serena's bare `follow` is omitted; `follow marr` remains because its actual
fallback asks which Marr. A nested level-gate regression proves a routing prefix
does not advertise entry around an ineligible leaf. This is structural routing
validation, not proof that every arbitrary script statement produces dialogue.
Focused and full Go suites pass; new live-server browser verification is pending.

`quest-dialogue-discovery.spec.ts` now also has a Serena scenario that opens the
dialogue with the real H key and clicks three displayed response spans. It
checks both reply packets and visible reply text. This new browser scenario is
authored, not yet run: the camp process still owns the current server lifetime.

Fresh-server verification subsequently passed: GPU preflight, existing Lhranc
dialogue regression and Serena's three real response-option clicks all passed
in 23.9 seconds (`/var/tmp/idlequest-dialogue-click-e2e.log`). Full Go
quest/world/exporter suites also passed (`/var/tmp/idlequest-kyrenna-full-go.log`).
This proves these dialogue interactions, not the full epic or all NPC dialogue.
The Caradon chain is being rerun separately with the imported Kyrenna handler;
use `/var/tmp/idlequest-caradon-kyrenna-enabled.log` for its result.

That run proved both exact actors receive quest-initiated CombatInit, but
stopped on an optional scene ownership field that was not populated yet.
The authoritative ownership assertion now uses the exact-spawn init packet,
while separately requiring client active-combat state. A subsequent attempt
hit the same scene-loading boundary when navigating immediately. The fixture
now waits (15s maximum) for the real entity-pool position and targets the exact
loaded spawn, rather than a catalog/type target. Current continuation log:
`/var/tmp/idlequest-caradon-scene-ready.log`. Combat completion, earned drops
and Marl's shroud remain unverified until that run succeeds.

### NPC mana boundary exposed by the continuous encounter

The scene-ready run ended after 5.3 minutes without Kyrenna dying. She remained
in melee range with 8,269/13,750 HP despite about 34,488 cumulative damage on
her hate entries. This is not evidence of a looting failure: no death/loot was
reached. Both NPCs had a runtime mana pool of 0/0. Local `npc_types` records
39069 and 39155 have `mana=0`, level 55 and WIS/INT 174.

EQEmu's `NPC::CalcMaxMana` treats database zero as an automatic base pool:
`(casting attribute / 2 + 1) * level`, with integer division, or the explicit
nonzero override for caster classes. `Mob::IsIntelligenceCasterClass` and
`IsWisdomCasterClass` include hybrids and their guildmaster counterparts.
Sources: https://github.com/EQEmu/Server/blob/master/zone/npc.cpp and
https://github.com/EQEmu/Server/blob/master/zone/mob.cpp (inspected September 5).
The existing full-mana affordability exception matches `zone/mob_ai.cpp` and
is retained; literal 0/0 made it permanently true for these imported casters.

The shared server model-to-combat conversion now resolves that sentinel and
selects INT/WIS in its query. Both named encounters therefore receive 4,840
base mana. All weighted and exact-ID combat retrievals use this boundary.
No database migration is appropriate: zero is valid source data. Runtime mana
bonuses remain separate. The local corpus contains 15,866 zero-mana caster
records, not necessarily all enabled or in-era, so this is not a quest-specific
exception. Actual healing spells in the failed run were not individually
recorded; unlimited affordability is confirmed independently by source.

Focused Go conversion tests cover caster/GM classes, explicit overrides,
noncasters, odd attributes and zero stats. Go DB-combat/combat/world suites
pass. A focused runtime test spends a finite pool and proves paid casts become
unavailable while free casts remain usable; the existing full-mana exception
test also passes. Logs: `/var/tmp/idlequest-npc-mana-go.log` and
`/var/tmp/idlequest-npc-mana-vitest.log`. The browser fixture now asserts the
actual authoritative 4,840 mana initialization before continuing the real
fight; the fresh-server rerun is pending. Do not claim the encounter passed.

That rerun (`/var/tmp/idlequest-caradon-finite-mana.log`) subsequently verified
the 4,840 mana init and real Kyrenna death in about two minutes, with both
14380/14381 in the authoritative LootGenerated packet. It failed at inventory
settlement: Heart was collected, Blood remained on the open, in-range corpse,
and seven inventory slots were free. This isolates a separate shared loot
identity defect, not an absent drop or inventory-capacity problem. The full
499-test selected runtime suite and typecheck also pass after the mana fix.

### Stable manual corpse-item identity

`loot all` sent array indexes 0 and 1 without waiting for each settlement.
After index 0 was removed, the second item shifted to index 0, making the next
request invalid. Rapid UI clicks or delayed no-drop confirmation could also
refer to shifted items. Corpse display slots were already allocated once at
death and preserved after removal; requests now use that authoritative slot
plus expected item ID. The shared service is used by commands and UI. No Drop
items now use this direct path without a confirmation dialog.

Server resolution rejects stale/repeated/wrong-item slots without falling back
to an index. Same-item copies have distinct slots. Pre-update clients retain
the old `itemIndex` meaning during mixed-version deployment; current clients
never send it. Deploy server support before serving the updated client. This
does not claim durable or cross-session atomic corpse settlement.

Focused Go tests cover removal, repeated IDs, stale/replayed identity, missing
identity and old-client decoding; client tests verify stable wire fields and
refusal to guess missing slots. The real Caradon chain still needs a fresh
server rerun after this change. No intermediate items were granted.

Next supporting-content finding (read-only, not repaired): Ghost of Glohnor
39082 has chance 0 in both local spawn groups 10240 and 10260, with positive
competitor weights, so neither ordinary placement can select him. Cached P99
NPC page `npc-pages/ghost-of-glohnor-fa644e0f37.wiki` (August 12, SHA256
fadacd172954735c0810c6d9a38e5bd012006c2bc4f282941a3ffc8423889ccd) describes
fallen-erudite placeholders. Verify the source/data cause and intended spawn
placements before restoring this next dependency; do not bypass it with a
debug spawn. Existing farming coverage tooling already recognizes this
positive-weight/zero-weight distinction and should be reused where practical.

The stable-slot fresh-server run is `/var/tmp/idlequest-caradon-stable-loot.log`.
It selected the real elemental placeholder and is handling its social adds;
do not restart the server to reroll the natural camp. Full relevant Go suites
pass (`idlequest-quest-mana-loot-full-go.log`), focused loot/command client
tests pass (10 tests), and typecheck passes. The full chain is still pending.

### Next Lhranc content decision: source review, not implemented

The cached epic page's quick and short walkthroughs say to loot the sword,
while its long dialogue section describes a coin-to-Marl ending. The separate
P99 NPC page identifies the direct-drop actor as EMU ID 90093 and lists the
sword as an always drop. Its preserved August 12 snapshot is
`npc-pages/lhranc-b73fa72691.wiki`, SHA256
9deb5f0ab838b59c943d2065fb21253e28f121f4b4787fd35b9069963e90114a.
The current P99 NPC page still agrees (checked September 5):
https://wiki.project1999.com/Lhranc.
In https://project1999.com/forums/showthread.php?t=143155, March 14, 2014,
post 10, player getsome explicitly distinguishes the later coin revamp from
the server's direct sword drop. This is player corroboration, not a developer
statement; nilbog's separate post there discusses stats/faction only.

Local data contains classic-looking 90093 (level 60, 19,000 HP, loot table
87760), ghost 90221, and later #Lhranc 90187 (level 70, 30,000 HP, loot table
103878). The effective upstream-derived hand-in currently spawns 90187, grants
token 14384, and its death spawns Marl 90189. The evidence now favors restoring
the direct-drop path instead of leaving the wiki conflict indefinitely open.
Before implementing: verify actual sword loot linkage, actor-form/proc data,
effective same-name script routing and existing holders of the token. Do not
blindly copy the NPC page's contradictory Warrior field versus Shadow Knight
description, or invent "nearly every hit" proc constants. No Lhranc gameplay
change has been made at this checkpoint.

### Static spawn dependency checker

The new read-only `cmd/audit-quest-spawn-dependencies` consumes the actual
content-filtered zone pool. `db/zone/spawn-selection.go` mechanically extracts
the live weighted selection rules; the population service and checker now use
the same decision model. No spawn odds or content were changed. Tests enumerate
every weighted roll and compare observed counts with the reported probabilities,
including disabled zero entries, duplicate IDs, missing NPC data, negative
weights and the preserved first-valid all-zero fallback. The audit refuses to
certify an unordered multi-NPC fallback as a reliable target.

Actual local output (`/var/tmp/idlequest-sk-static-spawn-dependencies.log`):
Caradon is selectable at 50% on placement 15892; Glohnor has 0% on 15964 and
15992. Kyrenna has no eligible static entry, as expected for a quest-spawned
actor (not a defect); keep her out of a static-dependency manifest. The command
exits nonzero when an explicitly requested static dependency cannot be proven.
Go zone/world suites and command build pass. This new extraction is not loaded
in the browser camp's server: do not restart that lifetime until its real
respawn run finishes. See the workflow document for the reusable command.

### Glohnor restoration migration prepared, not yet applied

Migration `134_restore_glohnor_quest_spawn_weights.sql` restores only the two
existing zero-weight Glohnor entries. It uses 33 and 20 respectively, filling
the unused shares of the existing 100-weight groups whose competitors total
67 and 80. This is an explicit playable IdleQuest approximation, **not a
claimed exact P99 rate**. The current cached NPC page documents placeholders
but no rate; an older May 2016 P99 forum table lists the same two coordinates
and a different rate. Existing positive corrections, all competitor weights,
locations and respawn timers are preserved. Do not automatically enable other
zero-weight NPCs. The provenance of the original disabling is not established:
the repository migration history search found no Glohnor weight change.

The migration checks that both exact NPC/zone/placement mappings exist, updates
inside a transaction, and rejects a nonpositive postcondition. The deployment's
required pre-migration backup is the rollback source. Its opt-in SQL test uses
connection-local temporary tables, not live game tables:

```sh
IDLEQUEST_E2E_CONTENT_AUDIT=true node scripts/quests/test-sk-content-migrations.mjs
```

Verified: both corrections, unrelated rows, idempotency, existing positive
values, failed-postcondition rollback and wrong-zone rejection. It has **not**
been applied to the local game DB or production, because the current browser
camp still owns the running server lifetime. After the camp terminates, apply
the local migration with a recorded preimage, check the actual spawn dependency
report, and rebuild/restart once to invalidate the cached zone pool. Then
extend the continuous shroud -> ghost -> real mummy -> earned head/wrappings
path without a debug spawn or replacement quest items.

Additional Lhranc evidence prevents a misleading replacement: 90093 is itself
spectral race 147 and has no current loot rows, despite the older NPC page's
EMU ID. The runtime-filtered static ghost is 90221, not 90093. Human 90187
already has a guaranteed sword drop from migration 061 (lootdrop 178706), plus
later-era imported loot and its token/Marl script. Thus the direct-drop problem
is not a missing sword row. The remaining correction must address redundant
token progression, level/HP, spell behavior and supporting loot data without
blindly swapping to 90093. Spell list 159 has Soul Devour proc 995/parameter75
and inherits casting list 9; the P99 NPC description says the human does not
cast normal spells. Revalidate all consumers before altering this list.

### Local rollout and Caradon completion checkpoint

The previous camp terminated after 20.8m: it killed the initial placeholder
and both social adds, then selected another placeholder on the normal respawn.
Its loot check incorrectly reused the first death's packet because a static
spawn keeps the same ID. `questSpawnCamp.observeKill` now captures a new receipt
boundary before each fight. That change is typechecked; the next successful
run did not need a placeholder cycle, so multi-cycle validation remains open.

With the old test terminal, the local server was stopped normally. Migrations
134 and 135 were applied and checksums recorded in the local migration ledger;
preimages are `/var/tmp/idlequest-sk-pre134-135.json`. Both are now immutable.
The earlier local ledger only records through 126; this work does not claim
127–133 were reconciled or reapply them. Production was not accessed or changed.
Canonical quest import and one rebuilt server loaded the new overrides. SQL
verification confirms both imported Lhranc sources exactly match their files,
human90187 has level60/HP19000/hits142–385, and list159 has parent0 while proc
995/parameter75 remains unchanged. Spawn audit confirms Glohnor is selectable
at 33%/20%. These data checks do not prove the full encounters.

New Lhranc overrides remove new token grants and the later death-spawned Marl
exchange, initiate owner-scoped combat, and remove the artificial two-hour
quest despawn timer. Existing #Marl handler/previously spawned actors and items
are not deleted; no outstanding token is converted into a free sword. The
ordinary imported human ID is preserved. Migration135 also removes the
later-era material loot group, not the existing guaranteed sword or other
NPCs' loot. Go tests exercise the real overrides, four-slot complete/incomplete
hand-ins, no free reward, owner attack and absence of later timer/Marl events.
The legacy final isolated fixture now expects direct corpse loot and names its
debug-defeat boundary explicitly. It is not proof of real final combat.

The fresh Caradon run **passed**, including GPU renderer preflight, in 2.1m:
`/var/tmp/idlequest-caradon-fresh-receipts.log`. The only initial granted item
was Cell Key. Both exact actors attack, Kyrenna actually dies, manual loot
collects Heart14380/Blood14381, and the earned Blood becomes Dark Shroud14377
at Marl while the Heart remains. Character setup/travel are debug-assisted;
no NPC, death or intermediate reward is fabricated. This closes the shared
mana/loot fixes for this segment, not the whole epic.

### Next shared runtime gap: innate NPC procs

`BuildNPCSpellData` loads cast entries only; it never sends
`npc_spells.attack_proc`/defensive/ranged proc metadata. Client
`runtimeNpcProcSystem.ts` handles buff-derived procs, but effective NPC stats
start with empty proc arrays. Therefore retaining Lhranc's database Soul Devour
does **not** prove it runs, and his final encounter is not complete yet.
Do not disguise this with an NPC-specific periodically cast nuke or re-enable
his ordinary SK spells. Extend the authoritative NPC payload into the existing
proc application pipeline with tested inheritance and correct rate semantics.

EQEmu `zone/mob_ai.cpp` inherits parent metadata and applies child values >=0;
attack procs use `AddProcToWeapon(spell, true, proc_chance)`. `zone/attack.cpp`
rolls permanent `PermaProcs[i].chance` as a direct percentage, not the Dex/delay
buff-proc formula currently used by our helper. Ranged/defensive semantics need
separate inspection. Sources: https://github.com/EQEmu/Server/blob/master/zone/mob_ai.cpp
and https://github.com/EQEmu/Server/blob/master/zone/attack.cpp.

### Permanent NPC melee procs: implementation checkpoint

`BuildNPCMagicData` now resolves immediate parent/child identity once for cast
entries and the independent `npcMeleeProc` payload. A child attack_proc=-1
inherits both spell/chance; zero disables the parent; a positive spell uses
the child's chance. Proc-only lists survive an empty cast-entry list. Missing
metadata/spells are diagnosed rather than replaced with a class-based guess.
The existing NPC proc executor handles the new source, retaining spell data,
resists, reflection, effects and death checks. Permanent chance is a direct
percentage, not Dex/delay or a buff rate bonus. Source `attack.cpp` gates NPC
procs on successful non-riposte hits, consistent with the ordinary current
NPC attack callbacks. No NPC-specific combat script was added.

Focused Go inheritance/error tests and the combat/world/quest packages pass.
35 selected Vitest tests pass, including actual CombatRuntime Soul Devour
damage with zero mana and no cast list, exact deterministic 75% selection,
companion-target execution, inactive/dead suppression and lethal-proc stop.
The first test iteration used the wrong test-unit assumption for resist
effectiveness (1 instead of the runtime's 100 percent); production was not
changed to accommodate it. Typecheck and canonical type generation pass.
Logs: `/var/tmp/idlequest-npc-proc-regressions.log`,
`/var/tmp/idlequest-npc-proc-go.log`, `/var/tmp/idlequest-npc-proc-typecheck.log`.

Read-only local audit finds 3,024 imported NPC records with an effective
positive attack proc; this is **not** an eligible-spawn or P99-era count.
No local npc_spells rows have a positive ranged or defensive proc. Those
families remain unsupported and must not be mapped onto direct percentage:
EQEmu adds 100 to their metadata rate modifiers, then scales a base chance;
defensive base chance uses attacker's delay and defender's AGI, not the
existing NPC buff-proc Dex helper. NPC ranged attack execution itself also
needs investigation before enabling ranged procs.

`test:e2e:quest-lhranc-encounter` is a new opt-in hardware-GPU final-segment
check. Four starting hand-in items and player setup are provided once; actual
ghost hand-in, human spawn/owner attack, source stats/proc, real death and
corpse sword acquisition must follow without debug spawn/death/reward repair.
It checks visible proc text but is not a full-epic acquisition playthrough.
The first fresh-server GPU run failed after 5.3m waiting for a corpse, after
the actual hand-in/spawn, no inherited cast list, correct proc metadata and
visible Soul Devour checks passed. This does not yet distinguish insufficient
test-party damage from a runtime defect. Its line-only reporter did not retain
the in-memory JSON attachment. The spec now writes a file-backed failure
snapshot and prints bounded 30-second HP/target/progress samples; the diagnostic
rerun is active. First log: `/var/tmp/idlequest-lhranc-real-encounter.log`;
rerun: `/var/tmp/idlequest-lhranc-real-diagnostics.log`. Do not claim a kill/loot
pass from the proc checks.

Separate source inspection found the raid-member branch in
`runtimeNpcAttackTickSystem` omits `tryNpcWeaponProcs`, unlike player/companion
branches. Close and test that boundary before claiming raid-target proc parity.
Do not modify the running browser's client runtime through HMR; wait for its
terminal result first.

The diagnostic rerun confirmed a fixture problem before its old loot timeout:
player maximum HP is 905, Rogue dies, then Warrior dies and active NPC IDs
become empty. Lhranc had 18,860/19,000 HP in the first sample. The test's
`debug player hp 100000` is **not** a max-HP boost: `combatService.debugSetPlayerHp`
explicitly clamps it to the existing maximum. The exact owned rerun session
was interrupted after that terminal encounter evidence (exit130); no browser
test remains running. The local dev server remains running from
`/var/tmp/idlequest-innate-proc-dev.log`. Do not claim that an NPC combat/loot
bug caused this wipe, or weaken Lhranc to make an underprepared group pass.
Next prepare an appropriately equipped/capable test group, verify its actual
stats before the hand-in, and fail promptly on encounter loss. Retain the
500-damage proc and real death/loot assertions. The final-segment test remains
unverified; this is not a full-epic pass.
