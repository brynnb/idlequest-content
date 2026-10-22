# Interim diagnostic snapshot, 2026-10-22 07:14 UTC

This snapshot is intentionally not green and is not the final source freeze. See receipt.json and run-status.json for exact commands and results.

- npm: 76 pass, 3 fail, 1 optional MySQL skip. Main behavior loading stopped before execution. Failures concern the admission ownership test, a stale support-review hash, and Mazziana source identity.
- Actual combined CLI: failed on a subsequently corrected unsupported upstream target.
- Baseline: all 36,496 files and 53 tables validated; immutable-baseline git diff empty.
- Exact-byte compilation: 8,884 of 8,885 scripts compiled. The only failure is the known disabled baseline Perl utility. All 816 proposed Lua sources compiled.
- All 45 declared row references resolve. The 33 missing literal occurrences are retained in eight disabled historical bodies, not newly added rewards. The later checker refinement is explicitly labeled post-snapshot.

Current fixes require the separate fresh final snapshot. These results are isolated/static checks, not live game, crafting, pickup, transaction, world activation or UI proof.
