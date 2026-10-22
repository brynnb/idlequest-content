# Compatibility review

The related current implementation was inspected privately. No private source,
repository path, commit identifier or implementation excerpt is distributed.
These are static compatibility conclusions, not executed settlement tests.

- Public grid starts persist a single active route per actor lifetime. Another
  observer cannot restart an admitted patrol. Cursor, pauses and callbacks are
  durable; live navigation still requires independent validation.
- Public immediate signals resolve existing actor lifetimes and settle receiver
  delivery before broadcasting transient speech. Missing actors do not cause
  invented spawns. Delayed public signals are not currently supported.
- Public grid start and callback delivery are supported, but public grid stop
  is not. NPC-to-NPC following and fallback public spawning are unsupported.
- World-scoped repeating timers persist their firing state before delivering
  speech. Per-character proximity persists separate bounds/inside state and
  dispatches enter/exit to that character's actor context.
- Public MoveTo currently requires no assigned native patrol; all11 converted
  councilor spawn rows satisfy that condition. Existing court adaptations are
  preserved, not used to claim the whole day/night choreography works.
- DoAnim and SetAppearance do not currently deliver animation; retained calls
  and mocked invocation tests are explicitly not rendered-animation evidence.

The public baseline files, exact source hashes, exported identities and static
path assertions remain independently reproducible. Official public EQEmu delay
unit provenance is recorded in signal-units.json without copying its source.
