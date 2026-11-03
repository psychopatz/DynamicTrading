# Agent Runbook — DTAbstract World Simulation & Presentation

## Mission

Implement the complete parent objective in this job, not merely the immediate phase.

The current Next Chunk is a starting point. After each accepted chunk:

1. update `PROGRESS.md`;
2. identify the next mandatory roadmap chunk;
3. continue automatically;
4. stop only for a genuine blocker, authorization/scope conflict, full developer-side completion, or the final explicit native user-owned gate.

## Read order

At the beginning of a fresh agent session:

1. repository root `AGENTS.md`;
2. this `AGENT_RUNBOOK.md`;
3. `README.md`;
4. `AUDIT.md`;
5. `ARCHITECTURE.md`;
6. `ROADMAP.md`;
7. `HARNESS_ACCEPTANCE.md`;
8. `PROGRESS.md` **last**.

Then inspect the current code/tests before trusting any recorded completion claim.

## Repositories

Primary:

`/home/psychopatz/Zomboid/Workshop/DynamicTrading`

Expected optional dependencies:

- `/home/psychopatz/Zomboid/Workshop/psychopatzCore`
- `/home/psychopatz/Zomboid/Workshop/ProjectHoomans`

Before editing any dependency repository:

- read its root `AGENTS.md`;
- inspect branch/HEAD/upstream/worktree/worktrees;
- preserve unrelated changes;
- make only the minimal reusable dependency change required by this parent objective.

## Git rules

Follow the DynamicTrading root policy.

Mandatory:

- existing `main` only; do not create a new branch;
- no blind `git pull`;
- no destructive reset/rebase/force-push;
- no automatic stash/discard of uncertain user work;
- keep commits coherent;
- do not mix unrelated edits;
- only push when current repository policy/authorization makes the exact destination safe; never invent publication authorization.

## Source-of-truth order

When sources disagree:

1. current production code/runtime behavior;
2. current tests and produced evidence;
3. stable architecture contracts;
4. this roadmap;
5. progress ledger;
6. older docs/agent prose.

The audit in this job is a verified baseline at its recorded SHA, not a substitute for re-auditing changed source.

## Mandatory architecture rules

- MarketSense remains intrinsic valuation/taxonomy authority.
- DTCommon remains merchant stock/budget/quote/trade/market authority.
- DTAbstract owns standalone abstract simulation policy, not merchant inventory.
- PsychopatzCore owns reusable actor/provider/journey/map-data/notification mechanisms.
- DTHoomans/Hoomans own physical representation when installed.
- One trader has one canonical DT trader record and one canonical Core actor identity.
- Provider handoff changes representation, not identity.
- A market ID is not automatically a geographic place; route/map use the explicit settlement-directory contract.
- Map, proximity and debug locate use one canonical projected-position query.
- Map/UI never mutate authoritative simulation state.
- Debug spawn is an abstract spawn, not a call to the DTHoomans live-caravan spawner.
- Standalone DTAbstract must not require Project Hoomans.
- No per-frame all-trader/world scan.
- No second intrinsic pricing system.
- No second merchant inventory.
- No copied PNC/Hoomans business/state logic merely to obtain a map.

## Implementation discipline

Prefer vertical proofs.

For each chunk:

```text
verify current source
→ add/confirm fail-first test
→ implement smallest owning responsibility
→ focused tests
→ integration regressions
→ static/diff checks
→ update PROGRESS
→ coherent commit when safe
→ continue
```

If a generic Core capability is missing, add the smallest domain-agnostic mechanism and test it in Core. Do not move Dynamic Trading policy into Core.

If a Hoomans adapter is needed, keep it optional and narrow.

## Debugging discipline

The dedicated DTAbstract manager is part of the product acceptance for this job, not optional developer polish.

Keep two classes of feedback distinct:

1. **debug command result** — confirms requested spawn/action succeeded/failed;
2. **gameplay discovery notification** — emitted when normal proximity detection discovers a nearby trader.

Do not use one as a substitute for the other.

## Validation discipline

Follow `HARNESS_ACCEPTANCE.md`.

Do not claim:

- map success from a table-only projection;
- notification UI success from queue-only tests;
- native SP/MP success from Lua mocks;
- provider handoff success from separate actors with matching names;
- persistence success from reusing the same in-memory table.

Report skipped evidence explicitly.

## Scope boundaries

Do not turn this into:

- Radio OS redesign;
- MarketSense repricing work;
- new trade UI;
- quests/contracts;
- full Hoomans architecture refactor;
- full physical long-distance pathfinding;
- broad Core map rewrite unrelated to the minimal reusable marker seam.

## Stop conditions

Early stop is allowed only for:

- unsafe user-authored Git conflict in required files;
- missing dependency/API that cannot be safely implemented;
- authorization restriction;
- a genuinely unspecified product decision that changes the approved architecture;
- all developer-side P0–P7 acceptance complete, leaving only explicitly user-owned native PZ testing.

A phase passing is not a stop condition.

## Final report

Report:

- phases completed;
- files/modules changed;
- exact tests/evidence;
- performance/persistence evidence;
- dependency repository revisions if changed;
- DynamicTrading revision and push state;
- native SP/MP evidence if any;
- remaining user-owned live acceptance or genuine blocker.
