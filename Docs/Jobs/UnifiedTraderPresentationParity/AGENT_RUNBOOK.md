# Agent Runbook — Unified Trader Presentation Parity

## Mission

Eliminate the remaining Dynamic Trading presentation/interaction split between DTAbstract and DTHoomans.

The final system shares trader presentation, map decoration, debug UI, notification UX, and trader conversation content. Only provider presence/materialization differs.

## Read order

1. DynamicTrading root AGENTS.md;
2. this runbook;
3. README.md;
4. AUDIT.md;
5. ARCHITECTURE.md;
6. ROADMAP.md;
7. HARNESS_ACCEPTANCE.md;
8. PROGRESS.md last.

When editing other repositories, inspect branch/status/instructions first.

## Continuous execution

This is a parent goal, not a one-chunk task.

After each accepted chunk:
1. validate;
2. update PROGRESS.md;
3. select the next mandatory phase/chunk;
4. continue automatically.

Stop only for:
- true repository safety conflict;
- unavailable required capability/toolchain;
- unresolved architecture/authority conflict;
- all P0–P7 developer work complete with only native user acceptance remaining.

## Hard architecture rules

- DTAbstract must not depend on ProjectHoomans or PNC.
- DTAbstract and DTHoomans remain mutually exclusive.
- DTHoomans requires ProjectHoomans.
- Core owns provider-neutral actor/map/notification/conversation/debug-host primitives.
- DTCommon owns trader-facing presentation/content/debug policy.
- provider modules own presence/materialization only.
- one canonical actor marker per actor.
- one shared trader conversation content path.
- one shared Dynamic Trading trader manager.
- no provider-specific trader notification widget.
- do not preserve obsolete presentation paths as compatibility shims after migration.

## Hoomans reference rule

ProjectHoomans is reference evidence, not code to copy wholesale.

Classify every Hoomans capability first:
1. generic actor/faction primitive -> Core;
2. Dynamic Trading trader concern -> DTCommon;
3. Hoomans-only concern -> keep in ProjectHoomans.

Do not migrate companion/combat/animation systems merely for visual similarity.

## Conversation discipline

The current DTAbstract hardcoded trader graph is not the desired final authority if DTHoomans follows a different trader-content path.

Audit existing Core semantic migration before moving code.

Prefer:
- existing Core semantic/conversation runtime;
- DTCommon trader extension/content;
- thin provider target/authorization adapters.

Never solve parity by importing PNC into DTAbstract.

## Map discipline

Core ActorMap remains the actor marker renderer.

DTCommon may decorate marker style.

DTAbstract may keep only non-actor discovery overlays after migration.

Do not render a second trader actor marker.

## Notification discipline

Implement compact actor notification generically in Core.

Use canonical portrait specs.

Normal trader discovery/spawn/arrival messages must not open the current large modal debug-like window.

## Debug discipline

Shared trader manager belongs in DTCommon and uses Core Debug Hub/UI components.

Debug-disabled runtime overhead should be negligible.

Provider-specific debug extensions must be bounded and optional.

## Validation

Use fail-first focused tests before each migration.

Run full suites at phase boundaries.

Use installed-PZ Kahlua verification for all changed production Lua.

Run git diff --check.

Perform source-removal audits before declaring P6 complete.

## Git discipline

- existing main only;
- inspect status before edits;
- preserve concurrent work;
- no reset/rebase/stash/discard of uncertain changes;
- coherent commits per repository;
- no push unless explicitly authorized.

## Documentation

Keep active goal state in this job directory.

Do not add goal progress to root AGENTS.md.

Update PROGRESS.md after accepted chunks.

Trim superseded implementation instructions instead of accumulating historical executable guidance.

## Final report

Report:
- Core primitives added/extracted;
- shared DTCommon presentation/debug/conversation contracts;
- deleted provider-specific presentation paths;
- source audit results;
- full test/Kahlua counts;
- exact remaining native acceptance items.
