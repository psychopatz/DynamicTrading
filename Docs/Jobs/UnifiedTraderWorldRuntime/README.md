# Unified Trader World Runtime

## Parent objective

Consolidate DynamicTrading so **one provider-agnostic DTCommon trader-world runtime** owns canonical trader lifecycle and commercial world behavior.

`DTAbstract` and `DTHoomans` become representation/interaction adapters:

- DTAbstract: abstract/Core journey presentation, map/nearby/notification/radio UI.
- DTHoomans: physical Hoomans body/caravan/faction/travel/NPC integration.

The same trader retains one trader record, one Core actor, one journey intent, one stock/budget state, and one settlement-visit history regardless of representation.

## Current status

**ACTIVE — architecture consolidation required.**

The previous DTAbstract production recovery is accepted foundation. It fixed map ownership, client projection, persistence, Debug Manager behavior, and production provider handoff.

A 2026-11-03 follow-up audit found the deeper split:

- DTCommon already owns most commercial truth;
- DTAbstract still owns an independent population/routing/journey/arrival lifecycle;
- DTHoomans still owns a parallel caravan population/travel/arrival lifecycle;
- remote and physical interaction adapters duplicate contact/action presentation;
- DTCommon still contains direct adopter knowledge (`PNC`, `DTHoomans`, hard-coded provider assumptions).

The next goal is removal of the parallel trader-world systems.

## Accepted foundation

Preserve:

- Core canonical actor/world/journey/provider lease;
- Core synchronized client projection and single map host;
- DTCommon trader record, stock, budget, quote/trade authority, settlement market/exchange, talk service, world knowledge, and settlement directory;
- production abstract↔physical provider handoff;
- DTHoomans physical body/caravan/faction integration;
- DTAbstract map, nearby discovery, notification, radio, Debug Manager, and projection presentation.

## Completion boundary

Developer-side completion requires:

- one DTCommon trader-world lifecycle;
- no independent spawn/routing/arrival/cooldown commercial lifecycle in both adopters;
- provider changes alter representation, not trader identity/state;
- common interaction/contact/action models are shared;
- DTCommon no longer directly requires optional Hoomans implementation globals where a provider seam can own them;
- redundant lifecycle code is removed after migration;
- standalone DTAbstract still works without Hoomans;
- DTHoomans physical traders consume the same canonical runtime;
- abstract↔physical handoff preserves trader/actor/journey/stock/budget/visit identity;
- SP/MP, save/reload, reconnect, and performance gates pass.

## Target shape

```text
PsychopatzCore
  generic actor/world/journey/provider mechanisms
                     |
                     v
                DTCommon
        canonical Trader World Runtime
        trader/commercial state authority
                     |
          +----------+----------+
          |                     |
     DTAbstract             DTHoomans
     provider/UI            provider/UI
     abstract view          physical NPC view
```

A trader is never intrinsically an “abstract trader” or a “Hoomans trader”. Those are representations/providers.

## Document map

- `AUDIT.md` — source-backed duplication/adopter-leak findings.
- `ARCHITECTURE.md` — target ownership and provider contracts.
- `ROADMAP.md` — mandatory consolidation phases.
- `HARNESS_ACCEPTANCE.md` — proof required before consolidation is accepted.
- `AGENT_RUNBOOK.md` — execution and repository safety.
- `PROGRESS.md` — current phase and immediate next chunk.

The conversational `/goal` bootstrap remains outside the repository.
