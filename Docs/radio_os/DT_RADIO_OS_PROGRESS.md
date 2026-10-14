# Reusable PsychopatzCore Radio OS — Progress Ledger

**Planning update:** 2026-10-15
**Baseline at planning:** DynamicTrading `da480d5ef91e18bbbcdfe80c79e5523356e13cca`; PsychopatzCore `ff7ce885eed29fa5f42b1a5223e39144982c8049`. Rechecked before implementation; unrelated worktree changes were preserved.

## NEW next chunk — C0: LCD alpha, source fidelity and adaptive scale (2026-10-15)

**Current task for Luna: C0** per `psychopatzCore/Docs/radio_os/CORE_RADIO_OS_COMPOSITOR_SCALE.md`, followed by **C1–C6 unattended**. This supersedes previous instruction at the bottom to wait for native U5–U7 checks. Preserve U0–U4 already implemented and tested offline.

**Latest Git main at this audit:** Core `87d16a3117c3dba689627c6a3167313bb0b8590e`, DynamicTrading `1fd47cac048502a838fbfbcf1c79a12dce4facd7`, Hoomans `c96cadda1570f59810552f9d3fc55d5c957ba670`. Recheck HEAD/worktree before editing.

**New real-game screenshot evidence:** US Army radio can be moved to a new position and Home/Contacts render more coherently, but shell looks extremely coarse, opaque display backing does not visibly fill the apparent window, the LCD looks cut out from the world, cropping/alpha seams are visible, and a user-visible size/zoom control remains absent. This is **failed native visual acceptance**; do not mark rendering/persistence complete merely from code/mocks. Screenshots do not independently reveal whether an actual backplate is missing or its bounds are too small.

**Source-confirmed observations:**
- Core `Renderer.lua::drawScreen` **already tries** to draw a themed `screen_bg_<theme>` sprite before dynamic UI, then shell in `render()`; real issue must be isolated with per-skin alpha coverage, texture opacity and lifecycle tests.
- US Army safe LCD manifest viewport is `{107,247,72,55}` at 256×432 shell coordinates. Visible aperture vs recorded safe content viewport may differ; test rather than assume.
- `tools/radio_os/build_dtabstract_walkie_shells_compact.py` enlarges a **341×341 downsampled compact source to 1024×1024**. It cannot restore original high-frequency art. The alternative high-resolution builder expects a missing/not-bundled 1448×1086 approved concept source; recover an authentic master only if available.
- `RadioOSWindow_Input.lua` and `_Geometry.lua` now include dragging, corner resizing, persistence and `applyScale`; `RadioOSDevice.lua` still defaults to scale ≤1.75 and the Open path clamps to 0.75–2.25. Make user zoom discoverable and max viewport-aware instead of claiming resizing doesn't exist.

**Execute next:** Add C0 source and alpha-mask comparison for six skins; compare intended hole, overlay screen viewports and BG opacity; add deterministic Python synthetic compositing smoke and optional native debug tint/outline probe (off by default). Then C1 sandwich, C2 genuine asset fidelity investigation, C3 zoom/fit controls, C4 alignment tests, C5 legibility/portrait and C6 normal-game acceptance. **Core owns these changes**; DT Common/Hoomans keep business logic.

**No PZ Headless Harness**: prohibited. Offline Lua/Pillow/contract tests and normal Project Zomboid SP/MP only. If no GUI access, finish and commit all safe offline work and prepare one consolidated user-run screenshot/console.txt test, leaving native unverified.

**Expected checkpoint format:** current C#, changed files by owning repo, exact offline tests, atlas/alpha pixel evidence, actual native screenshots/profiler if any, commit SHAs/push status, known missing high-res source, next C#.

---

## Earlier priority update — failed in-game UI acceptance (2026-10-15)

**Current next phase: U0 → U1 UI stabilization, not native R8 sign-off and not redoing R0–R7.** Source baseline at user report: Core `832a7e750bed35f42478416f5ed86a8dea141f1f`; DynamicTrading `017d739333d95b19ba927a54be6788daece705ff`; ProjectHoomans `c96cadda1570f59810552f9d3fc55d5c957ba670`. Recheck current HEAD before Luna edits.

**User-provided in-game evidence:** US Army walkie radio OS visibly renders but overlays the vanilla radio controls, cannot be dragged or dynamically resized, loses usual Core geometry/scale persistence, LCD shows crowded/overflowing text and **registered app icons are not rendered**. This is not a successful native functional acceptance; previous R2/R3 UI-gate completion claims are reopened.

