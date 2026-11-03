# Architecture — Unified Trader World Runtime

## 1. Stable ownership

### PsychopatzCore

Owns generic mechanisms:

- actor identity and state;
- location and journey primitives;
- provider leases and transitions;
- actor persistence;
- synchronized actor projection transport;
- generic map host and notification/debug infrastructure.

Core does not own trader economics or route policy.

### DTCommon

Owns the DynamicTrading domain:

- trader records;
- stock and budget;
- quote and trade authority;
- settlement market and exchange;
- population intent;
- route and destination intent;
- commercial journey and settlement state;
- arrival, visit history, and cooldown;
- provider registry;
- representation transition policy;
- common trader projection and client presentation model;
- common contact and action model;
- optional-adopter integration registries.

### DTAbstract

Owns the abstract representation implementation and abstract-facing presentation only.

### DTHoomans

Owns Hoomans physical bodies, caravans, mobile groups, resident participant travel, Hoomans geography, and Hoomans-specific presentation and access logic.

## 2. Canonical trader model

One trader keeps one canonical commercial identity:

- traderID;
- actorID;
- stock and budget;
- home, current, origin, and destination settlement;
- lifecycle state;
- journey identity and state;
- cooldown;
- provider lease and representation;
- visit history.

Provider transitions do not create a second trader or second commercial state machine.

## 3. Common runtime modules

DTCommon_TraderWorld.lua

- common lifecycle state;
- population;
- destination selection;
- journey intent;
- external journey state;
- arrival;
- exactly-once visit and exchange;
- cooldown;
- provider reconciliation.

DTCommon_TraderWorldRuntime.lua

- single commercial cadence.

DTCommon_TraderProviderRegistry.lua

- open provider registry;
- capability-specific provider selection.

DTCommon_TraderRepresentationRuntime.lua

- bounded proximity-driven representation switching;
- native-physical protection;
- missing-body recovery coordination.

DTCommon_TraderProjectionServer.lua and DTCommon_TraderPresentation.lua

- one provider-agnostic DynamicTrading projection source and client read model.

DTCommon_TraderContacts.lua

- canonical bounded contact, paging, market-event, and common action construction.

DTCommon_IntegrationRegistry.lua and DTCommon_TradePresentationRegistry.lua

- optional adopter capabilities without implementation coupling.

## 4. Provider contract

Providers may expose capabilities such as:

- isAvailable;
- ownsRecord;
- spawnTrader;
- canTravelTo;
- scoreDestination;
- startMovement;
- pollMovement;
- getPosition;
- reconcileRecord;
- materializeTrader;
- dematerializeTrader;
- recoverMissingBody;
- getActorRegistry.

Capabilities are optional and registered. Provider IDs are not a permanently closed hard-coded set.

## 5. Movement contract

DTCommon owns where, why, and when commercial travel occurs.

The provider owns how its representation executes movement.

DTAbstract executes a Core abstract journey.

DTHoomans executes Hoomans mobile-group travel for caravans. Temporary individual physical projections may pause movement and later rebase the same Core journey when returning to the origin provider.

Never run two commercial route authorities for one trader.

## 6. Population contract

DTCommon owns desired roaming population.

A selected spawn provider constructs the representation.

Abstract representation is preferred when available; physical caravan spawn remains a fallback provider capability. Hoomans guard and member composition remains DTHoomans-owned.

## 7. Arrival contract

Exactly one common arrival path owns:

- current and destination settlement update;
- visit identity;
- settlement exchange;
- visit and restock bookkeeping;
- cooldown scheduling.

Hoomans arrival events translate into that common API and do not independently apply another commercial exchange.

## 8. Resident traders

Resident is a DTCommon world role.

DTCommon owns commercial destination and location transitions.

DTHoomans owns the Hoomans excursion executor, participant lifecycle, visit timing, and exact-home return.

Externally validated Hoomans community IDs may enter the common external-journey API without requiring a duplicate DT settlement lookup.

## 9. Representation handoff

Temporary representation flow:

DTCommon trader
  -> origin provider
  -> DTCommon representation policy
  -> physical provider materialization
  -> same trader and actor
  -> physical body position
  -> dematerialize or recover
  -> recorded origin provider
  -> same canonical journey rebased from final body position

Native physical traders have no returnProviderID and are not auto-dematerialized.

## 10. Projection

The synchronized projection source is DynamicTrading and is owned by DTCommon.

Provider getPosition can override the Core projected position.

For physical providers, client projection suppresses the old abstract journey interpolation so map/debug consumers see live physical position rather than stale route interpolation.

## 11. Interaction model

Common contact data contains trader ID, display name, status, market events, actions, and capabilities.

DTAbstract adds remote and radio eligibility.

DTHoomans adds body, distance, role, faction, portrait, and physical-window behavior.

## 12. Performance rules

- roaming population is bounded;
- provider and integration registries are bounded;
- contacts and page size are bounded;
- commercial lifecycle is interval-driven;
- representation proximity checks are throttled;
- no duplicate commercial lifecycle tick;
- no duplicate arrival effect;
- no per-frame commercial-domain scan;
- projection payload remains Core-bounded.

## 13. Native acceptance boundary

Developer architecture and automated regression gates are complete.

Native SP/MP acceptance remains user-owned and must verify save/reload, reconnect, representation transitions, body uniqueness, and interaction parity.
