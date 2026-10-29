# Community Excursions & Commercial Trader Mobility

## Purpose

This phase connects the accepted settlement market/event engine to believable trader movement without making Dynamic Trading a second NPC AI.

There are two distinct trader lifecycles:

1. **settlement-owned resident trader** — a normal Project Hoomans settlement member whose default state is home and who only leaves rarely for a purposeful commercial excursion;
2. **base-less roaming trader/caravan** — an independent mobile trader faction with no home community whose default state is perpetual travel/roaming.

The generic movement/social foundation belongs to Project Hoomans. Dynamic Trading contributes commercial opportunity, merchant stock, market exchange, and commercial intent.

## Current audited baseline

DynamicTrading audit baseline:

`9ee65f0be58bdea00a1f1532173ec9fa8afee021`

Project Hoomans local audit discovered:

- generic mobile settlement departure/arrival infrastructure already exists;
- long-distance settlement travel is intentionally abstract;
- live/materialized Hoomans behavior is used for local roaming, interaction, combat, and nearby activity;
- `PNC.MobileSettlementVisitService` owns settlement visit/admission lifecycle;
- `PNC.HomeDutyService` already owns player-colony return-home travel/retry semantics;
- communities expose durable `community.id`, `community.home`, and site/home data;
- abstract groups may carry `homeCommunityId`, but the current generic `RETURN_HOME` score does not prove the target settlement is that exact home community;
- a generic arrival observer was added locally in Project Hoomans commit `2200b866`, but at audit time it was not present on any remote branch.

Recheck all of this before implementation because Project Hoomans is concurrently changing.

## Critical discovery: current DT caravans bypass settlement hopping

Dynamic Trading currently generates roaming caravans with:

```text
mobilePathMode = random
mobileControlMode = strategic
```

Project Hoomans' ordinary daily settlement-departure path only considers ambient street-roaming mobile groups. Therefore DT caravans do not currently participate in the generic settlement-to-settlement selector under normal production configuration.

Do not solve this by adding DT-owned movement. Extend the Hoomans commercial-mobility contract so a trader caravan can participate in settlement travel while Hoomans remains the final travel/destination authority.

## Critical discovery: admission is not a commercial visit

Current Hoomans mobile settlement travel has purposes for:

- `settlement_admission`;
- `hostile_contact`.

Neutral AI-settlement arrival under `settlement_admission` can transfer visiting members into the destination settlement. The configured default AI join chance is 35%.

That is valid for refugees seeking a home and invalid for a trading caravan.

A commercial visit must never accidentally absorb the trader or guards into the destination faction.

## Long-distance / live simulation boundary

Preserve the current scalable split:

```text
LIVE / MATERIALIZED
local roaming
conversation
trade
combat
nearby behavior
        |
        | long-distance objective
        v
ABSTRACT
cross-map travel
travel time
encounter resolution
destination progression
        |
        | local relevance / arrival
        v
LIVE / MATERIALIZED
```

Do not require physical full-map pathfinding for caravans or resident-trader excursions.

## Generic Project Hoomans excursion model

Do not implement "trader went on a trading run" as a Dynamic Trading-only state.

Project Hoomans should own a purpose-agnostic temporary community-member excursion model.

Conceptual state:

```lua
excursion = {
    id = "...",
    active = true,

    homeCommunityID = "...",
    homeFactionID = "...",

    participantIDs = { "npc_..." },
    purpose = "commercial_run",

    phase = "PREPARING",
    destination = {
        kind = "settlement",
        communityID = "..."
    },

    itinerary = { ... }, -- bounded; optional
    currentLeg = 1,

    startedAt = ...,
    expectedReturnAt = ...,
    updatedAt = ...,
    revision = ...,

    public = {
        status = "preparing",
        reason = "trading_run"
    }
}
```

Exact storage shape is implementation-defined, but it must remain bounded, versioned, and Hoomans-owned.

### Required phases

At minimum:

