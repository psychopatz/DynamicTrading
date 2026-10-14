# PsychopatzCore Radio OS — Cross-Mod Integration and Authorization Contract

**Canonical platform ownership:** `psychopatzCore/Docs/radio_os/CORE_RADIO_OS_CONTRACT.md`.
This file covers consumer boundaries specific to Hoomans and DynamicTrading.
Previous DTCommon-owned Radio OS architecture was **superseded** on 2026-10-15.

## Platform versus feature

**PsychopatzCore** owns the radio device itself: six walkie shell skins and UI textures, manifest/device registry, rendering and clipping, usable radio inspection, reusable Home/Settings/Contacts shell, app and contact-provider registries, widgets/button states, navigation, input/focus/zoom, cached subtexture rendering, generic portrait slot, localization and extension API.

**Core never hard-requires Project Hoomans, MarketSense, DTCommon, DTAbstract, DTHoomans or a specific NPC/merchant system.** Core may expose "Contacts" as a generic app but does not contain gameplay knowledge or grant permission to call/trade. Providers register bounded contacts/actions into Core. A future third-party mod must be able to register its own radio app with only a Core dependency.

**Project Hoomans** owns who a player knows, discovered NPCs/settlements/factions, identity and portrait data, actual communication and conversation effects. Extend current Hoomans WorldDiscovery `RadioScan`, `RadioAmbient` and `CallContact` contracts via a Core contact provider. Do NOT mistake their discovery transitions for full speech. If a genuine voice/chat action is not supported by existing Hoomans APIs, show it as unavailable until implemented in Hoomans, not in Core.

**DTCommon** registers trader app/interface and connects a Core radio contact to the **existing** Dynamic Trading V2 commerce path; retains MarketSense pricing, stock, quotes, snapshot routing, basket, settlement and multiplayer authorization. No custom Radio OS graphics, no second merchant/shop window, and absolutely no DT-specific code in Core.

**DTAbstract** implements remote radio trader discovery and access; can contact/trade with an abstract/virtual trader even without a spawned NPC *only when server-side eligibility and device/session checks pass*. **DTHoomans** implements physical merchant adapter; an in-person trade requires a valid, nearby interactable actual merchant NPC and proper Hoomans rules. The same Core contacts presentation may show NPCs but cannot bypass physical-trade distance simply because radio was opened. Preserve guard referral.

Hoomans radio contacts and Hoomans in-person trading are different operations: a remote contact/discovery entry does not by itself authorize in-person merchant trading. Future truly remote NPC conversation features require separate explicit Hoomans authority, not automatic access to existing local dialogue.

## Extension API goals (proposals, verify against existing Core)

```lua
-- Names and callbacks are illustrative, not currently implemented:
PsychopatzCore.RadioOS.RegisterApp({
    id = "dynamictrading:traders",
    ownerModID = "DTCommon",
    icon = "icon_trader",
    isAvailable = function(context) return ... end,
    open = function(context, navigator) ... end,
})
PsychopatzCore.RadioOS.RegisterContactProvider({
    id = "projecthoomans:npc_contacts",
    ownerModID = "ProjectHoomans",
    list = function(context, page) return ... end,
    resolve = function(context, contactID) return ... end,
    invoke = function(context, contactID, actionID) return ... end,
})
```

Registration should allow plugin removal/unload, deterministic ordering, a bounded contact model, provider-owned status and action capabilities. A Core contact entry may contain a generic optional portrait descriptor but must not carry PNC records, merchant stock or large ModData. Namespaced IDs prevent contacts from multiple mods colliding. Core widgets display actual provider facts rather than generating artificial signal/battery/contact permissions.

The DTCommon trader app uses Core's optional `hitTest` and `onScreenClick`
presentation callbacks so a visible trader row is directly clickable. The callback
only selects the bounded provider snapshot and then delegates through the existing
V2 `OpenTrader` path; it does not create a second trade screen or authorize access.

## Server authority / sessions

Core radio device inspection is a shared utility and UI precondition. **Every consequential action is validated by the owning server service.** The client may request a contact/scan/call/trade; it may never self-assert authorization, NPC proximity, radio power, trader access, mode, prices or inventory state.

