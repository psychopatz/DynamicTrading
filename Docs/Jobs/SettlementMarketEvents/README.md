# Dynamic Trading — Settlement Market & Events

## Parent objective

Restore the **market simulation and market-event depth** of legacy Dynamic Trading as a modern, settlement-centered system built on the current rewrite.

This job does **not** attempt to restore every legacy feature. Legacy is reference material for useful economic behavior only.

The target system must make:

- trader stock persistent across sessions;
- trader stock change mainly through the trader's actual settlement lifecycle;
- settlements own compact local market conditions rather than giant literal inventories;
- MarketSense remain authoritative for intrinsic item value and taxonomy;
- Dynamic Trading own supply/demand pressure, stock availability, market modifiers, event effects, trader economic policy, and settlement exchange;
- Project Hoomans remain authoritative for physical NPC identity, movement, settlement presence, travel, and lifecycle;
- events influence prices immediately through market context while influencing physical stock only through actual logistics/settlement exchange;
- one settlement visit partially refresh or exchange stock rather than rerolling the trader inventory.

## Core gameplay principle

> **Prices react to information; inventory reacts to logistics.**

If a famine begins, food prices may react immediately. A trader's existing inventory must not magically transform. Their stock changes when they actually reach a settlement and participate in that settlement's market.

## Document map

- `AUDIT.md` — current implementation seams and legacy baseline.
- `ARCHITECTURE.md` — ownership, state model, pricing, exchange and events.
- `ROADMAP.md` — complete implementation phases and acceptance gates.
- `HARNESS_ACCEPTANCE.md` — required deterministic and integration verification.
- `AGENT_RUNBOOK.md` — Luna execution rules and read order.
- `PROGRESS.md` — current authoritative implementation checkpoint and Next Chunk.

The conversational `/goal` bootstrap is intentionally **not** checked into the repository.
