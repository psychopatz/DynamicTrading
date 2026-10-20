# DynamicTrading Adoption — Core Portable Conversation (C1–C6)

**NEW, NOT YET IMPLEMENTED (2026-10-21).** Canonical goal under PsychopatzCore `Docs/portable_npc_conversation/` at docs baseline `b6cb206f42e7e8a754fcca47a8908442c3fa27e1`. Existing DTCommon stock/trade/pricing and DTAbstract Core actor lease implementations remain in place, and prior Core NPC Foundation P1–P9 is a completed foundation rather than acceptance of a portable talk system.

## Current code and required separation

- `DTCommon_CoreActorPolicy.lua` resolves the Core actor identity behind a trader record and uses Core Social for capped trade pricing. **TraderID remains DTCommon-owned**; actorID remains Core-owned. Stock/budget/quote revisions/commit validation remain DTCommon; do not move them into Core personal inventory.
- `DTAbstract_CoreProvider.lua` currently delegates actor projection and lease operations to Core; it does NOT implement or own a personal conversation engine.
- `DTAbstract_RadioOS.lua` registers `dynamictrading:remote_traders` Radio OS provider exposing `dynamictrading:trade` action only, not a shared Core Talk action in the audited source. It builds bounded, authenticated-ready contact lists through DTCommon. Preserve these access controls and existing trade UI, no magic remote item teleportation.
- DTHoomans remains the optional physical body/trader adapter when ProjectHoomans is installed; Core actor identity, history, social and player-specific Knowledge must be identical in abstract and physical modes.

## Implementation contract

1. Add a separately registered authenticated **Talk** capability to DTAbstract radio contacts. Bind `traderID -> actorID` server-side via existing DTCommon policy. Verify actor presence/radio range/access/channel, per-player persistent character identity and stale snapshot/revision. Call **Core shared Conversation.ProcessTurn** (name provisional until Core C3 contract) instead of a DT-specific semantic parser/response engine.
2. Use Core identity-seeded backstory, personality, relationships, per-player Knowledge and EN/TL response planning, whether or not Hoomans is installed. The Talk interface may be embedded in existing Radio OS conversation UI; do not build another Chat window that duplicates Core/Hoomans authoring policy or message queues.
3. DT-specific trader facts (trade hours, goods and negotiation) must be registered as *bounded, authorized capability/fact providers*. They may answer general informational questions through Core conversation but a trade commit must still pass DTCommon server stock/budget/quote/fulfillment authorization. Radio Talk does NOT authorize buying/removing physical items merely through dialogue. No inventory/stock mixing.
4. DTHoomans near-body Talk uses the SAME Core actor/player scoped conversation service, with Hoomans live context providers where available. Never spawn a second persona/backstory/relationship store for DT trader.
5. For `DTAbstract → DTHoomans → DTAbstract`, use Core provider lease revisions, server transition barriers and Hoomans lifecycle callbacks. Preserve actorID, traderID, body lease uniqueness, personal inventory, DT merchant inventory, player-specific Knowledge and bounded conversational commitments. Reauthorize channel permissions when moving between radio and nearby; handle failed/retried materialization without double side effects.
6. Supporting Core-only, Core+DTCommon+DTAbstract with NO Hoomans, Core+Hoomans+DTHoomans, and both providers is mandatory. Save/restart with Hoomans enabled/disabled; in-process provider switching only when adapters are loaded. No assumption PZ can hot-unload mods during runtime.
7. Extend the EXISTING Hoomans Semantic Lab and Lua worker for DT dependency combinations; verify real final NPC talk, source trace, locale and trade authority, two-player disclosure, provider lease, and no trade duplication. No separate DT parser/compiler/harness GUI. Tests include two different players sharing one trader actor and no leaked private Knowledge over Radio OS.

## Status, ownership, safety

New cross-mod C1–C6 parent goal IN PROGRESS; Core current C1 baseline first. DT adapter-specific implementation is scheduled for C4/C5, with DT-only baseline and cross-mod acceptance C6. This is a docs-only adopter contract; no new Talk action, tests, ModData migration or remote trade functions were implemented by this commit. Never create a Git branch; only existing `main` after safe status checks. Never check in `GOAL_PROMPT.md`. No agent native Project Zomboid SP/MP, Workshop, radio device visual live test or publishing.
