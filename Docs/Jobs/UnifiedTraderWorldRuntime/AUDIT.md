# Audit — Unified Trader World Runtime

## Audit snapshot

Date: 2026-11-03

DynamicTrading `main` inspected at `f9f228452ce2493bc91044569354d131905a40bb`.

Two unrelated/unexplained `mod.info` load-order edits remain unstaged and must be preserved unless separately resolved:

- `Contents/mods/DTAbstract/42.20/mod.info`
- `Contents/mods/DTHoomans/42.20/mod.info`

Accepted recovery foundation:

- PsychopatzCore `d7a892155e8e890b6af87d4b7a322f0ac3e62ec4`
- ProjectHoomans `564f3656f09b443dc0c2bcda8b9886905baf7152`
- DynamicTrading `f9f228452ce2493bc91044569354d131905a40bb`
- DynamicTrading recovery suite: 57/57

## Verdict

**Commercial state is substantially centralized, but trader-world lifecycle authority is still split.**

DTAbstract and DTHoomans are not yet merely two interaction/representation modes over one runtime. They still contain parallel decisions about trader creation, population, movement, arrival, and world progression.

## Already centralized correctly

DTCommon already owns:

- `TraderService` / `TraderRegistry`;
- stock and budget;
- quote/trade execution;
- MarketSense-backed pricing context;
- settlement market/exchange;
- market events;
- Core actor policy/binding metadata;
- trader settlement IDs;
- settlement directory;
- settlement visit/restock bookkeeping;
- talk/conversation service and world knowledge.

These are foundation to extend, not replace.

## Finding A — two trader-world lifecycles remain

### DTAbstract

`DTAbstract_Lifecycle.lua` independently owns:

- abstract population cap and spawn sequence;
- trader/Core actor creation;
- initial settlement selection;
- destination selection;
- journey start/advance;
- cooldown;
- arrival;
- settlement visit/exchange dispatch;
- periodic lifecycle tick.

### DTHoomans

Overlapping responsibilities remain across:

- `DTHoomans_CaravanLifecycle.lua`
- `DTHoomans_CaravanService.lua`
- `DTHoomans_SettlementVisit.lua`
- `DTHoomans_CommercialMobility.lua`
- `DTHoomans_SettlementTrader.lua`

They participate in caravan/trader creation, trader binding, mobility/destination policy, physical travel, settlement arrival, settlement visit/exchange dispatch, and periodic creation/binding checks.

The movement engines differ; the commercial/world lifecycle concept overlaps.

## Finding B — handoff bridges two lifecycle owners

The recovery correctly established:

`DTAbstract abstract -> DTHoomans materialized -> DTAbstract abstract`

with one Core actor/provider lease.

But each adopter still owns world-lifecycle assumptions. Target behavior is simpler:

- DTCommon owns canonical trader journey intent/state;
- provider transition changes representation/execution only;
- providers report progress/state through one contract.

## Finding C — interaction adapters duplicate common machinery

`DTAbstract_RadioOS.lua` and `DTHoomans_RadioOS.lua` both implement overlapping:

- trader enumeration;
- readiness filtering;
- paging/limits;
- market-event presentation;
- action descriptor construction;
- trade/talk invocation.

Physical body/role/distance/portrait checks are valid DTHoomans concerns. Common contact/query/action construction should be shared.

## Finding D — DTCommon still contains adopter knowledge

Direct references found include:

- `DTCommon_MarketEvents.lua` -> `PNC.Communities`;
- `DTCommon_SettlementMarket.lua` -> `PNC.Communities`;
- `DTCommon_TraderService.lua` -> `DTHoomans.Caravan`, `PNC.Registry`, `DTHoomans.ValidateTraderAccess`;
- `DTCommon_Client.lua` -> `PNC.InventoryWindow`;
- `DTCommon_CoreActorPolicy.lua` -> hard-coded DTAbstract/DTHoomans provider set;
- settlement defaults labeled as DTAbstract-owned despite living behind the common directory seam.

Not every identifier string is inherently wrong, but optional adopter implementation calls should move behind registered providers/resolvers/capabilities.

## Finding E — Hoomans-specific mechanics must remain adapter-owned

DTHoomans should continue to own:

- Hoomans faction/caravan/member generation;
- guard roles/equipment;
- Hoomans body lifecycle;
- PNC travel;
- physical position/body reconciliation;
- Hoomans settlement geography adapter;
- NPC role/conversation integration;
- portraits and other Hoomans presentation.

Commonization must not reimplement Hoomans inside DTCommon.

## Finding F — DTAbstract-specific presentation remains valid

DTAbstract should continue to own:

- abstract provider implementation;
- client projection consumption;
- world-map presentation;
- nearby discovery notification presentation;
- radio/notification shell;
- Abstract Trader Manager UI.

These are presentation/representation responsibilities, not duplicate commercial authority.

## Finding G — native acceptance follows consolidation

The old recovery reached native-acceptance handoff. This audit introduces new mandatory developer work.

Native acceptance is deferred until the unified runtime is complete. The old recovery matrix remains regression coverage.

## Required direction

Create one DTCommon Trader World Runtime with explicit ports for:

- representation/provider;
- movement/travel execution;
- population/spawn representation;
- settlement/geography;
- access/interaction eligibility;
- contact/presentation augmentation.

Then migrate both adopters and delete redundant lifecycle ownership.

Do not solve this by wrapping both existing lifecycles in another compatibility layer.
