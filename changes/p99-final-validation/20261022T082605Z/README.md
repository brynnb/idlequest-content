# Final frozen-input validation

Qualified pass for the exact inputs bound in receipt.json. npm: 88 passed, 0 failed, 1 skipped (real MySQL round-trip test). All 2,530 central scenarios passed: 2,171 proposed, 264 baseline verifications and 95 reproductions. All 816 proposed Lua sources have hash-bound behavioral coverage and compile. Separate flavor, armor and Paladin cases overlap and are not additive.

The actual combined CLI validates 896 rows and 817 sources. Immutable baseline validation passes 36,496 files and 53 tables. The full 8,885-source compile retains one unchanged, disabled Perl utility incorrectly named .lua; its raw failure is preserved. Reference validation retains 33 historical missing literals in eight disabled sources, with zero new or active unresolved findings. This is not a zero-missing-reference claim.

No live game, database settlement/rollback, crafting, pickup, world activation, persistence or UI proof is claimed. See exact commands/log hashes in run-status.json, input fingerprints, proposed-source-proof.json, and limitations in receipt.json. Prior diagnostics remain historical.
