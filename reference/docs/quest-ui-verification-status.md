# Real-UI quest verification

This replaces natural acquisition/camping as the current verification scope.
Ordinary spawn/loot data is trusted. Seed prerequisite items, currency, character
and travel; use actual UI for dialogue, Give, Combine, and check real outcomes.

## NPC interaction capabilities

Quest replies expose `hasDialogue` and `hasTurnIn` independently. Hail opens
the existing quest window when either is available; Give Items is enabled only
for a successful reply with an `event_trade` handler. This advertises a hand-in
interface, not acceptance of any particular offer. All transaction, actor,
inventory and quest prerequisite checks still run on the server. The sidebar
includes both kinds under **Quest NPCs**. Hails refresh capability/availability
even with dialogue history; stale target, spawn, zone and character replies
cannot reopen the window.
Refreshed info after a completed hand-in also retains its successful status and
capabilities, so another Give does not require resetting the conversation.

Focused browser coverage: `debug-real-quest-interaction.spec.ts` (Docker debug
runner, `IDLEQUEST_REAL_GAME_E2E=true`). It uses Ghanlin's actual starting note
without injecting prerequisites or issuing debug quest commands. See the
Crimson Hands entry in `quest-audit-review-notes.md` for P99 evidence and the
remaining item-template discrepancy.

## Shared runner

All fourteen `npm run test:e2e:<class>-epic` entry points now select these
real-UI class suites through GPU Docker with one worker. Use `shadowknight`
for SK. They no longer select `debug-real-quest-flow.spec.ts`; historical
JSON/debug fixtures remain source/ID references, not UI proof. For example:

```bash
E2E_APP_URL=http://127.0.0.1:5189 npm run test:e2e:shaman-epic -- --reporter=line
```

Use the actual ready test-stack URL, not a remembered port. The entry-point
regression is `node --test scripts/testing/epic-ui-entrypoints.test.mjs`.
Run `npm run typecheck:quest-e2e` after changing the shared fixture or class
records. It checks all14 epic specs plus the Give UI spec and their imports,
using the application compiler settings. Normal `npm run typecheck` alone
does not include `testing/`. This is static checking, not a browser test.
Other historical recipe/debug audit commands have not been reclassified as
real-UI evidence by this change.

`testing/helpers/questUiScenario.ts` composes the existing Give-window helpers.
`questGiveUi.ts` now uses normal Playwright clicks/keyboard input, including the
currency quantity dialog. It no longer silently funds currency while staging,
dispatches synthetic inventory clicks, or repeatedly clicks while awaiting an
inventory update. Input funding remains explicit fixture setup.

Add ordinary quest coverage as short `QuestUiScenario` records registered with
`defineQuestUiTests` from `testing/helpers/questUiTest.ts`, not another bespoke
runner. SK records remain in `testing/e2e/quest-ui-scenarios.spec.ts`; Cleric
records live in `testing/e2e/quest-cleric-ui.spec.ts` using the same lifecycle.
Class is a suite setup parameter. Scripted-death cases now default to the
user-approved **Test Quest Strike**: click the real test-only UI button during
normal combat, then observe the server corpse and scripted consequences.
No cast preparation or current/max-HP changes are needed. Explicit spell/melee
finishers remain available for separate ordinary-combat regressions. `dialogue`
contains visible choices and response fragments; `items`/`currency` are offered
through Give; `rewards` describes the exact inventory delta; `spawns`,
`despawns`, and `combatNpcIds` assert actual actor changes. `kind: "combine"`
uses the bag UI. `defeat` is reserved for a short scripted encounter, not a
source-farming loop. `setupNpc` only supplies missing prerequisite presence,
never the expected spawned consequence.

`eventResponses` verifies visible signal dialogue before a fight. Nested
`defeat.spawns` / `defeat.combatNpcIds` verify new identities created after the
actual death, distinct from hand-in spawns. An empty `defeat.lootItemIds` asserts
the server death receipt without opening ordinary loot. See
[Cleric step checklist](cleric-epic-ui-verification.md) for coverage and limits.

Warrior coverage uses the same registration and bag UI; `setupItems` supplies
the retained Red Scabbard separately from consumed components. No finishing
spell is required for suites without scripted fights. See the
[Warrior checklist](warrior-epic-ui-verification.md) for all16 verified steps.

With the local test-mode stack ready, run through the GPU Docker pipeline:

