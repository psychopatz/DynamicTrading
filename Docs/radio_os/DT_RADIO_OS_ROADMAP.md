# PsychopatzCore Radio OS — Multi-Repo Roadmap (R0–R9)

**Owner:** PsychopatzCore for platform and reusable assets; ProjectHoomans for contacts/conversations; DynamicTrading for trader/scanner and server commerce. This roadmap supersedes the previous DTCommon RadioOS implementation order. Work unattended in small safe validated commits across the owning repos. Do not stop between chunks merely because a suite passed. Maintain a single concise progress ledger in this repo.

## R0 — Fresh multi-repo audit and baselines (NEXT)

Inspect git status/HEAD and current checkout of PsychopatzCore, ProjectHoomans, DynamicTrading, MarketSense, and test harnesses. Verify all six source PNGs and alpha holes against manifest, native B42 `drawSubTexture`/clipping/hit-test API, dependency and mod load order. Inspect Core `RadioDeviceState`, `RadioActions`, `RadioSignalHost`, `PortraitPanel`; Hoomans `WorldDiscovery.CallContact/RadioScan`, conversation UI; DTCommon `OpenTrader`, `RequestTrader`, `validateAccess`, DTHoomans NPC map and DTAbstract broken `Base.WalkieTalkie` detection. Baseline existing tests and add defensive reproductions. **Gate:** actual ownership/dependency map and test evidence, no speculative implementation.

## R1 — Move shared art/tools/manifest into PsychopatzCore

Safely transfer all six production PNGs, compact source, relevant generator/CI and Lua manifest to Core-owned media/UI paths. Update checked manifest UV/paths and asset lookup without depending on DTAbstract or DTCommon. Keep thin legacy redirects until proven safe; remove duplicates once consumers switch. Confirm six LCD alpha cutouts, all sprite counts, texture lookups and Core-only mod loading. **Gate:** Core owns and serves all six textures independent of consumer mods; offline image and Core-only native smoke where available.

## R2 — Reusable Core radio renderer/window

Implement cached atlas renderer, clipped screen, physical shell, window lifecycle, scaling and readable LCD zoom, generic widgets, icons, status labels and modular button states, physical-button/mouse/keyboard navigation. Reuse and cooperate with Core vanilla radio UI action host. Start with Core-only Home/Settings and inert placeholders; fail closed if assets/device invalid. **Gate:** six skins, calibrated hitboxes/legible text, no duplicate host or click-through; offline and native B42 as available.

## R3 — Mod-agnostic app/contacts SDK in Core

Add namespaced `RegisterApp`, `RegisterContactProvider`, `Unregister`, `Open`, `GetDeviceContext` or appropriate Core-convention equivalents after audit. Generic Home, Contacts, Contact Detail, status and call-action presentation; lifecycle/disabled/loading/no-provider; bounded sorting/paging/caches and safe plugin failure. Create a minimal fake third-party plugin smoke fixture. **Gate:** Core loads and navigates without either consumer; dummy registered app/provider works; no business-logic dependency.

## R4 — Project Hoomans contacts/discovery adapter

Add Hoomans-owned Core plugin for actual known NPC/settlement/faction contacts. Reuse authoritative Hoomans WorldDiscovery `radio_scan`, `call_contact`/knowledge APIs; respect player discovery and multiplayer access. Attach verified Hoomans identity/portrait into Core's generic portrait slot. Review separate genuine NPC conversation capabilities, expose real chitchat only if implemented and authorized; discovery advancement is not dialogue. Preserve normal in-person NPC interaction. **Gate:** Core+Hoomans contacts work, no privacy/knowledge leak, empty/unavailable cases and legitimate action outcomes.

## R5 — DTCommon trading app and secure access bridge

DTCommon registers only the **trading app**, trader contact-action integration and V2 `OpenTrader` handoff. Audit current server RequestTrader/snapshot and ExecuteTradeBasket/commit access. Require authoritative provider-specific permission checks; `record.a==1` cannot silently grant device-independent remote trading, and a client "abstract" mode cannot bypass physical NPC. Preserve MarketSense, stock, basket, currency, existing Hoomans trade-mode UI, and old client behavior only where safe. **Gate:** forged IDs/device/mode denied server-side; existing trade regressions pass; no duplicate commerce UI.

## R6 — DTAbstract remote trader contact/scanner adapter

Register remote-eligible trader provider/Scanner in Core with actual six vanilla walkie IDs and verified `RadioDeviceState`/real item/power/two-way checks. A valid abstract trader may be contacted and traded even when no NPC body exists. Include server-side bounded remote scanner results, no contact leakage, expired/turned-off radio denials, no fake signal data. **Gate:** Core+DTCommon+DTAbstract installation works without PNC; absent NPC remote trade permitted only with valid access.

## R7 — DTHoomans physical trader/merchant adapter

Register physical merchant actions in the shared Core UI without taking UI ownership. Hoomans ContextHub/conversation remains the path for actual face-to-face merchant trade; server checks a real nearby merchant NPC, role and interactability **at each snapshot/commit**. Radio contact card must never turn Hoomans physical trade into remote trade. Guard referral stays referral. Preserve direct in-person trading even without an active radio. **Gate:** near merchant permitted, far/no body/wrong role denied; combined installation works without duplicate options and shared V2 trade UI is used.

## R8 — Native SP/MP and performance acceptance

Test six handheld shells against actual Build42 assets with portrait/video clipping, Home/Contacts/Scanner/Call/Settings, mouse/keyboard/softkeys, scaling, load combinations and PNC-independent Core startup. Test dedicated MP with two players, discovery/portrait privacy, abstract trader with no NPC, physical merchant walk-away, radio off, forged/stale/replayed sessions, reconnect, stale stock, basket and 100-NPC synthetic vs native profiling. No per-frame global scan, unbounded data, texture decode or polling. **Gate:** native SP and MP evidence separately logged and performance measured; mocks never substitute.

## R9 — API/docs, cleanup and readiness

Remove obsolete DTAbstract preview/art copies **only after** verified migration and consumers, document Core public API and third-party example, update paths/build workflows and localization, preserve legacy safe redirects as needed. Document HAM/manpack/receiver-only families as deferred artwork. Cross-repo regression suite, clean startup, safe commits/push. **Gate:** R0–R8 passed, native runtime acceptance and no unresolved blocking defects; otherwise honest partial status.

## Per-chunk checkpoint

Report R#, owning repo(s), exact files/behavior, test commands and evidence class (source/asset/Lua/native SP/native MP/profiler), commit SHA + push status, remaining blockers, precise Next Chunk. Continue automatically without repeated consent for safe work.
