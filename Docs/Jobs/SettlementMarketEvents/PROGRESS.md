# Progress — Settlement Market & Events

## Parent status

**IN PROGRESS — documentation/architecture established; production implementation not started under this job.**

The full M0–M8 roadmap is the completion boundary.

## Planning baseline

DynamicTrading remote/current baseline inspected at:

`e6012c27de66f299e019c7aa62db4dc4c986e089`

Legacy behavioral reference:

`ee0a8dc6a6989fbbdbd943ec23aa3f1c54099415`

Local planning checkout matched `origin/main` at the baseline but had an unrelated modified:

`Contents/mods/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua`

Preserve it.

## Accepted existing foundation

- stable trader registry and persistent stock;
- bounded initial MarketSense-backed stock seed;
- MarketSense definition/instance pricing;
- server-authoritative buy/sell basket settlement;
- exact identity/replay/stale-version security;
- trader budget and stock revisions;
- Core actor policy with settlement-gated `MarkVisit` and `Restock`;
- Hoomans physical trader/faction binding;
- DTAbstract remote access;
- Talk service;
- WorldKnowledge adapter;
- reusable Radio OS integration.

These are foundations to preserve, not work to rewrite.

## Current gap

No current production domain owns:

- settlement market profiles;
- local supply/demand pressure;
- recovery to baseline;
- market-aware availability;
- market-aware quote modifiers;
- generic scoped market events;
- event-driven price/availability modifiers;
- bounded settlement exchange that partially transforms persistent trader stock;
- two-settlement logistics propagation through a trader.

## Current phase

**M0 — Source audit and contracts**

## Next Chunk — M0A

Luna must start by proving the exact current lifecycle seam before adding market state.

### Required work

1. Recheck DynamicTrading local `main`, upstream, dirty files and worktrees.
2. Inspect current:
   - `DTCommon_TraderRegistry.lua`
   - `DTCommon_TraderStock.lua`
   - `DTCommon_TraderService.lua`
   - `DTCommon_CoreActorPolicy.lua`
   - `DTCommon_Storage.lua`
3. Trace the actual current Project Hoomans/DTHoomans path that represents:
   - trader enters/arrives at settlement;
   - settlement identity;
   - call site or missing call site for `MarkSettlementVisit`.
4. Identify the canonical stable settlement ID contract. Do not invent one until this audit is complete.
5. Inspect current MarketSense public taxonomy/tag APIs suitable for bounded category indexing.
6. Add fail-first/guardrail tests proving:
   - trader stock persists across repeated snapshots;
   - UI/snapshot does not reroll stock;
   - settlement visit requires settlement context;
   - duplicate visit ID does not apply twice;
   - current transaction path remains unchanged.
7. Record exact current seams and any required narrow adapter in this ledger.

### M0A acceptance

M0A is accepted only when Luna can point to the real production settlement/trader lifecycle and stable settlement identity, with tests protecting the persistent-stock baseline.

After M0A acceptance, continue automatically to the remaining M0 work and then M1–M8. Do not stop for another /goal.

## Known constraints

- Legacy is reference only; no wholesale port.
- The old trading MVP docs explicitly excluded market simulation. That exclusion does **not** apply to this new job; however, the safe trading MVP foundation remains mandatory.
- Native PZ acceptance is not a prerequisite for starting implementation. Finish all safe developer-side work first.
