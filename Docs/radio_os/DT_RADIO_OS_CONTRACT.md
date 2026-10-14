# DTCommon Radio OS — Architecture and Security Contract

## Product definition

One phone-like, clickable radio/device interface with Home, Contacts, Contact Detail, Call/Conversation, Trader Scanner and Settings. The shell resembles the actual vanilla handheld radio used, with Project Zomboid-like matte pixel-art elements. NPC names/portraits, frequencies, signal/battery, actions, lists and labels are **rendered dynamically**. No second shop/stock/basket screen is painted onto a walkie. Selecting Trade transfers into the established V2 trade-mode inventory window, never forks commerce settlement.

The shared UI framework is usable with either integration installed separately or both together. DTCommon itself must not require ProjectHoomans or the DTAbstract mod and should not independently bypass the access rules of either integration.

## Ownership

| Module | Owns | Does not own |
|---|---|---|
| DTCommon | RadioOS UI renderer/widgets, atlas/skin registry, reusable app/router/control model, common normalized contact/action capabilities, client request coordination, trader snapshot/commerce contract, central server authorization dispatch | NPC engine, Hoomans social memories, vanilla device implementation, separate quote/payment logic |
| DTAbstract | Abstract provider, real two-way device identification, remote trader discovery, remote eligibility/session source; contact without spawned NPC body when server permits | UI implementation fork, unauthenticated trading, invented physical NPC |
| DTHoomans | Physical/NPC provider, merchant identity lookup, Hoomans context/conversation entry, live NPC proximity and role validation integration, NPC portrait/conversation adapter | Duplicate Radio OS, alternate quote/settlement or guard merchant privilege |
| ProjectHoomans | NPC presence/state, conversation, authorization and native portrait/identity, existing inventory trade window | DTAbstract remote access policy |
| PsychopatzCore | Shared generic radio actions, inventory, currency, UI helpers/portrait renderer where appropriate | DT-specific app navigation/trader settlement |
| MarketSense | Intrinsic item semantics/value | Per-radio trader price policy |

**Independent modular load:** DTCommon alone loads the shared assets/classes safely but should not expose unsupported trader/call actions. DTHoomans alone (with DTCommon and ProjectHoomans) and DTAbstract alone (with DTCommon and MarketSense) register adapters at runtime. Both present => common UI with distinct contacts/entry rules. No PNC reference in an unconditional DTCommon import.

## Two verified acquisition/access modes (not client-selected authority)

- **physical_npc / DTHoomans**: player interacts with the actual identified merchant NPC via existing Hoomans context or successful conversation choice. Server confirms actor/player, authoritative NPC-to-trader mapping, trader role, current loaded/live/interactable NPC presence, proximity (existing service uses <=6 tiles squared radius 36), trader READY state and other Hoomans interaction rules at *snapshot and commit* time. Guards may refer to the merchant but must not offer trade. Walking away closes/invalidates a physical session; never convert it silently to remote abstract access.
- **abstract_radio / DTAbstract**: player operates an actual supported radio transceiver or explicitly permitted abstract access mechanism. Server checks real radio ownership/selected device and powered/two-way status as needed by gameplay contract, corresponding abstract trader capability and READY state; trader may have no spawned world NPC. No dependency on PNC.Registry. Do not require a physical body merely because legacy records have a p/l ID; conversely do not interpret a==1 as proof of radio authorization.
- A radio contact with a physical Hoomans NPC must **not** bypass Hoomans proximity rules simply because the same shell UI can show that contact. Remote voice features for Hoomans are future scope unless separately authorized; face-to-face Hoomans NPC dialogue can use common contacts/presentation widgets without requiring a radio shell.
- In hybrid installs, choose the provider by *server-resolved validated origin/session*, not by the client UI's displayed tab or request.mode. Explicit allow/deny, no automatic escalation from physical to abstract.

## Proposed normal form (design contract; adjust to actual existing APIs)

Local presentation record:
{ contactID, providerID, label, kind, portraitDescriptor?, status?, capabilities={canTalk,canTrade,canScan}, disabledReason? }
IDs are stable/capped strings. Never send rich server records or unbounded ModData to the client. Portrait descriptor refers to a **validated** existing resolver; fallback is a blank/silhouette screen for abstract contacts without NPC identity.

Request intent:
{ requestID, contactID?, traderID?, action, deviceRef?, conversationToken? }
Bound all lengths and validate every field. The server resolves authoritative actor/device/NPC/trader and grants a short-lived scoped session or rechecks directly on every important operation. A session token is an unguessable server-issued capability **only if the native runtime provides a sound generation/verification method**; otherwise server-side keyed session state and bounded opaque request handles. Never take access mode, NPC position, isAuthorized, prices, wallet or inventory claims from the client as authoritative.

Server session (concept):
{ playerKey, providerID, traderID?, npcID?, deviceID?, issuedAt, expiresAt, actions, accessRevision }
Scope includes actor, contact/trader, source, allowed actions, expiry and revocation. Disconnect, proximity/radio loss, despawn/unavailable trader, NPC role change, close and stale stock must fail closed. No serialized long-term session table.

## UI/asset contract