**Source-confirmed causes:** Core `PsychopatzRadioOSWindow.lua` derives from bare `ISPanel` rather than integrating existing window geometry helpers; `_Input.lua` consumes non-control clicks but does not drag/resize; `_Pages.lua::drawHome` draws only labels and attempts three rows on the tiny LCD; the separate app registry has icon IDs that are not drawn in Home. Mouse-clickable LCD rows, clipped child portraits and provider pagination also require test coverage. Preserve the six atlases and existing provider/commerce APIs.

**Mandatory plan:** `psychopatzCore/Docs/radio_os/CORE_RADIO_OS_UI_STABILIZATION.md` defines U0–U7. U0 = fresh source re-audit + FAIL-FIRST offline tests; U1 = frameless dragging/scale/geometry persistence; U2 = measured LCD content/paging/clipping; U3 = actual atlas icons/widgets/states; U4 = clickable on-screen controls; U5 = portrait/call UI; U6 = integration regression; U7 = normal-game SP/MP/profiler acceptance. Complete U0–U4 before more feature expansion. Keep native assertions pending until user screenshots/console logs or real desktop game runs prove them.

**Testing rule:** DO NOT install, launch, query, fix, or rely on the **PZ Headless Harness** (broken). Run ordinary Lua/unit/atlas tests unattended. Native means a normal Project Zomboid game session, not a harness/mock. If agent lacks desktop access, provide a single short manual checklist and continue independent safe work without repetitive permission prompts.

**Next chunk for Luna:** U0. Inspect clean worktrees/current source and Core `PsychopatzWindow_{Geometry,Responsive,Persistence,Controls}.lua`; write failing/guardrail geometry, input, icon-render and viewport tests; then proceed directly to U1. After each validated chunk record tests/evidence, affected SHAs, whether pushed, known blockers and next U#.

## Historical implementation status (source/offline only)

R0–R7 were implemented and tested at source/asset/offline-Lua levels, **but native UI testing revealed serious failures**. Their functional GUI acceptance is reopened as U0–U7. Native SP/MP/profiler pass is not established; R9 readiness is blocked.

## Commits

- PsychopatzCore: `832a7e7` (`Add reusable radio OS foundation`)
- ProjectHoomans: `c96cadda` (`Integrate Hoomans contacts with radio OS`)
- DynamicTrading implementation: `d7fed399` (`Integrate trading with reusable radio OS`).

## Completed checkpoints

- **R0 — audit:** Core `RadioDeviceState`, `RadioActions`, `RadioSignalHost`, `PortraitPanel`, Hoomans discovery/call boundaries, and DTCommon/DTAbstract/DTHoomans trade paths were audited. Native Build 42 `ISRadioWindow` device fields and Core Java/UI drawing signatures were checked separately. Graph coverage was checked for the relevant indexed code; excluded media paths were read directly.
- **R1 — shared assets:** six walkie skins, six atlases plus compact source, generators, validation tests, and the manifest now live under Core `42.20/media/ui/psychopatz/radio` and `UI/Radio/OS`. Pixel equivalence and six LCD alpha cutouts passed. DTAbstract retains a thin manifest/preview fallback during compatibility transition.
- **R2/R3 — Core OS:** bounded model, namespaced app/provider registry, device registry, translation facade, renderer, clipped LCD, navigation/input, generic Contacts/detail/portrait slot, Settings, and extension pages were split into Core modules. Custom-app movement has a regression smoke. Core has no consumer dependency.
- **R4 — Hoomans:** `projecthoomans:contacts` translates the authoritative bounded WorldDiscovery snapshot and delegates `call_contact`; refresh is event-driven and discovery is not represented as speech. The old duplicate Contacts radio action was removed.
- **R5/R6 — trading:** DTCommon registers the bounded Trader Scanner app; DTAbstract registers the remote trader provider and uses the existing V2 `OpenTrader` handoff. Abstract snapshot/commit access now requires a real active Core radio; stale/forged client mode is not an authority source.
- **R7 — physical trading:** DTHoomans registers a physical-only nearby merchant provider. It filters live bodies, Hoomans `trader` role, faction binding, READY state, and distance on the client for presentation; the server rechecks live body, role, faction, position, and distance at snapshot/commit. Guard referral remains separate. Nearby in-person access does not require a radio; remote abstract access does.
- **Localization:** Core `EN/TL Core.json` and DTCommon `EN/TL Trading.json` are valid and key-parity checked. Core/DT/Hoomans UI strings use shared translation facades.

## Evidence

