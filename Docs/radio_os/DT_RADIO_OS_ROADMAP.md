# DTCommon Radio OS — Unattended Roadmap / Acceptance Gates

Work through R0–R9 in order, skipping only an honestly blocked native subgate while continuing safe independent tasks. At every step update PROGRESS, tests, and safe commit/push. Retain the existing trading /goal separately; this is **not** a rewrite of the MVP quote/settlement roadmap.

## R0 — Fresh audit and tests (next chunk)

- Inspect HEAD/working tree, 3 modules, six atlas SHA/PNG dimensions/alpha, manifest, old preview, workflows and current test runner.
- Audit actual Build42 ISUI subtexture draw signature, scissor/clip API, input handling; PsychopatzCore RadioActions, UI components/portrait; Hoomans NPC/dialogue providers and trade endpoint; DTCommon snapshot/access gates and DTHoomans merchant/guard proximity.
- Reproduce existing abstract inventory radio fullType bug (Base.WalkieTalkie vs WalkieTalkie1–5/makeshift) in a test. Add no gameplay fix until source contract is understood.
- Baseline full tests and separately record offline Lua/native environments, file owners, public compatibility APIs and module load combinations.
- Gate: dated audit and failing/protective tests, no speculative code transplant.

## R1 — Move assets and shared ownership into DTCommon

- Relocate all six PNGs, production manifests, atlas helpers, builders/CI workflows and preview host to a DTCommon-owned /RadioOS namespace and ui path; do not load DTAbstract to display them.
- Keep thin DTAbstract compatibility if other code references OpenPreview or the DTA_* manifest; do not create duplicate runtime texture buffers.
- Fix import/init ordering, module-required dependencies, and all six item ID mappings. Ensure all 6 PNGs load, proper source UV and alpha center, no runtime file collisions for DTCommon-only and combined installs.
- Gate: DTCommon can resolve every asset without DTAbstract; manifest and PNG tests; exact counts; old preview either redirects safely or is explicitly retired with covered tests.

## R2 — Neutral widget renderer and navigation core

- Build reusable DTCommon.RadioOS registry, window, device skin lookup, screen clipping, atlas subtexture draw helper, focus/key/mouse/softkey, history/back and page transitions. Client-only; no trades yet.
- Static Home/Contacts/Scanner/Call/Settings demo pages with explicit nonfunctional states (never fake authorized contacts).
- Modular button state backgrounds, icons/indicators, dynamic localized text; portrait is a provider widget, not tied to PNC at DTCommon import.
- Verify tiny LCD at normal game scale, page/scroll/zoom or better art screen bounds as required. Avoid duplicated windows, oversize menus, click-through, clipped text.
- Gate: all six handheld shells and buttons respond in native SP when possible; offline state-machine tests pass.

## R3 — Common providers and authoritative access

- Specify server-to-client contact list/action capability and session contract; implement in DTCommon with bounded payloads and honest loading/denial.
- Authenticate/authorize player, source provider, trainer/trader ID, NPC (physical), and radio device (remote) at discovery/snapshot/trade; no spoofed mode override or guessable trader ID.
- Preserve existing DTCommon execute/basket/currency paths, and isolate any migration of existing RequestTrader/TradeBasketRequest permission checking behind regression coverage.
- Sessions bounded, expiring and revoked on disconnect, out-of-range, inactive radio or despawn; no permanent ModData sessions.
- Gate: forged remote physical NPC access and abstract absent-device requests are rejected server-side; existing trading smoke tests remain green.

## R4 — DTAbstract entry and remote adapter

- Introduce actual six-item two-way radio resolver and, where warranted, world placed/equipped radio support based on verified vanilla APIs; do not invent HAM shells.
- Open shared DTCommon Radio OS from legitimate DTAbstract remote context/RadioActions entry. Support real abstract contact in the **absence of a spawned NPC**.
- Scanner lists only eligible trader contacts without leaking blocked NPCs; device power/frequency/battery display only when backed by data.
- Gate: abstract-only installation opens common UI, can scan/open authorized trader (existing commerce view), rejects no-radio/offline, and does not require PNC.

## R5 — DTHoomans physical entry and NPC context

- Reuse PNC.ContextHub merchant provider and PNC ConversationOutcome. Add/shared UI action where appropriate without breaking immediate Trade or guard referral. No mandatory radio for face-to-face NPC trade.
- Server-validate merchant NPC role, presence/live-interactable body, <= documented interaction distance, identity and status at each snapshot/commit; no shared UI bypass or remote downgrade/escalation.
- Physical contact view is the common presentation/control architecture, not necessarily a physical radio shell when conversation is face-to-face.
- Gate: physical trader nearby works without DTAbstract; beyond proximity or wrong role denied; guard only refers, cannot trade.

## R6 — Real Contacts / Call / portrait integration

- Populate contacts by provider from authorized real identities, bounded list, selection, detail page, Call/Chitchat capability and stable cached UI updates.
- DTHoomans uses verified Project Hoomans conversation/portrait mechanisms; portrait rendering is clipped and low-cost. Show a graceful silhouette/abstract contact when no physical body or valid portrait is available.
- Implement chitchat only using existing authorized conversation API. No new LLM or semantic backend, no imagined synchronous radio voice.
- Gate: real physical contact opens an actual existing permitted conversation; contact without supported talk capability displays an honest disabled state. Confirm no portrait leak or load-order fault.

## R7 — Trader Scanner and V2 trade handoff

- Mode-appropriate scanner with load/unavailable/empty and sorting/paging; select a trader and open existing DTCommon.Client.OpenTrader(..., {mode="trade", npcID=... when physical}).
- Do not duplicate PNC.InventoryWindow.OpenTrade, DTCommon.TradeWindow, stock, quote or settlement.
- Gate: authenticated abstract trader with no NPC can trade; physical Hoomans requires nearby merchant; mixed baskets retain existing inventory state and validations; both adapters installed have no duplicate menu/side effects.

## R8 — Native gameplay and performance

- Native SP: each six walkie skins, idle/hover/pressed/disabled, font scaling/mouse input, available/offline states, portrait within cutout, app navigation.
- Native dedicated MP: authorization, two simultaneous players, correct NPC/trader scope, out-of-range, spoofed requests, replay, reconnect, stale stock and call/trade invalidation; no client-trusting data.
- Run tests/run_tests.py and relevant existing dt_trading_* smoke tests, plus new UI/offline Lua tests. Test module combinations and no compatibility regression.
- Use engine profiler/harness if accessible; record render, discovery, portrait updates, allocations/network volume. No per-tick full NPC scans.
- Gate: backed by real test logs and pass/fail matrix, not just mocks. Missing native environment => remain pending and report precise blocker.

## R9 — Hardening and release readiness

- Eliminate duplicate preview and stale DTAbstract-owned production asset paths after migration is safe. Confirm screenshots/atlas alpha, localization, settings, optional effects and fallback UI.
- Ensure data contracts, error codes and extension API are documented, with a compact extension recipe for HAM/manpack and future OS apps. Do not fake finishing unsupported hardware families.
- Gate: all mandatory gates R0–R8 evidenced, fresh integrated tests, clean startup and load order, safe commits/push, and explicit known limitations. Mark production-ready only when native SP and MP gates are satisfied.

### Checkpoint reporting format

Completed R#: files and behavior changed; evidence category and passing/failing tests; commit SHA / push status; risks/blocked gates; exact next R# chunk. Continue unattended to the next safe task without another user message.