Six committed 42.20 PNGs currently live under DTAbstract/42.20/media/ui/dtabstract/radio:
1. shells/DTA_Walkie_Shells.png — 1024x1024, six 256x432 cells, LCD alpha cutouts.
2. ui/DTA_Walkie_UI_Core.png — 1024x1024, 25 generic chrome sprites.
3. ui/DTA_Walkie_Buttons.png — 1024x512, 36 button state backgrounds.
4. ui/DTA_Walkie_Icons.png — 512x512, 32 pictograms.
5. ui/DTA_Walkie_Indicators.png — 512x256, 25 indicator sprites.
6. ui/DTA_Walkie_Overlays.png — 512x512, 8 translucent effects.

All are confirmed in the repository, but shell graphics are compact/color-reduced, and **native runtime/art acceptance is pending**. Manifest with six item IDs/rects and temporary preview are also under DTAbstract/UI. The other three radio families (HAM/manpack/receive-only) do NOT have finished production atlases; do not block the six-walkie MVP over this.

**Mandatory migration:** relocate shared renderer, six atlases, manifest and build-time sources/workflows to DTCommon ownership, e.g. DTCommon/42.20/media/lua/client/DTCommon/RadioOS and media/ui/dtcommon/radio. Update texture paths, localization, build scripts, CI, tests and dev preview; preserve compatibility with existing DTAbstract APIs as thin non-asset shims if needed. Move files rather than create runtime copies; only delete old location after successful smoke/native asset load. Image file name DTA_* may remain for migration compatibility, but actual DTCommon paths/registries must be authoritative.

Shell source 256x432 has only ~72–83x55–61 usable screen pixels. **This is a real UX limitation.** Explicitly validate zoom, game font height, at least two navigable rows, clipping, portrait legibility and interaction hitboxes. If necessary enlarge/paginate an OS LCD presentation or revise shell artwork/manifest together; do not render long unreadable text or off-screen controls. Nine-slice where supported/validated and nearest filtering where visually appropriate. Cache texture handles and precomputed UVs, no frame-by-frame image decoding/noise.

Render LCD backing, clipped app text/portrait/status, optional effects, shell faceplate, then physical button states/focus. All screen hitboxes share screen clip. Transparent sprite overlays named mask are decorative, not GPU clipping. Buttons use separate atlas background, icon and localized label; disabled states must prevent actual activation.

## Feature contracts / behavior

- Home: app tiles/list and selectable softkeys, Back/Close, cursor/keyboard/mouse/controller if feasible, consistent navigation. Translation keys for user-visible labels and reasons.
- Contacts: populated only from an authorized provider, with bounded list/paging, stable ordering, and safe empty/loading/unavailable states. Never blindly enumerate PNC world registry in DTCommon or leak remote NPC identities.
- Call/Chitchat: mode-specific provider capability. DTHoomans reuses actual PNC conversation API if nearby and legally interactable, and existing PNC/psychopatz portrait renderer as opt-in plugin. DTAbstract without physical NPC uses a contact identity/portrait placeholder; DO NOT invent LLM/semantic dialogue in DTCommon or falsely imply a real NPC call exists. Graceful capability-disabled state until concrete API is verified.
- Scanner: only server-eligible abstract remote traders from DTAbstract, and local physical merchants from DTHoomans when proximity confirms eligibility. Status/data are bounded and refreshed intentionally; not each redraw.
- Trade: call DTCommon.Client.OpenTrader with its existing mode/traderID and npcID where applicable after authorization, preserving Project Hoomans PNC.InventoryWindow.OpenTrade when installed and DTCommon fallback as documented. Do not create new basket/quote/inventory UI inside radio.
- Device: identify all six vanilla WalkieTalkie1..5 and WalkieTalkieMakeShift by actual item type/instance, validate inventory/equipment and DeviceData API where available, no magic Base.WalkieTalkie detection. Map selected device to skin; real battery/signal only, unknown if unavailable. Explore HAM/manpack/receive-only separately; no fictitious two-way radio for receive-only.
- Error/loading: explicit localizable non-crashing messages for unavailable mod provider, disconnected radio, invalid NPC/merchant, stale session, trader moved, unavailable currency/snapshot. Opening UI is not a trade approval.

## Authentication and commerce guarantees

All snapshots, scanning results exposing trader state, call/interaction outcomes and purchase/sale submissions must enforce authoritative player/trader/mode access, independently of the UI. Audit DTCommon.Server RequestTrader and TraderService validateAccess (a==1 currently allows unconditional access), and DTHoomans merchant conversation/guard referral before changing them. Do not break the existing stock and settlement code or leak trader snapshots to clients unable to access the trader. Bound request IDs, dedupe/expiry, prevent forged context/session reuse across players/traders/actions. Keep SP and dedicated MP behavior equivalent.

## Performance

No recurring world-wide OnTick scans. Use event-driven open/close and explicit throttled refresh, per-window input/portrait updates, bounded caches, snapshot diff/cached list rows, short-lived sessions, no per-frame Lua big allocations. Budget and profile frame time for 1, 10 and 100 NPC/trader records where a suitable harness can simulate this; distinguish true native results from synthetic benchmarks.