- **Asset:** Core manifest smoke: 6 device skins / 132 sprites; deterministic builders are pixel-equivalent; six shell alpha-hole validations pass; copied atlas hashes match the DTAbstract sources.
- **Offline Lua:** Core registry/window/action/manifest smokes pass; DT scanner/provider/access focused tests pass 7/7; Hoomans targeted discovery tests pass 9/9 and its provider smoke passes 1/1. The complete DT suite is 12/13 with only the pre-existing caravan-contract assertion failing. New Core, DT, and Hoomans Lua paths compile with `luac`; new paths pass the applicable Kahlua and i18n checks. The Core OS token scan leaves only the intentional manifest data file over the 2,000-token threshold.
- **Translation:** Core and DTCommon EN/TL catalogs parse with equal key sets; pz-verify i18n reports no hardcoded UI strings in the new Core OS, DTCommon scanner, DTHoomans provider, or Hoomans adapter.
- **Native SP/MP:** user-run in-game acceptance checklist provided; screenshots/logs are still pending. Offline mocks are not native evidence.
- **Profiler:** user-run combined radio/contact/trader workload is still pending.

## User-run native acceptance checklist

1. In a fresh singleplayer test save, enable PsychopatzCore alone and test `Base.WalkieTalkie1` through `Base.WalkieTalkie5` plus `Base.WalkieTalkieMakeShift`. Turn each device on, set volume above zero, unmute the microphone, open native `Device Options`, and open `Radio OS`. Verify the shell, readable LCD, controls, Home, Settings, Contacts, back navigation, and close/reopen behavior.
2. Enable ProjectHoomans with Core. Tune an active radio to `69000` and wait for discovery, or use the authorized Hoomans map Discovery debug action to reveal all signals. Open Radio OS → Contacts, verify names/status/portraits, and confirm `call_contact` reports a request without fabricating a conversation.
3. Enable DTCommon/DTAbstract/DTHoomans. Test a READY abstract trader while farther than the physical range; Radio OS → Traders must hand off to the existing V2 trade UI. Test a live nearby Hoomans trader; it must appear and hand off in range, then disappear or be denied when the player moves away or disables the radio. Guards/referral-only contacts must not trade.
4. Repeat the Core, Hoomans, and trading flows on a dedicated multiplayer server with the same mod set, including reconnect and two independent players.
5. With the Core profiler GUI connected, capture a workload that opens Contacts and Traders, moves through rows, performs a trade, moves out of range, and reconnects. Preserve screenshots or bounded profiler summaries plus the relevant `console.txt` error scan.

## U0–U4 — Radio OS UI stabilization slice (2026-10-15)

- Canonical `CORE_RADIO_OS_UI_STABILIZATION.md` was fetched from Core origin at `2d6c4e2` and read before this continuation. The implementation follows its U0–U4 requirements; native gates remain open.
- PsychopatzCore `c59286a` (`Stabilize Radio OS window interactions and LCD layout`) plus `87d16a3` (`Harden Radio OS geometry, paging, and sprite caching`) add frameless shell-region dragging, uniform ratio resizing, resolution clamping, player/device-family/skin-scoped geometry persistence, native-host hiding/restoration, measured/clipped LCD typography, responsive pagination, cached atlas sprite definitions/textures, direct screen hit-testing, bounded contact-provider paging, selection preservation, and a separate portrait/contact-detail module.
- DynamicTrading `6e6b50e0` (`Make trader scanner rows directly clickable`) keeps the trader scanner on the existing V2 provider handoff and adds direct row hit-testing. `80227347` records the preceding progress checkpoint; the current focused smoke also covers bounded provider pagination.
- Focused evidence: Core window/registry/action/manifest smokes pass; Core and DT changed Lua files pass `luac`; Core and DT focused Radio OS/provider smokes pass; `git diff --check` passes; PZ verification reports zero hardcoded UI strings and zero Kahlua issues in changed paths. Core token scan now leaves only the pre-existing manifest data file above the warning threshold. Native SP/MP and profiler evidence remain pending.
- Offline translation mocks may log the expected `getModFileReader_unavailable` message. Offline tests are not native evidence.

## Known limitations / baseline failures

- Core composition smoke currently fails its pre-existing profiler bootstrap load-order assertion (`tests/psychopatz_core_composition_smoke.lua:80`); the new radio OS is client-only and does not modify shared composition order.
- DynamicTrading full-suite execution remains non-green for pre-existing/configuration cases: `dt_caravan_contract_smoke.lua` lacks `groupSize = GROUP_SIZE`; the Hoomans bridge fixture path is absent; `tests/test_DTA_RadioOSPreview.lua` has its existing invocation assertion; and `test_config` exits without output. Focused Radio OS tests pass.
- Native Build 42 UI load, six-device visual/manual acceptance, dedicated MP/reconnect, walk-away/device-off, portrait rendering, and profiler measurements remain open. No headless harness was used.

## Next chunk (superseded by C0)

Prior normal-game native handoff was pending. **Use the NEW next chunk at the top: begin C0 immediately** and continue to C6, then revisit U5–U7 and R8/R9 verification without claiming native success from mocks.
