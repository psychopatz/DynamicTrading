# Reusable PsychopatzCore Radio OS — Progress Ledger

## NEW current work — A0 device-family asset architecture (2026-10-15)

**Next task: A0** from `psychopatzCore/Docs/radio_os/CORE_RADIO_DEVICE_ASSETS.md`, followed by A1–A2 technical refactor before **A3 US Army pilot artwork**. The user approved decoupling shell artwork **by individual radio model and by family**, specifically all walkie variants PLUS HAM and manpack. Shared UI widget atlases, Radio OS app/contacts API, Core-owned renderer, Hoomans NPC provider and DTCommon V2 commerce stay unchanged.

**Repository source audit at planning:** Core main `13d8aefbd23b17b41cac5f5e7cebe48a5e61626e` (latest UV gutter fix); DynamicTrading main `0672ddb3ee3494977049f326d6776eb56440f3b4`; Hoomans `c96cadda1570f59810552f9d3fc55d5c957ba670`. Recheck immediately on start. No asset or code changes are part of this goal-document commit.

**Existing implemented baseline:** Core has LCD matte/backdrop sandwich, measured six walkie apertures, responsive zoom and smokes, with recent 1px UV gutter repair. Legacy shell art still comes from **341×341** reduced source enlarged into a 1024×1024 six-shell atlas, which irreversibly lost detail. Renderer/zoom improvements do NOT manufacture missing source fidelity. Normal-game native acceptance remains open.

**Planned target:** individual high-detail transparent master and PNG per model, per-model aperture/backdrop/content and variable-control mappings, optional pristine/scratched/worn/damaged overlays derived from valid item condition where appropriate, shared five UI atlases. Six walkies (current manifest IDs) plus **HAM** candidates (`HamRadio1`, `HamRadio2`, `HamRadioMakeShift`) and **manpack** candidate (`ManPackRadio`) are mandatory; confirm exact Base fullTypes, capabilities, graphics, portable/placed behavior from actual installed Build42 before implementation. Do NOT reuse three-key walkie schema for HAM/manpack.

**Proposed per-chunk gates:** A0 evidence table -> A1 v2 schema compatibility -> A2 isolated art pipeline and alpha/quality tests -> A3 US Army image-approval checkpoint -> A4 individual remaining walkies -> A5 HAM -> A6 manpack -> A7 variants -> A8 native SP/MP and legacy cleanup. Missing authentic high-resolution source must be reported as an art blocker; never claim upscaling the compact sheet is a high-detail replacement. No shell art has been changed by this documentation update.

**Absolute prohibition:** PZ Headless Harness. Offline Lua/Pillow tests and normal game testing only, native results pending until actual evidence. Commit each validated owner-local change safely; no overwriting saved games or unrelated files, no force pushing. Maintain existing DT/Hoomans security/trade regressions; do not build a second trade UI.

---

## C0–C3/C4 offline stabilization checkpoint — 2026-10-15

Core-owned compositor and adaptive-scale work is implemented and pushed in
PsychopatzCore `6c20a47` (`feat(radio-os): layer LCD compositing and adaptive zoom`).
DynamicTrading, ProjectHoomans, and MarketSense source ownership is unchanged.

### C0 audit and reproduced cause

The renderer already attempted `screen_bg_<theme>`, so the failure was not an
absent background draw. Pillow inspection of the checked-in 1024×1024 shell
atlas found the complete connected alpha-zero LCD apertures are larger than the
safe content rectangles:

| skin | content viewport | measured aperture |
| --- | --- | --- |
| Toys | 90,236,81×61 | 88,232,90×81 |
| Valutech | 85,236,82×61 | 82,232,96×81 |
| Premium | 81,236,83×61 | 80,232,102×81 |
| Tactical | 99,246,81×55 | 97,231,93×81 |
| US Army | 107,247,72×55 | 97,234,93×81 |
| Makeshift | 86,247,79×55 | 83,231,99×81 |

The prior renderer backed only the first column, leaving transparent pixels in
the intended aperture able to expose the game world. `lcdBackdrop` metadata now
covers the measured aperture while `screen` remains the inset content/portrait
viewport. Exterior shell transparency is not filled.

### C1–C4 offline implementation/evidence

- The Core renderer now draws an explicit device-local sandwich: opaque theme
  matte, themed LCD sprite, stencil-clipped dynamic page/status, optional
  scanlines, then the transparent shell and physical controls. Portrait child
  rendering is wrapped in the same safe viewport stencil; screen-render errors
  clear the stencil before returning. Pixel-snapped rectangles use the same
  scale transform for LCDs, controls, shell destination, and hitboxes.
