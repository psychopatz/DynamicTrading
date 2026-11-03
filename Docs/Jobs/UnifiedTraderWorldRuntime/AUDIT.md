# Audit — Unified Trader World Runtime

## Audit snapshot

Date: 2026-11-03

This document now records the post-implementation ownership audit.

## Verdict

**The commercial trader-world lifecycle is unified under DTCommon.**

DTAbstract and DTHoomans no longer own parallel population, destination, arrival, cooldown, or exchange lifecycles. They expose representation, movement, and presentation capabilities through registered seams.

## Final ownership

### DTCommon

Owns:

- trader record and actor binding metadata;
- stock, budget, quotes, and trade authority;
- settlement market and exchange;
- trader population intent;
- route and destination intent;
- commercial journey and location state;
- exactly-once arrival and visit history;
- cooldown and scheduling;
- provider registration;
- representation transition policy;
- common actor projection and client trader presentation;
- common contact and action construction;
- optional-adopter integration and trade-presentation registries.

### DTAbstract

Retains:

- abstract Core actor and journey execution;
- map overlay;
- nearby discovery and notifications;
- radio adapter;
- Debug Manager and abstract debug actions.

It no longer contains a commercial lifecycle or provider handoff orchestrator.

### DTHoomans

Retains:

- Hoomans faction, caravan, merchant, and guard construction;
- Hoomans body lifecycle and physical provider mechanics;
- mobile-group travel execution;
- resident excursion participant travel;
- Hoomans settlement geography;
- physical access, display-name, capacity, portrait, conversation, and trade-window integration.

Its settlement arrivals and resident commercial state feed the common DTCommon lifecycle.

## Removed duplicate ownership

Deleted production modules:

- DTAbstract_Lifecycle.lua
- DTHoomans_CaravanLifecycle.lua
- DTAbstract_Handoff.lua
- DTAbstract_ProjectionServer.lua
- DTAbstract_PresentationClient.lua

The former DTAbstract projection source was replaced by one provider-agnostic DynamicTrading projection owned by DTCommon.

## Source audit result

Current source audit finds:

- zero DTAbstract to DTHoomans production references;
- zero DTHoomans to DTAbstract production references;
- zero PNC, DTHoomans, or DTAbstract implementation references in DTCommon production Lua;
- one commercial lifecycle tick in DTCommon_TraderWorldRuntime;
- one separate bounded representation-maintenance tick in DTCommon_TraderRepresentationRuntime;
- no old lifecycle, handoff, or adopter-owned projection files.

Remaining calls from DTHoomans into DTCommon are explicit adapter-to-domain calls, such as reporting an authoritative Hoomans settlement arrival to the common arrival API.

## Representation and recovery audit

Verified:

- one trader identity and one Core actor survive provider transitions;
- temporary materialization records the origin provider;
- native physical caravans do not receive a fabricated return provider;
- failed materialization rolls the lease back and clears temporary metadata;
- missing-body recovery returns to the recorded origin provider;
- physical projection uses live body position and does not interpolate a stale abstract journey;
- dematerialization rebases the same canonical journey from the physical body's final position.

## Resident trader audit

Resident traders are a world role, not a separate lifecycle.

DTCommon owns their commercial destination and location state. Hoomans continues to own excursion participant travel, visit timing, return-home execution, and safety mechanics.

The real cross-adopter hot-plug matrix verifies PREPARING, OUTBOUND, VISITING, RETURNING_HOME, AT_HOME, save/reload reconstruction, and grounded destination dialogue.

## Interaction audit

Radio contact duplication was consolidated into DTCommon_TraderContacts.

Physical-only behavior remains adapter-owned:

- live body;
- distance;
- trader role and faction checks;
- portrait;
- physical trade window.

DTCommon client transport no longer directly knows PNC inventory UI.

## Validation

- DynamicTrading: 59/59;
- changed production Lua luac parse: 43 files pass;
- installed-PZ Kahlua verification: 43 files pass;
- focused Core regressions: pass;
- focused Hoomans commercial/mobile regressions: pass;
- real cross-adopter hot-plug matrix: pass;
- Hoomans aggregate: 982/987 with five unrelated semantic or harness failures.

## Remaining risk

Only native Project Zomboid acceptance remains for SP, MP/reconnect, save/reload while materialized, body duplication, and presentation parity.

Two unrelated mod.info edits remain intentionally outside this goal.
