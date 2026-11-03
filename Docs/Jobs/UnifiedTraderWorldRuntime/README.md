# Unified Trader World Runtime

## Objective

Consolidate DynamicTrading so one provider-agnostic DTCommon trader-world runtime owns canonical trader lifecycle and commercial world behavior.

DTAbstract and DTHoomans are representation and interaction adapters over the same trader identity, actor, stock and budget, journey intent, and settlement-visit history.

## Status

**Developer implementation complete on 2026-11-03. Native SP/MP acceptance remains.**

The previous split lifecycle has been removed rather than wrapped.

DTCommon owns population, route intent, commercial journey and location state, arrival, cooldown, representation policy, common contacts, and common projection and presentation state.

DTAbstract owns abstract execution plus map, nearby, radio, and debug presentation.

DTHoomans owns Hoomans body, caravan, faction, mobile-group execution, resident participant travel, and physical presentation and integration.

Deleted obsolete production modules include DTAbstract_Lifecycle, DTHoomans_CaravanLifecycle, DTAbstract_Handoff, DTAbstract_ProjectionServer, and DTAbstract_PresentationClient.

## Validation summary

- DynamicTrading: 59/59;
- 43 changed production Lua files pass luac;
- 43 changed production Lua files pass installed-PZ Kahlua verification;
- Core focused actor, provider, projection, and map regressions pass;
- Hoomans commercial, mobile, excursion focused regressions pass;
- real cross-adopter hot-plug matrix passes;
- Hoomans aggregate is 982/987, with five unrelated semantic or harness expectation failures documented in PROGRESS.md.

## Remaining work

Native Project Zomboid acceptance only: standalone abstract, physical caravans, provider transitions, resident excursions, save/reload, SP, MP/reconnect, and duplicate identity and exchange checks.

## Document map

- AUDIT.md — implementation audit and ownership result.
- ARCHITECTURE.md — final ownership and contracts.
- ROADMAP.md — completed U0–U7 developer phases and native handoff.
- HARNESS_ACCEPTANCE.md — acceptance evidence.
- AGENT_RUNBOOK.md — durable execution and safety rules.
- PROGRESS.md — current state and native acceptance handoff.

The conversational goal bootstrap remains outside the repository.
