# Dynamic Trading -> Core NPC Foundation: Adapter Contract

Status: planning only. Authoritative cross-repository job: https://github.com/psychopatz/psychopatzCore/tree/main/Docs/npc_foundation. This document is a handoff for DTCommon/DTAbstract/DTHoomans; it does NOT replace GOAL_PROMPT.md or Docs/trading/DT_TRADING_MVP_* and does NOT mark native T6 trade acceptance complete.

## Roles and dependency behavior
- DTCommon keeps authoritative trader ID, market stock/virtual goods, trader budget, MarketSense quotes, item/currency transaction, access policy, dedupe and trade revisions. Link traderID -> Core actorId. Do not equate merchant stock and Core personal NPC inventory.
- DTAbstract provides radio and nearby abstract merchant contact, generic Talk, and trading presentation only under server-authorized physical access or future explicit delivery/fulfillment. It must run with Core+MarketSense+DTCommon alone; no PNC import.
- DTHoomans provides optional Hoomans live-body and richer dialogue adapter. It reuses the canonical Core NPC data and DTCommon merchant ledger. Its current mod.info requires ProjectHoomans; preserve that dependency.
- Hoomans absent -> retain one actor with stable identity, appearance, clothing and personal equipment, relationship and journey. Hoomans enabled -> materialize the same data without NPC reroll or merchant duplication.
- Both frontends loaded -> one actorId, one traderID, one journey authority, one physical body lease and one interaction entry. Save/restart/load module switching must be lossless; in-process provider switching only when both adapters already loaded.

## Existing coupling to remove incrementally
DTHoomans_CaravanLifecycle currently creates/maintains PNC mobile factions; DTHoomans_SettlementTrader binds Hoomans-staffed settlements; DTHoomans_Server validates live merchant body/role. DTAbstract_Client enumerates radio traders and opens trade. DTCommon_TraderService currently validates nearby actor or active radio for snapshots/transactions; a radio may authorize direct settlement. Do not delete these guards; replace with server-controlled encounter/communication/fulfillment policies backed by Core position/presence and explicit trading modes.

## Merchant world behavior
- Merchant chooses eligible Core Location anchors/settlements and travels via Core Journeys. Location discovery and permissions are scoped; no magical omniscient map of all merchants.
- On arrival establish a bounded stop and optionally perform idempotent DTCommon restock after verified visit; no restock on simply opening UI. No Hoomans community director required for the DT-only case.
- Relationship snapshots from Core inform capped server-side DT buy/sell modifiers; MarketSense continues to own intrinsic value and DTCommon owns quote/revision/settlement. Avoid repeated trivial-trade reputation farming and stale quote commit.
- Map hover uses Core portrait from resolved appearance and clothes; nearby floating Talk invokes registered shared interaction provider; no duplicate shop/dialogue windows.
- Radio contact can talk at distance, but item and money exchange require local encounter or future separately implemented reserved delivery/pickup path. No item teleportation by merely possessing a radio.

## Mandatory compatibility and security checks
Core+DTCommon only; DTAbstract only (without Hoomans); DTHoomans only (with Hoomans); both enabled; switching via save/restart; Hoomans added/removed after migration; multiplayer with reconnect. Assert stable actor/trader/relationship/inventory/stock IDs and versions, no duplicate merchant stock or independent body simulation; test stale snapshots, remote commit rejection, invalid item identity, transaction rollback.

Existing Docs/trading/DT_TRADING_MVP_PROGRESS.md has open native SP/MP T6 gates; preserve them. No Workshop publish/re-publish or non-user live gameplay signoff. Initial work is Core P0A mapping and source-backed fixture, not a DT gameplay rewrite.

## Permanent Git policy and separate-goal status — 2026-10-20

**Create no new Git branches** for DT, Core or Hoomans integration. Use existing authorized `main` after actual status/upstream/worktree review; reconcile Hoomans' preexisting PR #4 only through safe existing-main integration, not by spawning a new merge/feature/PR branch. Follow root `AGENTS.md`. Preserve user history; no force, reset, blind pull or Workshop publication.

Core Foundation P1–P9 has source-backed developer acceptance on Core main and provider integration tests in DT/Hoomans, but this does NOT establish native SP/MP compatibility. Hoomans grounded NPC personal dialogue B0–B6 remains a separately unfinished goal. Do not retrofit personal Knowledge facts into DT merchant stock/budget or leak hidden backstory through provider projections.

## Portable Core conversation follow-on (2026-10-21)

The earlier Core actor/provider foundation is recorded developer accepted. The **NEW** Core-owned C1–C6 shared offline conversation/Knowledge/hot-swap goal is active and not yet implemented. Detailed DT adopter contract: `Docs/npc_foundation/PORTABLE_CONVERSATION_ADAPTER.md`. Canonical Core roadmap and one current C1 chunk: `psychopatzCore/Docs/portable_npc_conversation/`. Preserve the current DTCommon trade and MarketSense contracts. No new branches, no native Workshop actions, no committed `/goal` prompt; do not resurrect outdated Hoomans PR #4 merge instructions.