```bash
IDLEQUEST_REAL_GAME_E2E=true npm run test:e2e:docker -- testing/e2e/quest-ui-scenarios.spec.ts --project=chromium --workers=1 --reporter=line
```

This task uses `E2E_APP_URL=http://127.0.0.1:5188` for its separate mechanics
stack. Do not point these setup-mutating tests at production.

## Verified results

- PASS (September 9, 2026): Lork returns either incomplete ambassador heart,
  including a heart with an unrelated item. Three normal Give scenarios plus
  GPU preflight passed in 19.7 seconds; inventory deltas and visible reminder
  asserted and rendered result inspected. Complete-set reward behavior is
  Lua-test validated. `testing/e2e/quest-incomplete-handin-ui.spec.ts`.
- PASS (September 9, 2026): Ton's High Keep mail alone, Kelethin mail alone,
  both deliveries together, and mail plus an unrelated item through normal
  Give clicks. Four scenarios plus GPU preflight passed in 50 seconds. Exact
  inventory deltas and response text are asserted; the rendered both-mail
  result was inspected. `testing/e2e/quest-mail-ui.spec.ts` reproduces this;
  `captureSuccess` captures results before the shared runner camps out.
  [Audit and scope](quest-handin-alternatives-audit.md). Local only.
- PASS: Duriek's Letter, Cough Elixir, Dusty Tome, and four-weapon hand-ins;
  Teydar's sheath hand-in; Caradon's key hand-in creating a new Kyrenna actor.
  Normal Give clicks, exact inventory deltas (including no unexpected rewards),
  and visible responses verified. `/var/tmp/idlequest-real-ui-seven.log`:
  six cases plus GPU preflight passed; Smaka failed on an ambiguous selector.
- PASS: Smaka payment through the actual wallet quantity dialog and Give UI,
  1000 platinum consumed and elixir received. Selector now scopes the wallet
  to the quest panel. `/var/tmp/idlequest-real-ui-smaka-scoped.log`: case plus
  RX9070XT preflight passed in11.7s.
- Root cause repaired: ZoneSpawn serialized instance0 with `omitempty`, while
  the client correctly required an explicit matching scope for quest spawns.
  Server now emits instanceId0. Wire regression and seven world-event unit
  tests pass. Failed reload workaround removed before verification. The two
  representative cases passed together after the fix:
  `/var/tmp/idlequest-real-ui-instance-fixed.log` (29.6s with GPU preflight).
- Current task-owned mechanics server: session64774, HTTP18081/WT14434;
  Vite5188. No acquisition-server restart or production changes.
- PASS: Gerot's Seal and Head exchanges; Marl's Note, Blood, and Wrappings
  exchanges; Glohnor's Shroud hand-in spawning the mummy and removing the ghost;
  Lhranc's final four-item hand-in spawning his mortal form.
  `/var/tmp/idlequest-ui-remaining-first.log`: seven hand-in cases plus GPU
  preflight passed. Two dialogue cases failed on an incorrect button locator;
  the actual response choices are clickable spans. Corrected clicks are being
  checked separately, not counted as passing here.
- PASS: Kurron's seek/worthy/agreed/mission choices and resulting attack;
  Lhranc's curse/cure choices; Marl's will/prophecy choices and seal reward.
  `/var/tmp/idlequest-ui-dialogue-retarget.log`: these three cases plus preflight
  passed. Soulcase initially failed because its window covered the inventory.
- PASS: Soulcase obtained through Knarthenne's dialogue, actual bag opening,
  mouse drag, Heart placement and Combine produce Heart of the Innocent and
  consume both Heart and Soulcase. Expanded Marl, Duriek, Smaka, Teydar and
  Caradon dialogue also passed, as did Caradon's attack and Lhranc's ghost
  removal/mortal attack. `/var/tmp/idlequest-ui-expanded-dialogue.log`: seven
  cases plus preflight passed in 1.5 minutes.
- PASS: the additional short Kurron/Lhranc death-and-loot assertions.
  These are not long encounters: ten HP, trained fixture, real Lifedraw gem
  click with the existing test-mode landing override. Observe the real server
  corpse receipt and loot through the normal UI. Prior attempts watched a
  live-actor list after death or let melee pursuit/resist RNG obscure the quest
  result; those are not passing receipts. The corrected pair and GPU preflight
  passed in `/var/tmp/idlequest-ui-final-boundaries.log` (56s).

