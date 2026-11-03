# Agent Runbook — Unified Trader World Runtime

## Mission

Consolidate DynamicTrading onto one provider-agnostic DTCommon trader-world authority.

The previous DTAbstract production recovery is accepted foundation. The current goal is broader: eliminate the remaining parallel commercial/world lifecycle split between DTAbstract and DTHoomans.

After each accepted chunk:

1. update `PROGRESS.md`;
2. select the next mandatory U-phase;
3. continue automatically;
4. stop only for a genuine blocker or full U0–U7 developer acceptance.

## Read order

1. DynamicTrading root `AGENTS.md`;
2. this runbook;
3. `README.md`;
4. `AUDIT.md`;
5. `ARCHITECTURE.md`;
6. `ROADMAP.md`;
7. `HARNESS_ACCEPTANCE.md`;
8. `PROGRESS.md` last.

Before editing Core/Hoomans, read that repository's root `AGENTS.md` and inspect branch/upstream/worktree state.

## Mandatory architecture rules

- DTCommon owns one canonical trader-world/commercial lifecycle.
- DTAbstract and DTHoomans are adapters, not peer trader simulations.
- Core owns generic actor/world/journey/provider mechanisms only.
- DTHoomans keeps Hoomans body/faction/caravan/NPC specifics.
- DTAbstract keeps abstract/map/nearby/radio/debug presentation specifics.
- Stock/budget remain DTCommon-owned.
- One trader means one trader record + one Core actor.
- Provider changes representation, not commercial identity.
- Arrival/visit/exchange is exactly once through common authority.
- Common route intent is distinct from provider-specific movement execution.
- Optional Hoomans behavior enters through registered provider/resolver seams.
- DTCommon must work with Hoomans absent.
- Do not add another compatibility layer around both old lifecycles as the final design.
- No permanent legacy copies after migration.
- No per-frame full-domain scans.

## Migration discipline

For each duplicated behavior:

1. characterize current observable behavior;
2. add parity/fail-first tests;
3. introduce/extend common contract;
4. migrate one adopter;
5. validate;
6. migrate the other adopter;
7. validate cross-provider parity;
8. remove obsolete code;
9. verify no fallback/caller remains.

Do not delete Hoomans-specific mechanics merely because commercial authority moves to DTCommon.

## Test discipline

Must prove common domain with fake provider, DTAbstract provider, DTHoomans provider, exactly-once arrival, provider transition invariants, standalone without Hoomans, split client/server presentation where relevant, save/reload, and performance bounds.

Do not claim unification merely because both adapters call the same trade endpoint while still owning separate lifecycle ticks.

## Git safety

- existing `main` only;
- preserve unrelated user work;
- no blind pull;
- no reset/stash/discard;
- coherent commits;
- no push unless explicitly authorized.

Two unrelated/unexplained DynamicTrading `mod.info` edits are currently unstaged. Preserve them unless separately resolved.

## Documentation discipline

Keep current-goal truth in this job directory. Do not append active phase/progress into root `AGENTS.md`. Replace superseded current-state wording rather than accumulating contradictions.

## Final report

Report lifecycle responsibilities moved to DTCommon, provider-specific responsibilities retained, adopter leaks removed, redundant files/functions deleted, provider parity and exactly-once evidence, full regression/compiler counts, and remaining native acceptance.
