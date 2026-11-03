# Progress — Unified Trader World Runtime

## Parent status

**ACTIVE — trader-world authority consolidation required.**

The previous DTAbstract production recovery is accepted regression foundation. A follow-up audit found that commercial state is shared but trader-world lifecycle authority is still split between DTAbstract and DTHoomans.

Native acceptance is deferred until this consolidation is complete.

## Verified current truth

### Shared already

DTCommon owns trader records, stock/budget, quote/trade authority, market/pricing context, settlement market/exchange, visit/restock bookkeeping, settlement directory, Core actor policy metadata, and talk/world-knowledge services.

### Still split

DTAbstract independently owns trader population/spawn, destination selection, journey start/advance, cooldown, arrival, settlement visit/exchange dispatch, and lifecycle tick.

DTHoomans owns overlapping behavior through CaravanLifecycle, CaravanService, CommercialMobility, SettlementVisit, and SettlementTrader.

### Interaction duplication

DTAbstract and DTHoomans RadioOS adapters independently implement overlapping contact enumeration, paging, market-event projection, and trade/talk action construction.

### DTCommon adopter leaks

Current direct adopter knowledge includes:

- PNC community reads in market code;
- DTHoomans/PNC reads in TraderService;
- direct PNC trade-window usage in DTCommon client;
- hard-coded DTAbstract/DTHoomans provider assumptions.

These are mandatory audit targets. Remaining references must become data identifiers or explicit adapter/provider boundaries.

## Preserved recovery foundation

Do not regress:

- PsychopatzCore `d7a892155e8e890b6af87d4b7a322f0ac3e62ec4`;
- ProjectHoomans `564f3656f09b443dc0c2bcda8b9886905baf7152`;
- DynamicTrading `f9f228452ce2493bc91044569354d131905a40bb`;
- recovery DynamicTrading suite: 57/57;
- one Core map host;
- synchronized actor projection;
- production persistence;
- real DTAbstract Debug Manager;
- production abstract↔physical handoff.

## Current phase

**U0 — Characterization and ownership contracts.**

## Immediate Next Chunk

### U0A — lifecycle authority/parity characterization

Before moving production code:

1. map each DTAbstract/DTHoomans lifecycle transition to the canonical DTCommon state it mutates;
2. add fail-first tests for trader creation, route/destination intent, arrival, exactly-once settlement visit/exchange, cooldown/next route, and provider transition identity;
3. add a test that common-domain lifecycle works without Hoomans globals;
4. classify each adopter function as common authority to migrate, provider implementation to retain, presentation/UI to retain, or obsolete duplicate to delete.

Then continue automatically through U1–U7.

## Repository safety

Two unrelated/unexplained unstaged `mod.info` load-order edits must be preserved unless separately resolved:

- `Contents/mods/DTAbstract/42.20/mod.info`
- `Contents/mods/DTHoomans/42.20/mod.info`

Do not stash, reset, discard, or accidentally include them.

## Blockers

None currently identified.

## Completion reminder

A provider transition is not completion if DTAbstract and DTHoomans still own separate commercial lifecycle decisions.

Final architecture: one DTCommon trader-world authority and thin provider adapters.