- Settings is discoverable from Home and exposes translated Zoom +, Zoom −,
  Reset Zoom, and Fit Screen rows. Limits derive from available viewport with
  90% width / 82% height safety margins and are exercised at 1280×720,
  1920×1080, 2560×1440, and 3840×2160. Position/scale persistence remains
  player/device scoped through Core UI settings. Resolution changes re-clamp
  the open window without resetting the saved preference.
- `OS.SetCompositorDebug(true)` is an opt-in, non-persisted development probe;
  normal gameplay keeps it disabled. It outlines shell destination, matte
  aperture, content viewport, and physical hitboxes.
- New offline Pillow test:
  `python3 tests/radio_os/psychopatz_radio_os_compositor_smoke.py` → PASS;
  six synthetic RGBA composites prove opaque matte coverage and exterior
  transparency, plus alpha-hole, UV-cell, scaled geometry, and button checks.
- Compact production builder now fails if any of the six measured alpha-hole
  bounds drift. Rebuild command → `PASS: 1024x1024 / 6 walkie shells /
  alpha-zero LCD openings / valid cells`. Checked-in and rebuilt shell PNGs
  are pixel-identical; both SHA-256 values are
  `6aac44ea4c6de17a4ff2ea13f8b6cddd50b432f02700a5258bb7b2f0a5ebfb9d`.
- Core offline Lua smokes pass: manifest (6 skins/132 sprites), window,
  registry, and action. The window smoke now asserts matte-first ordering,
  stencil cleanup after an intentional render failure, aperture containment,
  adaptive limits, resolution clamping, settings actions, drag/resize ratio,
  device-scoped persistence, and native-host restoration. Offline translation
  mocks may print the known `getModFileReader_unavailable` diagnostic.
- Changed Core Lua files pass `luac -p`; `pz_verify` reports zero Kahlua
  errors and zero hardcoded UI strings in the Radio OS directory. The token
  report still warns on the large manifest/device/renderer files; this is a
  maintainability warning, not a failed compatibility check.

### C2 source-fidelity result and native boundary

Core and the historical DynamicTrading DTAbstract copies of all seven radio
PNGs are byte/pixel-identical. The accessible project trees contain the
341×341 compact source and deterministic 1024×1024 output, but no authentic
1448×1086 master required by the high-resolution builder. No unrelated artwork
was substituted; fine-detail recovery remains an art-source blocker.

No normal Project Zomboid gameplay, SP/MP session, screenshot, console.txt
capture, or profiler run was performed in this chunk. The prohibited PZ
Headless Harness was not used. Native C5/C6 acceptance therefore remains
pending and must be verified in normal Build 42 gameplay.

### Commit/push and next task

- PsychopatzCore `6c20a47` pushed `main → origin/main`.
- DynamicTrading documentation is the only DT change in this checkpoint; it
  does not alter DTCommon, DTAbstract, or DTHoomans behavior.
- Next: run focused DT/Hoomans/Core integration regressions against the pushed
  Core, then perform the consolidated normal-game checklist for all six skins,
  Home/Contacts/Settings/Trader Scanner, portrait containment, scale controls,
  console.txt, and profiler evidence. Keep native SP/MP/profiler claims
  separate from offline evidence.

## C6 offline integration checkpoint — 2026-10-15

The pushed Core was exercised without modifying any consumer ownership:

- Core radio regression set passed: radio manifest, OS window, OS registry,
  OS action, the new Pillow compositor smoke, deterministic compact-shell
  rebuild, and the existing Core radio action/device/frequency/image/custom
  radio smokes. Expected offline translation-manager diagnostics were observed
  where the game file-reader API is unavailable.
- DynamicTrading focused checks passed: `dt_radio_os_app_smoke.lua`,
  `dt_radio_os_physical_provider_smoke.lua`, `test_DTA_Walkie_Manifest.lua`
  with the shipped manifest path, and `test_DTA_RadioOSPreview.lua` with its
  explicit module/manifest paths. The full `python3 tests/run_tests.py
  --verbose` result is 12/13; the one failure is the pre-existing
  `dt_caravan_contract_smoke.lua` assertion requiring `groupSize = GROUP_SIZE`.
- ProjectHoomans `python3 tests/run_tests.py radio` is 5/5. Direct
  `pnc_radio_os_provider_smoke.lua`,
  `pnc_radio_discovery_presentation_smoke.lua`, and
  `pnc_radio_relay_commands_smoke.lua` also pass. No Hoomans or DT gameplay,
  provider, settlement, inventory, or trader code was altered.

DynamicTrading documentation remains pushed at `2ba5e756`; Core remains pushed
at `13d8aef`; Hoomans and MarketSense worktrees remain clean and unchanged.
Native Build 42 SP/MP visual acceptance and profiler evidence are still open:
these Lua/Pillow checks are offline evidence, not native evidence.

