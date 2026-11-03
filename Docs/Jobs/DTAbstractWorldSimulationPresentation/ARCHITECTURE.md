# Architecture — DTAbstract World Simulation & Presentation

## 1. Ownership

### DTCommon owns

- trader merchant identity/record;
- exact persistent merchant stock and budget;
- quote/trade authority;
- settlement-market pressure and exchange;
- MarketSense-backed economic context;
- trader commercial policy fields such as current/home/destination settlement IDs;
- a Dynamic Trading settlement-directory **contract/registry** if a shared cross-provider settlement seam is required.

DTCommon does not own NPC bodies or vanilla map rendering.

### DTAbstract owns

- standalone abstract-trader population/lifecycle policy;
- which standalone trader should exist;
- abstract commercial route/destination policy when Hoomans is absent;
- driving Core actor journey advancement for DTAbstract-owned actors;
- standalone settlement-provider data/adaptation;
- DTAbstract client presentation adapters;
- nearby trader discovery policy;
- DTAbstract Debug Hub tools and server-authoritative debug commands;
- deciding when to request a provider handoff based on the approved proximity/presence policy.

DTAbstract does not own intrinsic pricing, duplicate merchant inventory or a second actor identity.

### PsychopatzCore owns

- canonical generic actor state;
- provider leases and transitions;
- generic world/location/journey mechanics;
- generic projected journey-position math if required;
- generic actor map-entry/nearby-query mechanisms;
- reusable notification mechanisms/UI;
- reusable Debug Hub;
- a generic vanilla-map marker/overlay host only if the implementation audit proves it is a reusable mechanism rather than Dynamic Trading policy.

Core must not learn trader economics, settlement-market rules or DTHoomans concepts.

### DTHoomans / Project Hoomans own when installed

- physical NPC/caravan bodies;
- Hoomans live presence and local movement;
- Hoomans faction/community membership;
- physical interaction/combat;
- authoritative Hoomans community/place data that an adapter may expose to the shared DT settlement-directory contract.

DTAbstract must remain functional when these mods are absent.

## 2. Identity invariant

> One commercial trader = one DT trader record + one canonical Core actor identity, regardless of current provider.

Never create:

```text
DTAbstract trader A
+
DTHoomans trader A-copy
```

Provider transition changes representation, not identity.

The DT trader record should retain/bind the canonical actor ID. Core provider state determines which representation currently owns it.

## 3. Standalone settlement directory

A settlement that can be routed to or drawn on the map must resolve through one bounded contract.

Conceptual descriptor:

```lua
{
    settlementID = "stable:id",
    name = "Readable Name",
    position = { x = 0, y = 0, z = 0 },
    profileID = "default",
    provider = "DTAbstract",
    enabled = true,
}
```

Rules:

- IDs are stable and persistence-safe.
- coordinates are authoritative provider data, never UI guesses;
- Hoomans communities adapt their current canonical IDs/positions when available;
- standalone DTAbstract uses approved data/provider definitions;
- the registry is bounded and indexed;
- market state continues to be owned by `SettlementMarket`, not duplicated into the directory;
- a settlement directory entry may exist before its market state is lazily provisioned.

## 4. Abstract trader lifecycle

The server-authoritative standalone lifecycle is conceptually:

```text
ensure trader/actor
      |
      v
AT_SETTLEMENT / IDLE
      |
select valid destination
      |
      v
START CORE JOURNEY
      |
      v
TRAVELING
      |
bounded advance by game time
      |
      +--> player proximity/discovery presentation
      |
      v
ARRIVED
      |
      +--> update current/last settlement
      +--> one idempotent settlement visit/exchange
      +--> publish relevant world knowledge
      |
      v
cooldown / select next route
```

No per-frame economy or all-world scan is allowed.

Use game-time/event/interval advancement with bounded work.

## 5. Moving-position projection

A trader on a journey must have one canonical **current projected position** for:

