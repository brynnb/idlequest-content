# Perl conversion backlog

The old July Classic/Kunark zero-backlog report is superseded. Use the current
Classic-through-Velious scope in `server/internal/contentscope/p99_zones.json`.
Zone inclusion is for audit only; it does not enable any content.

Run from the game repository root against the local development database:

```sh
node scripts/quests/audit-perl-conversion-backlog.mjs --json /var/tmp/quest-perl-items.json
node scripts/quests/audit-perl-no-item-backlog.mjs --json /var/tmp/quest-perl-events.json
node scripts/quests/quest-status.mjs --json /var/tmp/quest-status.json
```

The October 2, 2026 run found 209 item-bearing Perl candidates with all referenced
items available, 157 candidates with missing item references, and 372 without
detected item references (234 classified for review). These are source candidates,
not confirmed missing P99 quests. Match exact NPC identities/aliases and runtime
availability before implementation. Missing items require dependency review, not
automatic exclusion; heuristic later-era classifications require P99 evidence.

The first restoration batch is the 42 Thurgadin, Kael and Skyshrine class armor
quest pages. Their shared recipe pattern should use existing item settlement
helpers. Complex ring/shawl events follow after shared mechanics verification.

See `docs/p99-quest-parity-plan.md`, `docs/quest-audit-status.md`, and the canonical
`content_exclusions.json` ledger for current scope, evidence and remaining work.
The original report remains available in Git history; do not use a content-repo
copy of it as the current conversion checklist.
