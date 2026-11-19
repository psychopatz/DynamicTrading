# Portable Actor Lifecycle & GC — DynamicTrading Adoption

**Status:** PLANNED participant work.
**Parent:** PsychopatzCore Docs/portable_actor_lifecycle_gc/.
**Role:** make trader/commercial lifecycle consume Core retirement/GC correctly without confusing commercial record removal with actor death.

## Objective

DynamicTrading and DTAbstract/DTHoomans must preserve meaningful social history of retired/dead traders when warranted, while allowing commercial/provider records and unreferenced historical identity to be reclaimed.

DT remains authoritative for stock, budgets, quotes, sessions, debts/contracts and commercial-role policy.

Core remains authoritative for actor lifecycle/tombstones/social history/GC.

## Important distinctions

These are not automatically the same operation:

- rollback an uncommitted trader;
- remove a commercial role;
- dematerialize a trader;
- supersede an old migration actorID;
- kill/permanently retire the person.

Only the last case normally creates a historical lifecycle retirement.

Outstanding debt/contract may pin identity only when actual DT domain state requires it.