## C2 UV-gutter follow-up — 2026-10-15

The C2 atlas audit found a one-pixel alpha fringe in the compact shell atlas's
inter-row gutter at y=464. Core commit `13d8aef`
(`fix(radio-os): isolate shell atlas UV gutters`) clears only the atlas gutter
in the existing production builder and regenerated PNG. Pixel comparison
against the previous Core atlas reports exactly 108 changed pixels, all on row
464; no shell-cell, content viewport, or LCD aperture pixel changed.

The rebuilt artifact and checked-in artifact are deterministic and share
SHA-256 `8aa544733b2256ddec0182cc3ecbdd7562bc1c30b94b8e050704e5644843557b`.
The six-shell Pillow compositor smoke now also checks transparent themed LCD
background alpha and all shell UV gutters. Core manifest/window smokes still
pass. The normal-game texture-filter result remains unverified until a regular
Build 42 session; no global texture-filter setting was changed.

Core `13d8aef` is pushed to `origin/main`. The historical DTAbstract copy is
left untouched because Core is the production asset owner; DynamicTrading
does not load the Core shell atlas through a second renderer.

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

## Consolidated user-run native acceptance checklist (pending)

Run this only in a normal Project Zomboid Build 42 desktop session with a fresh,
disposable save. Do not use the PZ Headless Harness or treat offline mocks as
native evidence.

1. **Six-shell baseline:** with PsychopatzCore alone, test `Base.WalkieTalkie1`
   through `Base.WalkieTalkie5` and `Base.WalkieTalkieMakeShift`. Open each from
   native Device Options → Radio OS and verify the complete shell, opaque LCD,
   readable content, buttons, LEDs, Home, Contacts, Settings, back navigation,
   close/reopen behavior, and no game-world bleed through the aperture.
2. **Responsive geometry:** at 720p, 1080p, 1440p, and 4K where available,
   capture screenshots before/after Zoom In, Zoom Out, Reset Zoom, and Fit to
   Screen. Verify constant aspect ratio, aligned shell/LCD/portrait/buttons and
   hitboxes, bounded clipping, drag/resize behavior, and position/zoom persistence
   after close/reopen and resolution changes.
3. **Pages and Hoomans:** exercise Home, Contacts, Settings, Trader Scanner, and
   Contact Detail with long lists and pagination. With ProjectHoomans enabled,
   verify real authorized NPC names/status/portraits stay inside the LCD and that
   `call_contact` queues the existing request without fabricating dialogue.
4. **Trading ownership:** with DTCommon/DTAbstract/DTHoomans enabled, verify
   remote trader eligibility and the Radio OS Trader Scanner hand off to the
   existing V2 trading UI. Verify physical merchant interaction and proximity
   denial while moving out of range; do not open a second trading window or alter
   authoritative settlement/inventory behavior.
5. **Multiplayer:** repeat the Core, Hoomans, and trading flows on a normal
   dedicated server with the same mod set using two independent players. Test
   reconnect, radio/device off, walking away, and portrait/contact refresh.
6. **Evidence:** preserve timestamped screenshots, the relevant normal-game
   `console.txt` scan (including RadioOS and ExceptionLogger errors), and a
   bounded PsychopatzCore profiler summary covering Contacts, Trader Scanner,
   row navigation, trade handoff, range exit, and reconnect. Record SP, MP, and
   profiler results separately; all native acceptance remains open until these
   artifacts exist.

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


## Confirmed PsychopatzCore media-path convention (2026-10-15)

The project already stores reusable `Radio/Signal_found` and Conversation backgrounds under `PsychopatzCore/common/media/ui`. As requested, active Core Radio OS texture PNGs were **moved byte-for-byte** from `42.20/media/ui/psychopatz/radio` to `common/media/ui/psychopatz/radio`, with unchanged virtual `getTexture("media/ui/psychopatz/radio/...")` names. Any new walkie, HAM, manpack, condition-variant or animated LED runtime PNG must be exported to `Contents/mods/PsychopatzCore/common/media/ui/` using actual package-relative virtual texture paths. Version-specific Lua remains under `42.20/media/lua` where appropriate.

Eleven unapproved 1254x1254 original concept sheets have **not** been pushed as binaries. Their validated import target is `Contents/mods/PsychopatzCore/common/media/ui/Radio/DeviceConcepts/`, strictly **non-runtime staging**; they are not sliced and must not be registered as renderable skins before validation. The compact legacy 341px builder input belongs in `art_source/radio/legacy`, not a runtime texture path. Source provenance and native gameplay acceptance remain separate gates. No PZ Headless Harness.