```text
AT_HOME
  ↓
PREPARING
  ↓
OUTBOUND
  ↓
VISITING
  ├─ next approved stop → OUTBOUND
  └─ route complete → RETURNING_HOME
  ↓
RETURNING_HOME
  ↓
AT_HOME
```

Also support terminal/recoverable failure state without inventing stock changes.

### Generic lifecycle events

Expose reusable lifecycle notifications/facts such as:

```text
COMMUNITY_MEMBER_EXCURSION_STARTED
COMMUNITY_MEMBER_EXCURSION_DESTINATION_CHANGED
COMMUNITY_MEMBER_EXCURSION_VISIT_STARTED
COMMUNITY_MEMBER_EXCURSION_RETURNING
COMMUNITY_MEMBER_EXCURSION_COMPLETED
COMMUNITY_MEMBER_EXCURSION_FAILED
```

Names may follow existing Hoomans conventions, but consumers must not poll movement internals.

## Generic non-admission settlement visit

Add a Hoomans-owned temporary settlement visit purpose that is distinct from admission.

Conceptually:

```text
travel.kind = settlement
travel.purpose = settlement_visit
visit.intent = commercial
```

The exact field names may differ, but the semantics are mandatory:

- `settlement_admission` may transfer eligible members;
- `settlement_visit` is temporary and never transfers faction/community membership;
- visit intent is extensible for future commercial, diplomatic, social, resupply, or other temporary purposes;
- relationship/hostility checks, encounter deferral, pending arrival, visit expiry, and LOD behavior should reuse existing Hoomans machinery.

Do not special-case Dynamic Trading inside generic Hoomans visit resolution.

## Base-less roaming trader lifecycle

A roaming DT caravan:

- has no `homeCommunityID` and no hidden/imaginary faction base;
- remains a mobile trader faction;
- is never admitted/absorbed just because it commercially visits another settlement;
- may visit AI settlements and player settlements when safe and worthwhile;
- keeps exact DT merchant stock between stops;
- performs one bounded DT market exchange on each accepted commercial arrival;
- resumes roaming/chooses another commercial destination after the temporary visit;
- never needs a return-home phase.

Current DT caravan source comments that say a caravan leader "stays at the base" or describe a future idle-at-base variant are stale relative to this approved base-less lifecycle. Correct those comments/assumptions during M10; do not invent a base or offscreen leader merely to satisfy old comments.

Target behavior:

```text
local roaming
  ↓
commercial destination evaluation
  ↓
abstract travel
  ↓
encounter/failsafe handling
  ↓
commercial settlement visit
  ↓
DT market exchange
  ↓
temporary local presence
  ↓
leave / next opportunity
```

### Destination ownership

Hoomans owns:

- candidate settlement discovery;
- reachability;
- distance;
- danger/threat;
- diplomacy/hostility;
- final target selection;
- travel state.

Dynamic Trading may register a bounded commercial score/provider that contributes:

- carried stock vs destination demand;
- destination scarcity/surplus;
- price opportunity;
- active market event opportunity;
- trader specialization;
- recent market history.

Hoomans must not require Dynamic Trading to load.

### Recent-visit memory

Add bounded anti-ping-pong memory so caravans do not bounce continuously between the same two settlements.

Keep only a small bounded history/recent-visit penalty, not an unbounded route journal.

Player settlements should be evaluated as commercial markets under the same safety/opportunity contract rather than targeted merely because they contain a player.

## Settlement-owned resident trader lifecycle

A resident trader:

- remains a member of its original settlement faction/community throughout the excursion;
- defaults to home, not travelling;
- leaves rarely and only for a meaningful purpose;
- must not convert the whole settlement faction into a mobile faction;
- keeps the same exact DT trader record and merchant stock;
- becomes physically unavailable at home while away;
- returns explicitly to its own home community.

Target behavior:

