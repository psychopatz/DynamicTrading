# Cross-Repository PsychopatzCore Radio OS — Pasteable Luna /goal

**Starting location:** any Codex CLI working directory with access to checkouts of `psychopatzCore`, `ProjectHoomans`, and `DynamicTrading` (plus installed dependent mods); discover repository locations before editing. Unlike the previous goal, the **shared Radio OS belongs in PsychopatzCore, not DTCommon or DTAbstract**.

```text
/goal

Build a real reusable, clickable Project Zomboid radio operating system in **PsychopatzCore**, for use by Project Hoomans, Dynamic Trading V2 and future independent Psychopatz mods. Work unattended and continue automatically through all safe ordered milestones R0–R9.

Read in order:
1. psychopatzCore/Docs/radio_os/CORE_RADIO_OS_CONTRACT.md
2. DynamicTrading/Docs/radio_os/DT_RADIO_OS_AGENT_RUNBOOK.md
3. DynamicTrading/Docs/radio_os/DT_RADIO_OS_CONTRACT.md
4. DynamicTrading/Docs/radio_os/DT_RADIO_OS_ROADMAP.md
5. DynamicTrading/Docs/radio_os/DT_RADIO_OS_PROGRESS.md

Audit the latest working trees, current Base game Build42 APIs and integration code first. Extend PsychopatzCore's existing RadioDeviceState, RadioActions, RadioSignalHost and PortraitPanel; do not implement a parallel vanilla radio host. Move all six prepared walkie atlases, manifest, builders and preview from DynamicTrading/DTAbstract to PsychopatzCore-owned UI/radio paths. Preserve alpha screen holes and update all paths/CI/tests and consumers safely. Core must load alone without Hoomans, MarketSense or DynamicTrading.

Build Core's reusable device/skin/renderer architecture, responsive readable LCD with clipped dynamic portraits/text, button hover/pressed/disabled states, mouse/keyboard/physical softkeys, Home, Settings, Contacts, Contact Detail, generic action/call screen and a clean versioned app/contact-provider registration API. A third-party mod should be able to register a radio app or contacts without importing DynamicTrading or ProjectHoomans. No NPC names, stock screens or portrait baked into texture assets.

Integrate Hoomans by registering its real NPC/faction/settlement contacts through Core; reuse the existing server-authoritative WorldDiscovery radio_scan/call_contact paths and NPC identity/portrait/conversation services as actually supported. Distinguish contact discovery from true chitchat: never pretend a discovery response is live NPC dialogue. Preserve existing in-person talk paths.

Integrate DynamicTrading only as plugins: DTCommon registers the trader app and opens the existing V2 trade UI; DTAbstract supplies server-authorized remote trader discovery/access that can work without a spawned NPC; DTHoomans requires an actual near, interactable NPC merchant and verified role for in-person trading. Hoomans radio contacts must not bypass physical merchant proximity. Guards remain referral-only. MarketSense still owns valuation and DTCommon still owns stock, quotes and settlement. Do not add any separate trade screen/transaction/economy inside Core.

Server-validate every sensitive action (radio and provider eligibility, known contacts, NPC role/proximity, abstract trader right, request/session/replay and snapshots/settlement). Do not trust client-provided access mode, trade/contact IDs, prices or NPC positions. Specifically audit TraderService.validateAccess's record.a==1 behavior. Preserve the existing trade and Hoomans API/rollback paths.

Keep efficient texture caches, event-driven/paginated contacts, no per-frame global scans or heavy ModData, localized messages, and truthful unknown signal/battery states. Native-test six devices, screen legibility/zoom, portraits/clipping, load combinations, Core-only and dummy-plugin use, actual singleplayer/dedicated MP, forbidden remote access, normal physical NPC interaction and V2 trade regressions. HAM/manpack/receive-only shell atlases are future asset work, not ready.

Execute the R0 Next Chunk immediately, then R1 through R9 unattended. Run in-repo smoke/native/asset tests, update DynamicTrading/Docs/radio_os/DT_RADIO_OS_PROGRESS.md after every meaningful chunk, commit and fast-forward push validated changes into EACH OWNING repository. Preserve unrelated user edits, real saves and installs. No force pushes/resets or destructive user-data changes. Ask only if an actual dangerous/user-conflict/missing indispensable dependency blocks the affected task; keep independent safe work moving. Differentiate source, offline Lua, image, native SP, native MP and profiler evidence. Do not claim complete unless all required gates pass. Do not modify the separate DynamicTrading/GOAL_PROMPT.md trading goal.

Begin R0 now.
```
