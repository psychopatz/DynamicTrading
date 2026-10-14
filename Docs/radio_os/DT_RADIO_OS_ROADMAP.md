# PsychopatzCore Radio OS — Roadmap with Mandatory UI Stabilization

**Owner:** PsychopatzCore for platform/UI and reusable assets; ProjectHoomans for contacts/conversations; DynamicTrading for trader/scanner and server commerce. This roadmap preserves original R0–R9 as historical full-feature milestones. **New priority on 2026-10-15 is U0–U7 UI stabilization.** R0–R7 are recorded as implemented at source/offline test level, but screenshot proves R2/R3 UI acceptance failed. Do not restart old R0–R7 from scratch. Work unattended in small verified commits, keep this repo's progress ledger current, and defer new non-UI features until U0–U4 are stabilized.

## Current priority — UI Stabilization U0–U7 (read first)

Canonical detailed acceptance plan: `psychopatzCore/Docs/radio_os/CORE_RADIO_OS_UI_STABILIZATION.md`.

| Phase | Work | Acceptance (offline + normal-game native separately) |
|---|---|---|
| **U0 — NEXT** | Fresh audit / regression reproduction of unmovable shell, hardcoded scales, overflow, unused app.icon, nonclickable LCD | Source traces and FAIL-FIRST tests; no gameplay edits before diagnosis |
| U1 | Drag shell without pressing buttons, uniform aspect-ratio resize, screen clamping and saved geometry/scale | Offline geometry/input tests + user/native move/resize/reopen evidence |
| U2 | Font-measured viewport, paging, clipping and responsive rows at realistic LCD scale | No text, sprite or portrait bleeds from LCD; long names and localization handled |
| U3 | Draw real icon atlas, UI chrome and button hover/pressed/disabled state art | Command-level sprite assertions plus actual visible icon/button screenshot |
| U4 | Mouse-clickable app/contact/action rows and synchronized physical/keyboard focus | Resize doesn't shift hitboxes; click/Back/scroll/paging and list refresh work |
| U5 | Portrait child clip/lifecycle, honest provider call UI | Real allowed identities work, unsupported dialogue remains disabled |
| U6 | Core/Hoomans/DT integration and security regression | V2 trade screen unchanged; abstract vs physical merchant permissions preserved |
| U7 | **Normal Project Zomboid** SP/MP acceptance and bounded profiling | Six skins, resolutions, movement/persistence, icons/input/portrait and MP access tested with screenshots/logs; unmet native gates remain pending |

**Do not use the PZ Headless Harness.** It is explicitly broken, and is not an allowed diagnostic, launch, repair or test mechanism. Offline Lua, static atlas validation and **normal user-run game sessions** are allowed. The agent should implement and commit safe offline U0–U7 work unattended, prepare one consolidated user testing checklist if it cannot use the game's desktop, and **never label native passes from mocks**. Read the existing Core window geometry/persistence helpers before attempting a base-class change; keep the radio visually frameless.

### Gate precedence

R0–R7 = earlier implementation work completed at source/offline level; R2/R3 native UI acceptance is reopened by U0–U4. R8/R9 and any production-ready label are **blocked** until the relevant U milestones pass actual native SP/MP acceptance. Do not confuse feature completion with usable UI.

---

## R0 — Fresh multi-repo audit and baselines (historical)

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

Report U# (or historical R#), owning repo(s), exact files/behavior, test commands and evidence class (source/asset/Lua/normal-game native SP/native MP/profiler), commit SHA + push status, remaining blockers, precise Next Chunk. Continue automatically without repeated consent for safe work.