- **Hoomans** checks learned contact/discovery state, actor permissions, NPC identity, and actual supported call/dialogue constraints.
- **DTAbstract** checks player radio (using Core's real device validation where appropriate), authorized remote trader, READY state and scoped session/request; no physical NPC required.
- **DTHoomans** checks actual NPC merchant identity, role, presence/live interactability and distance for in-person trade, including snapshot and settlement; guard is referral-only.
- **DTCommon** checks these authorization results at RequestTrader/snapshot and ExecuteTradeBasket/commit; replay/stale credentials, forged IDs or changing from physical to abstract must not bypass access. Present code allows `record.a==1` via `TraderService.validateAccess` without independent actual-device validation, so audit and add regression coverage.

Do not invent unguessable tokens if native primitives aren't verified. Use bounded server-maintained sessions or independently revalidate, with expiry/disconnect/revocation, and fail closed. Existing DTCommon Client.OpenTrader -> PNC.InventoryWindow.OpenTrade (when installed) or DTCommon fallback remains the trade handoff; no new transaction code is part of the Radio OS.

## Atlas ownership migration

The following **six actual production PNGs**, current manifest and optional preview are in the DynamicTrading repo under `DTAbstract/42.20/media/`, but their final owner will be Core:
- `shells/DTA_Walkie_Shells.png`: 1024×1024 / 6 radio bodies
- `ui/DTA_Walkie_UI_Core.png`: 1024×1024 / 25 UI sprites
- `ui/DTA_Walkie_Buttons.png`: 1024×512 / 36 button states
- `ui/DTA_Walkie_Icons.png`: 512×512 / 32 icons
- `ui/DTA_Walkie_Indicators.png`: 512×256 / 25 states
- `ui/DTA_Walkie_Overlays.png`: 512×512 / 8 subtle effects

Migrate **binaries, builder scripts, CI asset generation, manifest, tests and renderer** to `PsychopatzCore/42.20/media/ui/psychopatz/radio` and `PsychopatzCore/UI/Radio/OS` (actual naming after Core source audit). Verify PNG hashes/alpha, correct atlas lookups and Core-only game load before removing original DTAbstract assets. Never make a runtime `require` from Core into DTAbstract, or duplicate texture loads long-term. Existing DTA names may remain during compatibility transition; Core path is authoritative.

Walkie LCD holes span roughly 72–83×55–61 source pixels. This is insufficient for a large portrait + several text lines at native size; require actual B42 zoom/readability tests, screen clipping and compact app layouts. Assets are **art-ready for the first walkie prototype** but not native-accepted production UI. HAM/manpack and receive-only skins are not yet produced; support them by later registering device-family manifests, never falsely claim complete artwork.

## App behavior

- Core Home/Settings and generic Contacts viewer work with zero providers (honest empty/inert state).
- Hoomans contact provider lists only known/authorized entities; can use a nearby NPC's verified portrait through Core portrait panel; an unspawned abstract contact uses a neutral identity fallback unless its source supplies a valid descriptor.
- Call/Chitchat action delegates to a *real supported* provider call/dialogue API; a WorldDiscovery `call_contact` result that updates phase is not automatically an NPC speech session.
- Trader Scanner is a **Dynamic Trading app** registered in Core; bounded source-authenticated trader list, status and access. Clicking Trade opens existing V2 trade UI separately; radio screen never paints buy/sell grids or stock.
- Status, battery, signal and frequency display measured game data (or "unknown"). Do not fabricate 4-bar reception for abstract sessions.

## Performance and acceptance

No per-frame texture reload, full NPC/world scan or ModData chatter. Cache atlas handles, crop UVs and presentation list rows; use event-driven refresh and bounded pagination. Test Core standalone; Core+Hoomans; Core+DTAbstract/DTCommon; Core+DTHoomans/DTCommon/Hoomans; hybrid; future dummy plugin. Offline Lua/mocked GUI is not native Build42 SP/MP evidence. Check split-screen/player index and correct device selection, six skins, softkeys, portrait frame cost, race/stale sessions, old commerce regressions and native server denial. The roadmap defines gated verification.

## Mandatory current presentation-quality gate (2026-10-15)

The existing Core OS and mod providers are implemented at source/offline-test level. A user-supplied native screenshot of the US Army radio shows the UI overlapping the vanilla radio panel, a rigid shell with no drag/resize, extremely cramped LCD text and missing atlas app icons. This is **failed native UI acceptance** despite earlier R0–R7 progress. Fix in PsychopatzCore under [`CORE_RADIO_OS_UI_STABILIZATION.md`](https://github.com/psychopatz/psychopatzCore/blob/main/Docs/radio_os/CORE_RADIO_OS_UI_STABILIZATION.md) (U0–U7), before adding new trading/LLM/chat functionality.

- Core should reuse its window geometry, UI settings, responsive and clipping helpers where compatible with a **frameless diegetic shell**. Support constrained drag, constant-aspect resize and saved per-player position/scale, with LCD/button hitboxes transformed together.
- Use actual prepared icon/button/chrome sprites, dynamic localization and measured layout; the 72–83×55–61-pixel LCD cannot display three arbitrary rows below a two-line header. UI page contents and contact portraits must be genuinely clipped; direct click and hardware navigation must agree.
- DT/Hoomans providers should remain stable. Trader app uses existing V2 window and authorized DTCommon server service; Hoomans contacts use authorized discovery/conversation. Do not rebuild business logic to make visuals look finished.
- The **PZ Headless Harness is forbidden** because it is broken. Offline Lua/atlas/unit suites and normal Project Zomboid Build 42 SP/MP with user screenshots and console.txt are the accepted evidence paths. If normal game access is missing, native acceptance is *pending*, not passed.

## 2026-10-15 latest visual acceptance blocker (C0–C6)

New normal-game screenshots demonstrate low-detail/cropped six-shell artwork, apparent monitor bleed-through and inadequate discoverable scaling **after** Core's U0–U4 source improvements. The canonical corrective plan is `psychopatzCore/Docs/radio_os/CORE_RADIO_OS_COMPOSITOR_SCALE.md`. UI composition, alpha-hole/backing rect geometry, source fidelity, visible +/-/fit zoom and pixel-snapped viewport/hitboxes must be corrected in Core. This does not transfer ownership to DynamicTrading.

Core currently attempts `screen_bg_<theme>`, so transparency is a *measured cause to identify*, not proof no background was drawn. The 341×341 compact source is confirmed from the builder as a lossy source for the 1024×1024 shell. No arbitrary art substitutions. Consumer apps and server-authorized V2 trade paths remain unchanged. **PZ Headless Harness prohibited**; require normal game for native acceptance.
