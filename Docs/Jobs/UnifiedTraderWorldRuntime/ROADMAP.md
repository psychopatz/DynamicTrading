# Roadmap — Unified Trader World Runtime

## Parent completion boundary

DynamicTrading has one provider-agnostic DTCommon trader-world runtime. DTAbstract and DTHoomans are representation and interaction adapters, not parallel trader simulations.

**Developer status: COMPLETE. Native acceptance remains.**

## U0 — Characterization and ownership contracts

**COMPLETE**

Lifecycle authority, provider boundaries, adopter leaks, arrival semantics, contact duplication, persistence, and representation handoff were characterized before migration.

## U1 — DTCommon Trader World domain

**COMPLETE**

DTCommon owns bounded population, route intent, commercial journey and location state, arrival, exactly-once visit and exchange, cooldown, external journey state, and provider-independent queries.

Gate evidence: dt_trader_world_common_smoke.lua.

## U2 — Provider and representation registry

**COMPLETE**

Registered provider capabilities replace the hard-coded provider set. DTAbstract and DTHoomans register representation and movement capabilities. Representation switching is owned by DTCommon.

## U3 — Remove lifecycle authority from DTAbstract

**COMPLETE**

DTAbstract_Lifecycle, DTAbstract_Handoff, adopter-owned projection server, and adopter-owned projection client were removed. DTAbstract_TraderWorldProvider now owns only abstract representation execution.

## U4 — Remove lifecycle authority from DTHoomans

**COMPLETE**

DTHoomans_CaravanLifecycle was removed. Roaming caravan travel and resident excursions consume DTCommon route and commercial state while retaining Hoomans group and participant execution. Settlement arrivals enter DTCommon TraderWorld arrival authority.

## U5 — Unify interaction, contact, and access seams

**COMPLETE**

Common contact construction, integration adapters, and trade-presentation registration now live in DTCommon. Radio adapters contribute eligibility and presentation differences instead of duplicating canonical construction.

## U6 — Remove parallel and legacy code

**COMPLETE**

Source audit confirms:

- no DTAbstract and DTHoomans production cross-reference;
- no adopter implementation reference under DTCommon production Lua;
- one commercial lifecycle tick;
- old lifecycle, handoff, and adopter-owned projection files deleted;
- common projection source is DynamicTrading rather than adapter-owned.

## U7 — Regression, performance, and native handoff

### Developer gates — COMPLETE

- DynamicTrading full suite: 59/59;
- changed production Lua: 43/43 luac parse;
- changed production Lua: 43/43 installed-PZ Kahlua verification;
- git diff --check: pass;
- focused Core actor, provider, projection, and map regressions: pass;
- focused Hoomans mobility, excursion, and settlement regressions: pass;
- real cross-adopter hot-plug matrix: pass;
- Hoomans aggregate: 982/987, with five unrelated failures documented in PROGRESS.md;
- bounds, save and reload, hot-swap, failed materialization, physical-position projection, and optional-adopter isolation covered.

### Native acceptance — PENDING

User-owned matrix:

- standalone DTAbstract;
- DTHoomans physical traders;
- representation transitions;
- resident excursions;
- abstract and materialized save/reload;
- SP;
- MP, reconnect, and resync;
- no duplicate trader, body, or exchange;
- map, notification, radio, and NPC interaction parity.

## Stop condition

Developer implementation is complete. Do not create another consolidation phase unless native acceptance reveals a concrete defect.