## SK interaction checklist

All rows below passed the combined real-UI run:
`/var/tmp/idlequest-ui-complete-suite.log` — **18 scenarios plus GPU preflight,
19 passed in 4.3 minutes**. The final targeted rerun also passed with the extra
Kyrenna attack assertion and narrower loot-window selector:
`/var/tmp/idlequest-ui-final-exact-actors.log` — **three scenarios plus GPU
preflight, four passed in 1.2 minutes**. No in-scope SK interaction is left
failed or untested. These runs were serialized on the RX 9070 XT Docker runner.

| Step | Real UI/result covered |
| --- | --- |
| Optional Kurron opening | Seek/worthy/agreed choices; three armor pieces and 900pp consumed; mission choice triggers attack; short fight and Letter looting |
| Optional Letter to Duriek | Letter consumed; apprentice/replacement response |
| Optional Smaka | Cough-elixir choice; real 1000pp quantity dialog and Give; Elixir received |
| Optional Elixir to Duriek | Elixir consumed; search directions |
| Optional Tome to Duriek | Tome consumed; research response |
| Teydar's Sheath | Decrepit-sheath choice; three ingredients consumed; Decrepit Sheath received |
| Duriek's Corrupted Ghoulbane | Four direction choices; three weapons plus Sheath consumed; Corrupted Ghoulbane received |
| Optional Lhranc story | Curse/cure choices and responses |
| Optional Marl story/Seal | All eight available story choices; Seal received |
| Optional Gerot Seal | Seal consumed; Note received |
| Optional Marl Note | Note consumed; visible scripted response |
| Knarthenne/Soulcase | Heart dialogue gives Soulcase; real inventory and Combine consume Heart of Kyrenna plus Soulcase; Heart of the Innocent received |
| Caradon's Cell Key | Who/where choices; Key consumed; exact new Kyrenna spawned; both Caradon and that Kyrenna attack |
| Marl's Blood hand-in | Blood consumed; Dark Shroud received |
| Ghost of Glohnor | Shroud consumed; exact mummy spawned; ghost removed |
| Gerot's Head hand-in | Head of Glohnor consumed; Head of the Valiant received |
| Marl's Wrappings hand-in | Wrappings consumed; Will of Innoruuk received |
| Lhranc ending | Four final items consumed; ghost removed; exact mortal Lhranc spawned and attacks; short fight and Innoruuk's Curse looting |

Ordinary acquisition is deliberately **not tested**: Darkforge armor inputs,
ratman Tome, Ghoulbane, Soul Leech, Sky Blade, Rharzar Spine, ashenbone Hide,
Enchanted Platinum Bar, mimic Key, Kyrenna Blood/Heart, mummy Head/Wrappings.
Their inputs are seeded, not camped. This does not certify the world population,
drop rates, rare spawns, a full naturally acquired character chain, or combat
balance. Always-ally quest faction behavior remains intentional and unchanged.

The local P99 cache's Shadow Knight Epic Quest checklist is the step source:
`data/p99wiki-project1999-api-cache/raw-pages/shadow-knight-epic-quest-ee3595791b.wiki`.
It identifies the Letter/Tome opening as optional. No later token/Marl ending
is substituted for P99's mortal Lhranc/sword ending.

Kurron's imported ordinary loot also has a 44.444% Letter entry. Consequently,
one corpse alone cannot prove the scripted guarantee. The deterministic
`TestKurronRequiresAndConsumesCashWhilePreservingExtraHandins` checks the real
Lua adds a Letter only after valid payment; `TestQuestNPCInventoryBecomesGuaranteedLoot`
proves that added inventory bypasses the ordinary random roll. Both pass in
`/var/tmp/idlequest-ui-npc-loot-unit.log`, alongside the actual UI/death/loot run.

Prior command-driven receipts remain useful server-mechanics evidence, not
proof of normal UI clicks. This checklist is based on the new real-UI suite.

Additional verification: typecheck passed (`/var/tmp/idlequest-ui-final-types-verified.log`);
instance-scope wire and dialogue discovery tests passed
(`/var/tmp/idlequest-ui-focused-go.log`); seven world-event controller tests
passed (`/var/tmp/idlequest-ui-spawn-regressions.log`). Verification was completed
on `codex/quest-chain-completion` before the user-requested checkpoint commit;
nothing was pushed or deployed.
