# Reusable PsychopatzCore Radio OS — Progress Ledger

**Planning update:** 2026-10-15
**Baseline at planning:** DynamicTrading `da480d5ef91e18bbbcdfe80c79e5523356e13cca`; PsychopatzCore `ff7ce885eed29fa5f42b1a5223e39144982c8049`. Rechecked before implementation; unrelated worktree changes were preserved.

## Current status

R0–R7 are implemented and verified at source, asset, and offline-Lua levels. Native singleplayer, dedicated multiplayer, and profiler acceptance remain open for user-run in-game verification. R9 cleanup/readiness is therefore not complete; this ledger does not claim production readiness.

## Commits

- PsychopatzCore: `832a7e7` (`Add reusable radio OS foundation`)
- ProjectHoomans: `c96cadda` (`Integrate Hoomans contacts with radio OS`)
- DynamicTrading: pending final ledger commit for this milestone.

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

## Known limitations / baseline failures

- Core composition smoke currently fails its pre-existing profiler bootstrap load-order assertion (`tests/psychopatz_core_composition_smoke.lua:80`); the new radio OS is client-only and does not modify shared composition order.
- DynamicTrading full suite has the pre-existing `dt_caravan_contract_smoke.lua` assertion for missing `groupSize = GROUP_SIZE`; all other 12 of 13 discovered tests pass after the radio security gate fixtures were updated with an active-radio mock.
- Offline translation smokes may log the expected `getModFileReader_unavailable` message; catalog parsing/parity and fallback behavior pass.
- Native Build 42 UI load, dedicated MP, reconnect/walk-away/device-off cases, and performance measurements remain acceptance gates.

## Next chunk

Record the exact commits, then incorporate user-run native SP/MP/profiler evidence. Keep the legacy DTAbstract preview fallback until Core-only and combined native consumers are verified; do not claim readiness before R8 passes.
