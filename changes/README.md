# Review proposals

Keep the baseline immutable. Each proposal is JSON with:

- format: 1
- id: lowercase dash-separated ID
- summary: concrete before/after behavior
- baseManifestSha256: SHA-256 of manifest.json
- evidence: objects with url and note (include retrieval/revision information)
- rows: objects with table, before and after (complete exported row or null for insert/delete)
- sources: objects with target, beforeSha256, proposedFile and afterSha256

Proposed Lua belongs under changes/<id>/ and target is the canonical
maintained/lua/<origin>/<zone>/<name>.lua path. Every changed quest Lua row
must match a proposed maintained source. Preserve -- name: aliases.

Check with:

    node tools/cli.mjs check-proposal . --proposal changes/NAME.json
    node tools/cli.mjs preview . --proposal changes/NAME.json --env-file /outside/scratch.env --database idlequest_content_review
    node tools/cli.mjs apply-scratch . --proposal changes/NAME.json --env-file /outside/scratch.env --database idlequest_content_review

Preview runs inside a rolled-back transaction. Application checks exact current
rows and schema, rejects stale fixes and missing references, and rolls back the
whole proposal on failure. Reapplication recognizes unchanged postimages.

Shared-module replacements target maintained/modules/<module-name>.lua. Leading
-- enabled: false comments preserve reviewed disabled state on future imports.
Review-ledger targets and the pinned handoff workflow are documented in
docs/handoff.md. Rehearsal commands intentionally target scratch databases only;
the handoff stages ordinary source edits and a guarded migration for review.
