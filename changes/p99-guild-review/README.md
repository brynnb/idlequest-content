# Guild Summons substantive review

Scope: the **79** Guild Summons pages previously classified `branch_facets_only`, not the whole 1,135-page P99 corpus. Every complete cached quest page and relevant canonical/alias Lua body was read; historical `reviewed` labels were not treated as proof. All current root/nested proposals were inspected using exported `findProposals`.

## Result

- **79** per-title substantive source reviews, **93** canonical/alias bindings.
- **9 dialogue-only Lua corrections**: Seloxia, Mespha, Gahlith, Datur, Sragg, Leraena, Depnar, Runethar and Belious. Player names are dynamic, obvious wiki typos are normalized, and reward/eligibility/activation behavior is preserved.
- **1 book-only correction**: Tobon's note item18774 maps by `filename=AKAWizGM01` to books3150. Its non-navigation prose now follows the cached page. `books` has manifest primary key `id`; no item row is edited.
- **102 isolated Lua scenarios passed**: 93 guild branches plus9 documented-dialogue checks. Empty/unrelated offers, one-note consumption, extras, duplicate notes, repeat rewards and retained values are checked. Baseline reproductions are explicitly labelled. These are **not game-runtime, character-creation, population, settlement, persistence or UI tests**.
- Every title has a note item, matching reward item, note book, starting-item row, NPC row, zone-weight candidate and positive spawn candidate in a relevant source zone. NPC `exclude`/`isquest` flags are recorded, not interpreted as proof of live reachability.

## Artifacts

- `coverage.json`: per-title facet conclusions, corrections, discrepancies, unknown values and intentional adaptations.
- `evidence.json`: exact cached-page hashes/URLs; baseline, proposed-source and proposal hashes; full relevant guild branch/helper excerpts; immutable support-row locations, raw-line hashes and file hashes. NPC-page references supplement availability evidence; they do not certify every NPC statistic.
- `ledger-records.json`: conservative `partial` records for parent integration.
- `manual-notes.json`: individual substantive observations.
- `proposal.json`: nine Lua/quest-row edits, preserving existing source ownership.
- `tobon-book-proposal.json`: one verified books-row edit.
- `runtime-assertions.json`, `runtime-receipt.json`, `runtime-receipt.log`: hash-bound isolated test cases and successful receipt.
- `validation.json`: local source/row/hash consistency and proposal merge check; full CLI validation belongs to the parent.

## Remaining uncertainties and preserved behavior

All79 pages show experience and faction directions but do not supply exact XP/faction magnitudes. Retained values are implementation values, not measured P99 parity. No page specifies cash; no guild branch awards nonzero cash, but omission alone does not prove a P99 zero.

Datur's guild branch lacks XP despite documented presence. The retained upstream Perl also has no XP magnitude, so no number was invented. This is an explicit reward-parity block.

Kylan's unusual Rogues/Shadowed Men faction block and Opal's duplicate faction entry remain unresolved under the documented prior decisions. Kaglari's additional Frogloks faction loss is not listed on the page. Ebon Mask244 and Hall of the Ebon Mask5006 are distinct local rows; Eolorn's actual primary faction is244, so no guessed remap was made for Eolorn, Mater or Margyn. The fresh comparison includes plural `standings` lines and expands Perrir's helper function, both missed by the earlier branch-only extraction.

Welno's supported local NPC alias, Maesyn's omitted unsupported trades/referral text, Caskin's later-era exclusion and friendly item-based eligibility remain intact. Condensed navigation, wiki pronoun/header contradictions and the Spurned robe-versus-tunic prose conflict are explicit per-title residuals. No unsupported class/race/deity restrictions or new starter assignments were added.

No baseline source, table, manifest or policy file was changed; all edits remain proposals. No commit, push or PR was made by this worker.
