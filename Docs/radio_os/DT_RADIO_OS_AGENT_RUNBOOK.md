# DTCommon Radio OS — Luna/Codex Unattended Agent Runbook

**Goal:** build a genuinely interactive, reusable Radio OS / contacts UI, shared by DTAbstract and DTHoomans. The common UI, assets and navigation live in DTCommon; each entry adapter supplies verified access context. Existing Dynamic Trading V2 and Project Hoomans conversation/inventory/trade systems remain the source of truth.

## Read in order

1. Docs/radio_os/DT_RADIO_OS_AGENT_RUNBOOK.md (this document)
2. Docs/radio_os/DT_RADIO_OS_CONTRACT.md
3. Docs/radio_os/DT_RADIO_OS_ROADMAP.md
4. Docs/radio_os/DT_RADIO_OS_PROGRESS.md
5. RADIO_OS_GOAL_PROMPT.md
6. Only the in-scope source and tests required by the current next chunk. Historical DTABSTRACT_* art documentation is source/reference, not final ownership.

## Agent operational rules

- Work **unattended** in small testable increments and continue through the ordered milestones until all mandatory acceptance gates pass or a *real* blocker arises. Do not request repetitive permission to read, inspect, write, refactor within this goal, test, document, or commit and push normal validated changes.
- First inspect the current worktree, branch/remote, local dependency checkouts and current files. The baseline below is an audit snapshot, not guaranteed fresh. Preserve all unrelated edits. Never reset, force push, overwrite conflicts, destroy real saves or Workshop installs, silently change settings, or invent test results.
- Git procedure: inspect status/diff and upstream; commit only coherent verified in-scope work; push fast-forward safely when possible. On conflict, isolate/report the impacted repo and continue independent work.
- Use isolated game profiles/saves for native tests. Use the repo's test runner and dependency tests. The Project Zomboid headless harness may help if available, but verify capabilities before relying on it; tests must be truly native to claim native results.
- Require **true** evidence classification in progress: source audit, asset validation, offline Lua smoke, native Build 42 SP, native Build 42 MP, measured profiler. Never present mocks or image screenshots as proof of interactive native support.
- No duplicate item catalog, currency or economy code. MarketSense owns valuation. PsychopatzCore owns reusable inventory, portrait and UI primitives where actually available. ProjectHoomans owns NPCs, conversations, portrait data and existing trade-mode inventory window. DTCommon owns trade contract/settlement AND the new neutral presentation framework; adapters own mode-specific access rules.
- Keep backwards compatibility with current DTCommon.Client.OpenTrader/RequestSnapshot and the V2 trade UI. Any revised session/access server contract must deny unauthorized calls from old clients, not silently trust client flags.
- Store transient navigation/contact queries in client memory; persistent social/contact knowledge must use the appropriate authoritative existing owner, not a bulky new global ModData database. Bound caches, payloads, searches and refresh cadence. No per-frame game-wide scans.
- Prefer scripts that generate small reproducible assets and validate PNG alpha/rectangles. Protect the existing approved style; avoid regenerating all art or inventing hyper-realistic facades.
- Stop only on genuine user-owned-data risk, unresolved Git conflict, missing indispensable game/dependency interfaces, or a necessary product decision not resolved by this contract; continue independent safe tasks if possible.
- After every chunk: focused tests, relevant regression tests, git diff --check, progress edit (short), commit/push safely, then advance to the next chunk without waiting for instructions.

## Source boundaries and current audit

Current DynamicTrading main baseline at start of planning: 3f8ec67540c43e2f67cf9ee8acbe002e3886a48b (2026-10-15 audit). Recheck HEAD before edits.

- DTCommon has DTCommon_Client.lua, DTCommon_TradeWindow.lua, DTCommon_TraderService.lua and DTCommon_Server.lua. Client.OpenTrader can route to the existing PNC.InventoryWindow.OpenTrade when available and otherwise uses its own legacy lightweight fallback. Preserve expected behavior; the radio is not a replacement commerce UI.
- DTAbstract currently holds DTA_Walkie_Manifest.lua, DTA_RadioOSPreview.lua, a developer-only OpenPreview and six PNG atlases. Its hasRadio() currently checks Base.WalkieTalkie (not the six concrete vanilla handheld fullTypes) or Base.HamRadio1. The preview is not live contact/trade functionality.
- DTHoomans_Context.lua provides merchant-specific physical NPC trade context, DTHoomans_Client.lua handles PNC ConversationOutcome including trader/referral handling, and DTHoomans_Conversation.lua applies merchant-versus-guard eligibility. Preserve guard referral semantics.
- DTCommon.TraderService has server-side validateAccess(): a READY record with a == 1 passes without proving the player's actual radio/device/session; physical a != 1 checks nearby NPC (radius squared 36). Do not equate "client UI opened" with authorization. Design a backwards-compatible authoritative session/access upgrade and test both gates.
- PsychopatzCore already exposes RadioActions and PortraitPanel components; inspect APIs and ownership before integrating or duplicating. DTCommon must not require ProjectHoomans/PNC at boot.

## Completion evidence

Required: standalone DTCommon load; DTCommon+DTHoomans load; DTCommon+DTAbstract load; both adapters installed; six walkie shell/render/softkeys; Home/Contacts/Call/Scanner navigation; real mode-authenticated opening/denial; physical NPC proximity; abstract absent-NPC remote trade; V2 inventory UI reuse; server rejection of forged mode/trader IDs; SP and dedicated MP; cache/memory and UI redraw profiling. Missing native testing => document precise blocker and remain not-ready.

Progress belongs in Docs/radio_os/DT_RADIO_OS_PROGRESS.md (only phase, implemented, evidence, blockers, next chunk). Do **not** replace GOAL_PROMPT.md, which is the separate Dynamic Trading MVP goal.
