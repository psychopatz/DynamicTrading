# Dynamic Trading — Settlement Market, Events & Trader Mobility

## Parent objective

Restore the **market simulation and market-event depth** of legacy Dynamic Trading as a modern, settlement-centered system, then connect that economy to two believable trader lifecycles: settlement-owned resident traders and base-less perpetual caravans.

This job does **not** attempt to restore every legacy feature. Legacy is reference material for useful economic behavior only.

The target system must make:

- trader stock persistent across sessions;
- trader stock change mainly through the trader's actual settlement lifecycle;
- settlements own compact local market conditions rather than giant literal inventories;
- MarketSense remain authoritative for intrinsic item value and taxonomy;
- Dynamic Trading own supply/demand pressure, stock availability, market modifiers, event effects, trader economic policy, and settlement exchange;
- Project Hoomans remain authoritative for physical NPC identity, movement, settlement presence, travel, and lifecycle;
- events influence prices immediately through market context while influencing physical stock only through actual logistics/settlement exchange;
- one settlement visit partially refresh or exchange stock rather than rerolling the trader inventory;
- eligible Hoomans settlements provision their market state automatically in normal gameplay;
- the existing Hoomans mobile-settlement arrival lifecycle drives trader exchange without a DT-owned travel loop;
- market pressure actually recovers over game time through a bounded runtime path;
- at least one grounded production event producer creates real market events without test/debug registration;
- settlement-owned traders are bound to their home market and may later leave only through rare, purposeful Hoomans-owned excursions;
- base-less trader caravans use Hoomans-owned commercial settlement visits and can actually move between markets without settlement admission/absorption;
- long-distance trader travel stays abstract while nearby/materialized Hoomans behavior remains live;
- generic excursion/public-status hooks expose authoritative social facts such as "the trader is away on a trading run" without coupling semantics to DT movement internals;
- a production semantic question such as "Where is your trader?" can resolve the authoritative destination settlement name, relative direction, and ETA when the speaker is allowed to know them;
- PsychopatzCore provides one reusable spatial-relation/language foundation for both world-cardinal place directions and observer-relative clock bearings, rather than trader/combat-specific direction math.

## Core gameplay principle

> **Prices react to information; inventory reacts to logistics.**

If a famine begins, food prices may react immediately. A trader's existing inventory must not magically transform. Their stock changes when they actually reach a settlement and participate in that settlement's market.

## Document map

- `AUDIT.md` — current implementation seams and legacy baseline.
- `ARCHITECTURE.md` — ownership, state model, pricing, exchange, events, and mobility boundaries.
- `COMMUNITY_EXCURSIONS.md` — detailed generic Hoomans excursion + two-trader mobility design.
- `SPATIAL_LANGUAGE.md` — reusable Core coordinate→direction/distance/clock-bearing contract.
- `M10H_TACTICAL_SEMANTIC_INTEGRATION.md` — audited Hoomans combat-awareness → spatial fact → Semantic Scene / ambient reaction integration plan.
- `ROADMAP.md` — complete implementation phases and acceptance gates.
- `HARNESS_ACCEPTANCE.md` — required deterministic and integration verification.
- `AGENT_RUNBOOK.md` — Luna execution rules and read order.
- `PROGRESS.md` — current authoritative implementation checkpoint and Next Chunk.

The conversational `/goal` bootstrap is intentionally **not** checked into the repository.