- map marker;
- distance-to-player;
- nearby discovery;
- debug locate/teleport;
- provider handoff policy.

Do not separately interpolate in each consumer.

If Core does not already expose this, add one generic journey/world query such as conceptual:

```text
Actors.World.ProjectPosition(worldState, now)
```

or an equivalent narrow reusable contract.

It must derive position from the canonical journey origin/destination/progress/time and agree with arrival state.

## 6. Map model

The map is presentation of authoritative state, not its own simulation.

### Trader markers

Derived from:

```text
Core actor
+ projected current position
+ DT trader display state
+ discovery/visibility
→ map marker
```

The map may show:

- trader name/label;
- traveling/at-settlement state;
- destination where policy/knowledge allows;
- provider/debug state in debug mode.

### Settlement markers

Derived from the settlement directory, not the trader map registry.

Normal visibility/discovery policy may differ from debug "show all."

### Rendering

Prefer a generic Core map-overlay registration mechanism if it can remain domain-agnostic. Otherwise keep DTAbstract's renderer thin and data-driven.

Do not import PNC/Hoomans internals into standalone DTAbstract.

## 7. Nearby discovery and notification

Use one bounded proximity policy over canonical projected positions.

State machine:

```text
OUTSIDE
  |
enter radius
  v
DETECTED
  +--> mark known/discovered
  +--> publish/show one notification
  +--> optional provider-handoff evaluation
  |
remain inside
  v
NO REPEAT SPAM
  |
exit beyond hysteresis radius + cooldown
  v
eligible for future detection
```

Notification presentation should use the existing PsychopatzCore notification UI.

Debug spawn feedback and gameplay nearby-detection notification are separate events and must remain distinguishable.

## 8. Dedicated DTAbstract debug contract

The Debug Hub tool must inspect **abstract** state directly.

Mandatory capabilities:

- list current abstract traders;
- show provider/state/current/destination/position/distance;
- spawn abstract trader near player;
- spawn at an explicit map/world position if the available safe map context supports it;
- force one lifecycle tick;
- force arrival/advance for deterministic testing;
- locate/show marker;
- teleport player to trader;
- reset/mark discovery;
- remove a debug-created abstract trader;
- request materialize/dematerialize only when the physical provider exists.

Every mutation is server-authoritative and returns an explicit result/reason.

## 9. Provider handoff

Hybrid mode must prevent two simultaneous lifecycles from owning one actor.

Conceptual transition:

```text
DTAbstract abstract lease
       |
nearby + physical provider available
       v
validated provider switch
       |
DTHoomans materialized body
       |
player leaves / live representation no longer needed
       v
persist body projection
       |
validated dematerialize/switch
       v
DTAbstract resumes abstract lease/journey
```

Hard rules:

- merchant stock stays in DTCommon;
- actor personal state stays in Core/Hoomans actor state;
- no duplicate body;
- no duplicate settlement exchange on handoff;
- no journey restart from origin;
- save/reload preserves provider and world state coherently.

## 10. Performance boundaries

Forbidden:

- per-frame scan of every trader/settlement;
- per-frame map-data rebuild;
- repeated full MarketSense scan for movement/presentation;
- map renderer mutating simulation state;
- client authority over trader spawn/travel;
- separate interpolation math in map, detection and debug systems.

Required:

- bounded trader population;
- indexed settlement lookup;
- event/interval-driven lifecycle;
- cached/dirty map projection where practical;
- proximity checks only at bounded cadence or relevant movement events;
- deterministic duplicate protection for arrival/exchange/notifications.

## 11. Compatibility modes

Mandatory developer-side coverage:

1. **Standalone:** Core + MarketSense + DTCommon + DTAbstract.
2. **Physical:** Core + MarketSense + DTCommon + DTHoomans + Project Hoomans.
3. **Hybrid:** all above, with one canonical trader actor transitioning providers.
4. Existing Radio OS / Talk / trade flows remain usable.

Standalone behavior must never silently depend on Hoomans globals.
