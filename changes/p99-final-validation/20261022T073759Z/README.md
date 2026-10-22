# Diagnostic validation snapshot

This snapshot finished with two integration-test failures. Main behavior did not execute. Both defects were corrected later, and a separate snapshot must validate those new bytes.

Actual combined proposal validation, immutable baseline validation, standalone armor and Paladin cases passed. All 816 proposed Lua files compiled. The sole full-tree compile failure is the unchanged disabled baseline Perl utility. Reference checking qualified 33 unchanged historical missing literals across eight disabled sources; there are no new or active unresolved findings.

See receipt.json and run-status.json for exact boundaries, commands, fingerprints and log hashes. No live game or UI proof is claimed.
