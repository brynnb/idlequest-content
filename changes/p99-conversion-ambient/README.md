# Ambient and lifecycle closure

21 new Lua bodies from the exact 34-key assignment. No NPC, spawn, path, item,
reward or enabled-policy changes. Two bodies retain animation requests that the
current runtime intentionally ignores. This is not a live-playability claim.

`closure-review.json` records every original source hash, disposition, exact
identity, cached P99 evidence, outcome and source-bound test names. Twelve rows
remain concrete ambient/world integration limitations; Soulbinder Cubnitskin is
excluded with positive post-P99 era evidence. Ritap/Sojan were reviewed as direct
dependencies but not changed. No eighth-Shawl reward branch was introduced.

## Connected patrol adaptation

Ulfur's four independent dialogue branches and waypoint15's twelve immediate
signal0 requests remain complete. New `event_spawn` starts the existing grid30,
not an invented path. Its 24 coordinates and pauses are bound to exported data.
Current implementation admits a circular public route, persists its cursor and
callbacks, rejects a second active route for the same lifetime, and settles
immediate public signals to distinct existing actor lifetimes. Actual navigation,
bootstrap and multiplayer behavior still require live testing.

Seven guard receivers already existed in the earlier Velious flavor proposal.
They are **not seven new conversions**. This review corrects an initial baseline-
only diagnosis of missing receivers. Only `-- actors: world` was added to those
seven existing files and their owning proposal hashes; original signal emotes
and return-all trade handling are unchanged. See `guard-scope-updates.json` and
`connected-overlay-evidence.json`.

## Runtime evidence and limitations

The related current implementation was inspected privately; its source and
repository provenance are not redistributed. Public upstream signal-unit
provenance is in `signal-units.json`. Compatibility conclusions cover actual
persistence and dispatch rather than only Lua capture:

- World timer settlement commits durable state before delivery.
- Public MoveTo is restricted to actors without assigned native patrols; all 11
  councilor spawn identities satisfy this. Legacy court senders remain partial.
- Public delayed signals and fallback public spawning are explicitly rejected.
- Public grid-start and callback delivery exist, but public grid-stop does not
  pass the current settlement admission. NPC-to-NPC following is also rejected.
- Proximity registrations are persisted per character and delivered to the
  moving owner's script. Captive retains this engine adaptation without adding
  a spawn or claiming natural activation.
- DoAnim/SetAppearance are no-ops. Corrith/Sirchthain retain requested animations;
  mocked invocation is not rendered animation evidence.
- Perl signal delays are already milliseconds. Official pinned EQEmu
  QuestManager source distinguishes them from second-based `settimer`.

Aldikar's maintained clock adaptation supersedes its old trigger leg. Current
published maintained Aldikar adaptation explicitly does not change other royal schedules. Dain's
maintained ring exchanges are preserved, not used to claim its omitted legacy
movement is complete.

## Verification

`runtime-assertions.json`: 127 isolated, source-hash-bound cases, including
connected receiver order and an absent-recipient model. The model is not an
executed persistence/rollback test. `behavior.test.mjs` also binds identities,
all original hashes, source/proposal hashes, exact grid policy, and the seven
header-only receiver changes. `test-receipt.json` and logs record the result.

Run with the approved official Go toolchain:

```
PATH=/tmp/p99-go-toolchain/go/bin:$PATH GOCACHE=/tmp/p99-go-cache GOPATH=/tmp/p99-go-path node --test changes/p99-conversion-ambient/behavior.test.mjs
PATH=/tmp/p99-go-toolchain/go/bin:$PATH GOCACHE=/tmp/p99-go-cache GOPATH=/tmp/p99-go-path node tools/cli.mjs check-proposal . --proposal changes/p99-conversion-ambient.json
```

Generators are deterministic and affect proposed artifacts only. Initial34 and
seven authorized existing-receiver extensions are recorded separately.
