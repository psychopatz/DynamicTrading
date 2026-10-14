# Reusable PsychopatzCore Radio OS — Progress Ledger

**Planning update:** 2026-10-15
**Baseline at planning:** DynamicTrading `da480d5ef91e18bbbcdfe80c79e5523356e13cca`; PsychopatzCore `ff7ce885eed29fa5f42b1a5223e39144982c8049`. Rechecked before implementation; unrelated worktree changes were preserved.

## Immediate priority update — failed in-game UI acceptance (2026-10-15)

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

## U0 — Radio OS UI stabilization slice (2026-10-15)

- PsychopatzCore `737e3dd` (`Stabilize Radio OS window interactions and LCD layout`) adds player-local position/scale persistence, resolution clamping, uniform aspect-ratio resizing, shell-region dragging, native-host hiding/restoration, measured/clipped LCD typography, responsive row pagination, atlas-backed Home/list/button/status rendering, and direct screen hit-testing for Core pages and extension apps. The window smoke now covers drag, resize, restore, host replacement, Home/Contacts rows, provider actions, and custom-app screen callbacks.
- DynamicTrading `6e6b50e0` (`Make trader scanner rows directly clickable`) adds responsive trader-row rendering and direct row hit-testing while preserving the existing provider and V2 `OpenTrader` handoff. The DT app smoke covers the click path.
- Evidence class: source audit, offline Lua, `luac`, asset manifest, `git diff --check`, and PZ verifier. Core focused radio tests and DT focused radio tests pass; PZ verification reports zero hardcoded UI strings and zero Kahlua issues in changed paths. Native SP/MP and profiler evidence remain pending.
- The task-referenced `psychopatzCore/Docs/radio_os/CORE_RADIO_OS_UI_STABILIZATION.md` was not present in the checked-out workspace, so this slice follows the supplied U-roadmap text plus the available Core/DT contracts. Do not treat that missing document as native acceptance evidence.

## Known limitations / baseline failures

- Core composition smoke currently fails its pre-existing profiler bootstrap load-order assertion (`tests/psychopatz_core_composition_smoke.lua:80`); the new radio OS is client-only and does not modify shared composition order.
- DynamicTrading full suite has the pre-existing `dt_caravan_contract_smoke.lua` assertion for missing `groupSize = GROUP_SIZE`; all other 12 of 13 discovered tests pass after the radio security gate fixtures were updated with an active-radio mock.
- Offline translation smokes may log the expected `getModFileReader_unavailable` message; catalog parsing/parity and fallback behavior pass.
- Native Build 42 UI load, dedicated MP, reconnect/walk-away/device-off cases, and performance measurements remain acceptance gates.

## Next chunk

Continue U1–U4 offline stabilization as safely possible, then use normal Project Zomboid gameplay for native acceptance. Do not use the PZ Headless Harness or claim readiness before native UI and integration passes.
