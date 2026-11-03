# Architecture — DTAbstract World Simulation & Presentation

## 1. Stable ownership

### PsychopatzCore owns reusable mechanisms

Core owns:

- canonical generic actor state;
- actor registry persistence contract;
- provider leases/transitions;
- generic world/location/journey mechanics;
- canonical projected current position;
- generic client projection/snapshot transport needed by adopters;
- generic actor map-entry/nearby-query mechanisms;
- reusable notification and Debug Hub mechanisms;
- **one generic vanilla-world-map overlay/tool host**.

The last item is mandatory. Adopters must not each monkey-patch `ISWorldMap`.

Core must not learn trader economics, Hoomans community policy, colony rules, or Dynamic Trading route policy.

### DTCommon owns commerce

DTCommon owns:

- trader merchant identity/record;
- merchant stock and budget;
- quote/trade authority;
- MarketSense-backed pricing context;
- settlement market/exchange;
- trader commercial settlement IDs;
- the bounded settlement-directory contract if it remains the shared DT seam.

DTCommon must not directly depend on PNC globals. Optional Hoomans geography enters through a registered adapter/provider.

### DTAbstract owns standalone abstract trading policy

DTAbstract owns:

- bounded standalone trader population policy;
- abstract route/destination policy;
- driving Core journeys for DTAbstract-owned actors;
- standalone settlement provider data;
- DT-specific map layer descriptors;
- nearby-trader discovery policy;
- DTAbstract Trader Manager UI and command presentation;
- server-authoritative DTAbstract debug commands;
- deciding when the approved physical-provider handoff condition is met.

DTAbstract does not own a second actor registry authority, generic map host, merchant inventory, or physical NPC body.

### ProjectHoomans / DTHoomans own physical policy

Hoomans owns:

- physical bodies;
- live NPC AI/combat/needs;
- Hoomans faction/community policy;
- Hoomans-specific map layers and debug actions;
- community geography exposed through a narrow provider adapter.

DTHoomans adapts the shared trader/Core actor into that physical representation.

## 2. One trader / one actor / one provider lease

```text
DT trader record
      |
      +-- actorID --> Core actor
                       |
                       +-- provider lease: DTAbstract OR DTHoomans
```

Provider transition changes representation, not identity.

Never create a “DTAbstract copy” and “DTHoomans copy” of one merchant.

## 3. One map host

Target:

```text
                 PsychopatzCore Map Host
                 owns ISWorldMap patch
                         |
          +--------------+--------------+
          |                             |
ProjectHoomans layers             DTAbstract layers
communities/groups/etc.           traders/DT settlements
          |                             |
          +------ register/unregister --+
```

Rules:

- exactly one Core production hook into the vanilla map;
- generic ordered overlay registration;
- generic toolbar/tool registration where a shared map control surface is required;
- adopter-specific labels/icons/policy remain in adopter modules;
- ProjectHoomans legacy generic host files are migrated or reduced to thin adapters, then redundant monkey patches are removed;
- DTAbstract has no direct fallback `ISWorldMap.render` patch after migration;
- mixed load order must not decide whether markers exist.

## 4. Authoritative client projection

Server actor state is authoritative.

Clients that need map/debug/discovery information consume a bounded read-only projection synchronized from authority.

Minimum projection for DTAbstract:

```lua
{
  actorID,
  revision,
  provider,
  providerState,
  position = {x,y,z},
  journey = {
    state,
    origin,
    destination,
    startAt,
    eta,
    progress,
    destinationSettlementID,
  }
}
```

The transport may use a generic Core actor projection/snapshot mechanism. Do not synchronize the entire private actor record if the client only needs a bounded presentation projection.

Map, nearby discovery, debug locate, and handoff presentation must consume the same authoritative revision/position semantics.

## 5. Production persistence

Codec capability alone is insufficient.

The runtime must connect Core actor registry persistence to the actual save/load lifecycle used by the game/adopter.

Requirements:

- trader `actorID` cannot outlive its actor silently;
- load reconstructs the Core actor before lifecycle advancement relies on it;
- missing/corrupt actor linkage has deterministic recovery/quarantine behavior;
- active journey/provider lease survives the intended save/restart boundary;
- no duplicate actor is created merely because the registry was not loaded yet.

## 6. Settlement directory

A routable settlement descriptor has:

```lua
{
  settlementID,
  name,
  position = {x,y,z},
  profileID,
  provider,
  enabled,
}
```

Rules:

- stable IDs;
- authoritative coordinates;
- bounded indexed registry;
- market state remains separate;
- standalone DTAbstract provider data may use fixed trading hubs if that is the approved product policy;
- Hoomans communities register through an adapter/provider, not through a DTCommon special-case PNC lookup;
- “vanilla town trading hub” and “generated Hoomans settlement” are distinct concepts unless explicitly unified.

## 7. Abstract lifecycle

```text
ensure canonical trader+actor
        |
idle at settlement
        |
select destination
        |
Core journey
        |
bounded authoritative advance
        |
arrival
        |
exactly-once settlement visit/exchange
        |
cooldown / next route
```

No client authority and no full per-frame world simulation.

## 8. Map/discovery position

One canonical current position is used by:

- map marker;
- nearby detection;
- debug locate/teleport;
- provider-handoff decision.

Do not reimplement interpolation separately.

## 9. Nearby discovery

Use enter radius + exit hysteresis + cooldown.

The server/client boundary must be explicit: the client may present discovery from an authoritative synchronized projection, but must not invent or advance trader world state.

Debug action result and gameplay nearby notification are different event classes.

## 10. Real DTAbstract Trader Manager

The Core Debug Hub entry must open a real UI.

Minimum UI:

- refreshable trader list;
- IDs/name/provider/state;
- current projected position/distance;
- current/origin/destination settlement;
- journey state/progress;
- Spawn Near;
- Spawn At explicit position where supported;
- Force Tick;
- Force Arrival;
- Locate on Map;
- Teleport;
- discovery reset/mark;
- Remove debug trader;
- Materialize/Dematerialize when physical provider is available.

All mutations are server-authoritative.

A helper function returning `true` is not UI acceptance.

## 11. Provider handoff

Production orchestration must actually drive:

```text
DTAbstract abstract
   -> approved proximity/materialization condition
   -> provider transition
   -> DTHoomans materialized
   -> leave/dematerialize condition
   -> persist physical projection
   -> DTAbstract resumes
```

Adapter-level manual tests remain useful unit evidence but do not satisfy this requirement.

## 12. Performance

Forbidden:

- multiple adopter `ISWorldMap` monkey patches;
- per-frame full trader/settlement scans for simulation;
- full actor-record replication when a bounded presentation projection is enough;
- repeated full MarketSense scans for map/discovery;
- duplicate notification spam;
- map renderer mutating simulation state.

Required:

- bounded population;
- interval/event-driven lifecycle;
- bounded projection payload;
- dirty/revision-based sync where practical;
- indexed settlement lookup;
- one map host;
- deterministic cleanup/unregister behavior.