```text
HOME
 normal settlement/shop life
     ↓ rare approved commercial run
PREPARING
     ↓
OUTBOUND
     ↓
commercial settlement visit(s)
     ↓
RETURNING_HOME
     ↓
HOME
     ↓
optional final home-market exchange / recovery
```

### Rare-excursion gating

The first commercial policy should consider bounded factors such as:

- trader is actually at home;
- home settlement still exists and is active;
- no Follow Player override;
- no protected/critical local task;
- meaningful commercial opportunity exists;
- stock/budget is sufficient for a run;
- route is safe enough;
- trader has not just returned;
- home cooldown is satisfied.

Do not make resident traders behave like perpetual caravans.

### Home target

Return home must target the **exact home community**, resolved from Hoomans community/site/home data.

Do not rely on the current fuzzy abstract `RETURN_HOME + any settlement` score as proof of home routing.

Reuse Hoomans travel/retry/failure principles. If the home target becomes invalid, excursion failure/displacement is a Hoomans lifecycle concern; Dynamic Trading must not silently teleport the merchant home.

## Semantic/public status contract

Semantics should read social truth, not travel internals.

Expose generic Hoomans queries such as the conceptual equivalents of:

```lua
PNC.CommunityExcursions.GetPublicStatus(npcID)
PNC.CommunityExcursions.GetCommunityAbsences(communityID)
```

The public result should provide stable social meaning such as:

```text
status = away
reason = trading_run
phase = visiting
destinationKnown = true
destinationCommunityID = ...
expectedReturnAt = ...
```

Do not expose every internal route field to ordinary dialogue.

### Knowledge visibility

The semantic/knowledge layer decides what a speaker actually knows.

Examples:

- faction leader may know route and ETA;
- ordinary local may know the trader is away and rough destination;
- outsider may know only that the trader is not currently here;
- future relationship/knowledge rules may disclose more.

The first proof should demonstrate that a local asking/answering "where is the trader?" can consume authoritative excursion status without hard-coded DT movement checks.

Dialogue wording remains downstream semantic realization; do not hard-code a fixed sentence in the excursion service.

## Future invitation seam

This phase does **not** require a complete "send your trader to my settlement" UI or semantic action.

However, the architecture must leave a stable request/suggestion seam so future systems can submit a commercial destination request without directly commanding movement.

Conceptually:

```text
player/semantic request
    ↓
commercial visit request / route suggestion
    ↓
trader/faction policy evaluates
    ├ relationship
    ├ distance
    ├ danger
    ├ economic opportunity
    ├ current excursion
    ├ home needs/cooldown
    └ route availability
    ↓
accept / reject / defer
```

The semantic layer may submit a request later; Hoomans/faction AI remains decision authority.

## Failure and interruption rules

Preserve existing Hoomans safeguards and extend them generically:

- active encounter may defer arrival;
- stale pending arrival must cancel if the group moved;
- destroyed/invalid destination triggers alternate-target or return-home policy;
- resident trader Follow Player must not be silently overwritten by an automatic excursion;
- protected facility/work activity must not be destroyed by mobility reconciliation;
- duplicate arrival/visit IDs must not duplicate DT exchange;
- commercial visits never trigger admission member transfer;
- save/reload must preserve excursion identity/phase/home/visit idempotence;
- no excursion failure may reroll merchant stock.

## Performance invariants

- no per-frame global destination solver;
- no all-settlement market scan for every live NPC;
- no full MarketSense registry scan per route decision;
- route scoring is bounded/cached;
- long-distance travel remains abstract;
- recent-route history is bounded;
- excursion state is compact;
- semantic public status is a query/projection of authoritative state, not a second persistence store.

## Non-goals for this phase

- full player commercial-invitation UI;
- authored dialogue library for every excursion state;
- faction macroeconomy;
- physical warehouse simulation;
- escorts as a mandatory resident-trader feature;
- physical full-map walking between settlements;
- replacing Hoomans travel/encounter/LOD authority;
- converting every settlement resident into a mobile group.
