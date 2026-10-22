# A–F static P99 review

All 223 formerly screen-only pages have manual records: 196 actual-quest candidates with partial source-facet comparisons, 10 excluded titles, 9 excluded mechanics and 8 reference pages. No record claims complete live, screenshot or natural acquisition parity. Classification-only records are not counted as quest-source reviews.

`findings.json` binds cached page evidence and effective source hashes to per-page facets. `ledger-records.json` is the exact-title partial-status merge sidecar. `manual-notes.json` distinguishes matches, discrepancies, proposals, adaptations and remaining unknowns. The baseline has not been edited.

## Validation boundaries

111 hash-bound proposed-source mocked scenarios and four unchanged source-normalization diagnostics passed in `runtime-diagnostic.log`. These use the actual item helper and normalized Lua with the strict scalar-only reward fixture. They are not live engine settlement or encounter proof. The synthetic five-available-item cases test the bounded loop, not a real five-slot trade. `fixture-override-audit.json` documents every override and retracts the earlier unsupported array-reward mock.

Recipe expectations are split among `recipe-expectations-additions.json`, `coldain-recipe-expectations.json`, `crusader-recipe-expectations.json`, `enchanter-recipe-expectations.json` and `supporting-recipe-expectations.json`. `recipe-row-evidence.json` preserves exact immutable rows and hashes. Structural recipes do not prove natural acquisition, crafting UI or settlement.

The large Bard, Cleric, Crusader, Druid, Enchanter, Coldain shawl and ring primary exchange graphs have explicit stage-level reviews. Coldain ring 10 is cross-linked to the independent numeric-title review. Unknown XP/odds, unsupported live lifecycle behavior, unexported forage acquisition, ambiguous placement and documented encounter adaptations remain explicit rather than guessed. Karn muffin cash/factions are now partially implemented by the coordinated A–M proposal; XP remains unknown.

## 32 A–F proposals

- p99-af-aegis-dialogue: Restore documented defend life instructions; preserve Rodcet Nife reply, predicates and every reward branch.
- p99-af-airbox-recipe: Enable exact ten Infected Rat Livers in Air Tight Box combine; preserve all other metadata.
- p99-af-bandit-sashes: Replace undocumented bronze armor reward pool with the18 P99-listed bronze weapon types. Preserve uniform-choice approximation; do not infer empirical odds or change XP/batch behavior. Honor up to four independent sash rewards per trade; return surplus and preserve letter branch.
- p99-af-brell-recipe: Enable exact four-component Holy Cask combine; preserve all other recipe metadata.
- p99-af-bronin-dialogue: Replace later Kiolna recipient advertisement with exact documented Bank Clerk instruction in both Bronin aliases. Preserve every exchange, attack and spawn behavior.
- p99-af-bug-recipe: Enable the existing exact six-component Bug Collection combine; preserve all other recipe fields.
- p99-af-cannibalize-recipe: Enable the exact P99-documented existing combine; preserve all other recipe fields and component/success/failure entries.
- p99-af-chalice-recipe: Enable the exact P99-documented existing combine; preserve all other recipe fields and component/success/failure entries.
- p99-af-chalice-shovel-pickup: Allowlist the documented existing Abandoned Orc Shovel pickup1658 only. Preserve imported placement and timer; the wiki/imported y-coordinate sign conflict remains unresolved.
- p99-af-cheslin-state: Prevent stale completed card flags from repeatedly granting rewards, preserve sequential hand-ins and historical persisted global Chrono key; leave random drop uncertainty untouched.
- p99-af-cleric-spirit-lifecycle: Spawn the Spirit from Shmendrik death even without Natasha; remove only her duplicate spawn responsibility and honor her documented combat exception at timed depop.
- p99-af-cromil-reward: Replace unsupported Flash of Light15201 with Spook the Dead15209 named by the P99 completion report. Retain unresolved conflicting Hammer of Wrath heading; evidence-selected correction, not full parity. Bone Chips branch unchanged.
- p99-af-crusader-ground-pickups: Allowlist exactly the two documented existing classic quest ground pickups. Preserve every ground row coordinate, timer and field.
- p99-af-druid-progression-dialogue: Restore exact documented progression instructions for Alrik, Foloal and both Ella aliases; preserve all shared Ranger/Druid item protocols and existing adaptations.
- p99-af-eestyana-note: Connect delivered note using local name/lore and Wolten output; reject distinct Drosco starter. Preserve every reward and unrelated handler.
- p99-af-enchanter-ground-timers: Set only three explicitly documented 24-hour Enchanter epic ground pickup timers to86400 seconds. Keep all coordinates, other metadata and allowlist rows unchanged.
- p99-af-erdarf-entry: Restore two documented Erdarf entry exchanges and four dialogue branches. Preserve upstream XP and conflicting acid-depop fallback explicitly; later chain remains incomplete.
- p99-af-forpar-dialogue: Accept the exact documented final-component phrase while preserving every existing reward and the unquantified missing XP.
- p99-af-frostbite-tonic: Accept good tonic instead of explicitly bad tonic; preserve all other event handlers, leave unknown faction/XP gaps explicit.
- p99-af-garadain-dialogue: Restore exact documented mission and ready instructions without changing any ring exchange or encounter condition.
- p99-af-giz-dialogue: Add documented Tani sent me dialogue alias in both Giz sources; preserve existing handlers and avoid invented class gates or attack behavior.
- p99-af-greenmist-factions: Correct only three explicitly documented faction identities; preserve unverified +20 magnitudes, XP, eligibility and unrelated branches. Also materialize both documented multi-item rewards explicitly because the exported QuestReward bridge ignores items arrays.
- p99-af-jemoz-faction: Correct documented Dismal Rage faction target for both head and helm turn-ins in both aliases; align legacy head to exact three scrolls and helm to documented Minor Healing plus canonical unverified scroll-pool fallback.
- p99-af-nekexin-respawn: Set only the documented Nekexin two-hour respawn to7200 seconds. Verified group11394 contains only NPC93043; preserve placement, variance and unrelated encounter adaptations.
- p99-af-noxhil-phrase: Accept the exact P99 collecting fire beetle eyes phrase alongside the retained local alias. Preserve every reward, faction gate and unrelated Scroll of Ghan branch.
- p99-af-red-wine: Honor explicit P99 up-to-four red wine offerings with independent per-item faction andXP. Preserve70gold branch priority and return surplus/unrelated items. No unbounded stack conversion.
- p99-af-sky-upgrades: Restore eight documented legacy reward upgrades and correct Enderbite to Black Nebulous Sapphire. Preserve existing complete-test rewards and other handlers; ambiguous Truwian upgrade and return-book identities remain unresolved.
- p99-af-stormhammer-recipe: Enable exact two distinct emerald shards in Cracked Emerald combine; preserve every other metadata field.
- p99-af-taldrik-note: Require documented Note to Taldrik with all three drinks in Oasis and South Ro. Preserve all other branch behavior and refunds.
- p99-af-tash-recipe: Enable the exact P99-documented existing combine; preserve all other recipe fields and component/success/failure entries.
- p99-af-vaurk-exclusion: Suppress only explicitly post-Velious knife exchange and its advertisement; preserve NPC activation and return every offer.
- p99-af-wafer-recipe: Enable existing exact two wings, mud crabs and bone chips in Component Mortar combine. Preserve every other recipe field.

The shared Lady Gelistial dialogue refinement is included in the existing flavor proposal. Shared-actor and recipe ownership was coordinated to avoid duplicate overlays. All proposals remain subject to the parent integration and comprehensive validation.
