# Architecture — Unified Trader World Runtime

## 1. Stable ownership

### PsychopatzCore owns generic mechanisms

Core owns generic actor identity/state, world/location/journey primitives, provider leases/transitions, persistence, synchronized actor projection, map host, and generic notification/debug infrastructure.

Core does not own trader economics, route policy, Hoomans communities, or caravan behavior.

### DTCommon owns the DynamicTrading domain

DTCommon owns one canonical trader-world model:

- trader commercial record;
- stock/budget;
- quote/trade authority;
- market and settlement exchange;
- trader lifecycle policy;
- population intent;
- route/destination intent;
- journey/commercial location state;
- cooldown/schedule;
- arrival and exactly-once settlement visit/exchange;
- trader availability;
- common interaction/contact/action query model;
- provider-independent debug/query model.

DTCommon may use generic PsychopatzCore APIs. Optional adopter implementation details enter through registered ports.

### DTAbstract is an abstract representation adapter

DTAbstract owns:

- abstract provider implementation;
- abstract/Core journey execution where the provider contract requires it;
- client projection consumption;
- map presentation;
- nearby discovery presentation;
- notification/radio UI;
- Abstract Trader Manager UI.

It does not own a second trader population/routing/arrival lifecycle.

### DTHoomans is a physical representation adapter

DTHoomans owns:

- Hoomans bodies;
- faction/caravan/member generation;
- guard roles/equipment;
- PNC travel integration;
- physical position/body reconciliation;
- Hoomans settlement geography provider;
- NPC role/conversation integration;
- portrait/physical presentation.

It does not own a parallel commercial trader lifecycle.

## 2. Canonical trader model

```text
TraderWorld trader
  traderID
  actorID
  commercial state
  stock/budget
  home/current/origin/destination settlement
  lifecycle state
  journey intent/state
  cooldown/schedule
  provider lease / representation
  visit history
```

Exactly one trader record and one Core actor exist per trader. Provider state changes representation, not identity.

## 3. Trader World Runtime

Target common domain surface, names illustrative:

```text
DTCommon/TraderWorld/
  TraderWorldService
  TraderPopulation
  TraderRouting
  TraderJourney
  TraderArrival
  TraderInteraction
  TraderProviderRegistry
```

Existing modules may be extended instead if ownership stays coherent.

Runtime flow:

```text
ensure trader
    |
select/maintain world intent
    |
choose destination
    |
request provider movement
    |
observe canonical journey/provider state
    |
arrival
    |
exactly-once settlement visit/exchange
    |
cooldown / next intent
```

There is one authority flow for commercial/world decisions.

## 4. Provider contract

A provider registry should expose bounded capabilities such as:

```lua
{
  id,
  isAvailable,
  canRepresent,
  ensureRepresentation,
  releaseRepresentation,
  startMovement,
  getPosition,
  getState,
  recover,
}
```

Capabilities may be optional but must be explicit. Provider IDs should be registered data, not a permanently hard-coded closed set.

## 5. Movement ownership

DTCommon owns **where/why/when** a trader travels.

Provider owns **how that representation executes movement**.

- DTAbstract may execute via Core abstract journey.
- DTHoomans may execute via PNC physical/mobile travel.

Both map to the same destination, journey intent/identity, arrival semantics, and trader record.

Never run two route authorities for one trader.

## 6. Population ownership

DTCommon owns desired trader population/commercial roles.

Provider owns representation construction.

Example:

- DTCommon requests a roaming trader.
- DTAbstract creates an abstract representation.
- DTHoomans creates a caravan representation with trader + guards.

Guard/member composition remains DTHoomans policy.

## 7. Arrival ownership

Exactly one common arrival path owns:

- current/destination settlement update;
- visit identity;
- market exchange;
- visit/restock bookkeeping;
- cooldown scheduling.

Provider-specific arrival events translate into this path. They cannot independently apply another exchange.

## 8. Interaction model

Common contact/action query model:

```lua
{
  traderID,
  displayName,
  status,
  marketEvents,
  actions,
  capabilities,
}
```

Common actions include trade/talk availability and shared server authorization.

Adapters augment/filter:

- DTAbstract: remote/radio availability and presentation.
- DTHoomans: live body, distance, role/faction, portrait, NPC conversation surface.

Paging, canonical lookup, market-event summary, and common action descriptors should not be implemented twice.

## 9. Optional-adopter boundaries

Replace direct optional-adopter reads with registered seams where appropriate.

Targets include:

- community/region resolution;
- trader display-name augmentation;
- physical access validation;
- physical trade UI integration;
- provider registration;
- settlement geography.

DTCommon must remain functional when Hoomans is absent.

## 10. Map/presentation

PsychopatzCore remains the single generic map host.

DTAbstract and DTHoomans own visual representation but consume the same canonical trader/actor state.

Do not move map rendering or Hoomans portrait/body details into the common domain.

## 11. Handoff

```text
DTCommon TraderWorld
       |
same trader / actor / journey / stock / visit identity
       |
representation = DTAbstract
       |
provider transition
       |
representation = DTHoomans
       |
provider transition
       |
representation = DTAbstract
```

Handoff is representation change, not transfer between two commercial simulations.

## 12. Migration rules

- characterize behavior before moving code;
- add fail-first/parity tests;
- introduce common contract;
- migrate callers;
- remove obsolete active code;
- do not keep permanent legacy/compat mirrored lifecycle code;
- preserve working pricing/stock/market systems unless evidence requires changes.

## 13. Performance

Required:

- bounded population;
- interval/event-driven lifecycle;
- no duplicate commercial lifecycle ticks;
- no per-frame domain scans;
- bounded provider/contact queries;
- exactly-once arrival effects;
- no duplicate trader/body during handoff.
