# Acceptance — Unified Trader World Runtime

## Evidence rule

Use explicit evidence classes:

- source/static;
- common-domain unit;
- provider contract;
- split authority/client;
- production composition;
- production persistence;
- cross-repository regression;
- native SP;
- native MP.

Adapter compatibility does not prove duplicate domain authority is gone.

## Common-domain lifecycle

Run DTCommon with fake providers and no DTAbstract/DTHoomans globals.

Required:

- create/ensure trader;
- one actor binding;
- destination assignment;
- canonical journey intent;
- provider movement execution/observation;
- arrival;
- exactly-once settlement visit/exchange;
- cooldown;
- next route;
- save/reload.

No adopter module may be required to define commercial lifecycle semantics.

## Single-authority proof

Instrument mutations to:

- current/origin/destination settlement;
- visit ID/history;
- settlement exchange;
- cooldown;
- provider lease;
- trader availability.

For one canonical journey, assert exactly one authority applies each commercial transition. Provider-specific arrival events cannot double-apply exchange.

## Provider contract

Use at least:

- fake provider;
- DTAbstract provider;
- DTHoomans provider.

Across transitions preserve:

- traderID;
- actorID;
- stock;
- budget;
- journey identity/intent;
- visit history;
- one active representation/body where applicable.

Provider absence must degrade cleanly.

## DTAbstract adapter

Verify map, nearby, notification/radio, Debug Manager, abstract movement, and client projection.

Reject if DTAbstract still independently owns commercial destination selection, arrival exchange, or cooldown.

## DTHoomans adapter

Verify caravan/faction/member generation, trader/guard roles, body, PNC travel, physical reconciliation, Hoomans settlement adapter, and NPC conversation/portrait presentation.

Reject if DTHoomans independently applies a parallel commercial lifecycle.

## Interaction/contact

Build canonical contact/action data once.

Common proof:

- trader lookup;
- status;
- market events;
- trade/talk action descriptors;
- paging/bounds;
- server authorization.

Adapter proof:

- remote/radio eligibility for DTAbstract;
- body/distance/role/faction/portrait for DTHoomans.

## Optional-adopter isolation

Run/search DTCommon with Hoomans absent.

Audit direct `PNC`, `DTHoomans`, and `DTAbstract` references. Remaining references must be justified as data identifiers or explicit registered adapter boundaries, not hidden implementation coupling.

## Cleanup

Search for duplicated ownership of:

- population ticks;
- trader creation;
- destination selection;
- journey start;
- arrival;
- settlement visit/exchange;
- cooldown;
- contact enumeration;
- access validation;
- provider transition.

Every surviving implementation must have one unique owner. No permanent legacy/compat/fallback/mirrored lifecycle remains.

## Regression foundation

Keep previous recovery contracts green:

- Core single map host;
- split client projection;
- persistence;
- map;
- nearby;
- Debug Manager;
- Spawn At;
- settlement provider;
- orphan recovery;
- provider handoff;
- performance bounds.

Recovery baseline: 57/57.

## Performance

Bound lifecycle cadence, provider maintenance, trader/settlement counts, projection payload, contact enumeration, map/nearby reads, and handoff checks.

Reject duplicate commercial ticks, per-frame domain scans, duplicate arrival effects, duplicate notifications, and duplicate bodies/traders.

## Persistence/recovery

Across save/reload preserve trader→actor binding, provider state, journey intent/state, stock/budget, and visit history. Missing-body recovery must not create a second trader.

## Native acceptance

After U0–U7 developer gates:

- standalone DTAbstract lifecycle/presentation with no Hoomans globals;
- DTHoomans physical trader/caravan through the same common lifecycle;
- approach/materialize/move/leave/dematerialize without identity or commercial duplication;
- SP save/reload;
- MP authority/resync/reconnect;
- no duplicate body/trader/exchange.
