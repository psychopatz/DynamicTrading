# Reusable Core Radio OS — Cross-Repository Luna/Codex Agent Runbook

**Goal:** a mod-agnostic, real, clickable radio/contacts OS **owned by PsychopatzCore**, consumed by Project Hoomans and Dynamic Trading V2, extensible by future mods. This replaces the obsolete plan assigning the entire Radio OS to DTCommon.

## Read order

1. `psychopatzCore/Docs/radio_os/CORE_RADIO_OS_CONTRACT.md` — canonical **platform ownership**.
2. `DynamicTrading/Docs/radio_os/DT_RADIO_OS_AGENT_RUNBOOK.md` — unattended execution rules.
3. `DynamicTrading/Docs/radio_os/DT_RADIO_OS_CONTRACT.md` — cross-mod integration and security contract.
4. `DynamicTrading/Docs/radio_os/DT_RADIO_OS_ROADMAP.md` — R0–R9 ordered milestones.
5. `DynamicTrading/Docs/radio_os/DT_RADIO_OS_PROGRESS.md` — Next Chunk, latest results.
6. `DynamicTrading/RADIO_OS_GOAL_PROMPT.md` — pasteable start prompt.

Treat actual checked-out source, verified dependencies and native game observations as higher priority than historical documentation. Core API proposals in these docs are NOT already-implemented APIs.

## Repositories / ownership

| Repository/mod | Authority |
| --- | --- |
| `psychopatz/psychopatzCore` | Radio shells and six atlases, skin/texture registries, device validation & vanilla integration, **Radio OS runtime/UI/widgets/navigation**, generic extensible app and contact-provider APIs, reusable portrait slot and radio diagnostics |
| `psychopatz/ProjectHoomans` | NPC/faction/settlement contacts, world discovery, identity, portrait data, dialogue, real NPC conversational abilities, client/server registration plugin for Core |
| `psychopatz/DynamicTrading:DTCommon` | Trader application integration and bridge to existing V2 trade UI; trader records, quotes, snapshots, MarketSense value adaptation, currency, authoritative settlement |
| `DynamicTrading:DTAbstract` | Remote abstract-radio trader provider, legitimate access/session/scanner behavior when no NPC body spawned |
| `DynamicTrading:DTHoomans` | Actual nearby merchant NPC binding and conversation/physical trade entry; guard referral remains non-trade |
| `MarketSense` | Item semantics/intrinsic value only |

**Core cannot depend on any of the consumer mods.** The former DTAbstract preview and manifest are starting material to migrate into Core, not a place for the production OS to live. Keep UI implementation and assets in Core, *not* in DTCommon, DTHoomans or DTAbstract. DTCommon still centrally owns Dynamic Trading server-side access and settlement.

## Existing extension points worth auditing

- Core already has `PsychopatzCore.RadioDeviceState` with `GetPlayerDevices` / `FindActivePlayerDevice` / `IsActive`, `PsychopatzCore.RadioActions`, `PsychopatzRadioSignalHost` and generic `PsychopatzPortraitPanel`. Reuse and upgrade these. Do not build another competing `ISRadioWindow` patch.
- Hoomans `WorldDiscovery.HandleAction` has `radio_scan`, `radio_ambient`, `call_contact` and `WorldDiscovery.CallContact`. Re-audit client/server wiring; a *discovery phase update* is not automatically NPC chit-chat. Hoomans decides real calls/dialogue capabilities and what a player is allowed to know.
- DTCommon `Client.OpenTrader` already forwards to PNC trade-mode window when present; trader settlement is in `TraderService`. `validateAccess` currently passes for `record.a == 1` without actual device validation; close access gaps without breaking current pricing or physical trade.
- Six production walkie atlases (6 shells; 25 UI Core; 36 buttons; 32 icons; 25 indicators; 8 effects) currently live in DTAbstract/42.20/media/ui/dtabstract/radio. They are verified GitHub files, **not yet Core assets or native-tested**. Shell version is color-reduced and LCD holes are small. HAM/manpack variants are not ready.

## Unattended execution loop

Repeat until R0–R9 acceptance gates pass, or a genuine blocker:
```text
read Next Chunk -> inspect statuses/HEAD in each affected repository
-> reproduce / prove one contract -> implement smallest coherent owner-local patch
-> focused Lua tests + dependency regressions + native tests where available
-> git diff --check -> concise progress evidence -> commit each repo safely
-> fast-forward push when credentials allow -> continue next safe chunk
```

- Do not repeatedly ask permission for ordinary in-scope inspection, edits, safe tests, isolated fixtures, new goal/docs/tests, commits or fast-forward pushes. This goal authorizes those safe tasks.
- Preserve unrelated edits, live saves, installed mods, user settings, branches, and external data. Never `git reset --hard`, clean unknown files, force push, or discard conflicts. Check each repo's status, upstream and current HEAD, and re-read impacted files before editing.
- Cross-repo migration: first publish validated Core assets/API; migrate/adapt Hoomans and Dynamic Trading consumers; only remove old DTAbstract assets when all relevant load combinations and compatibility tests pass. Changes land in **owning repositories**, not vendored copies.
- Do not install unrelated tools or change user-owned PZ worlds. Native tests use isolated disposable saves/profiles; headless harness may assist only after actual capability verification.
- Do not claim runtime success from mock Lua, PNG geometry or source inspection. Log separately: source audit, asset validation, Lua smoke, native Build 42 SP, dedicated MP, profiler.
- No new price registry, manual item values, stock economy, duplicate conversation brain, simulated "real call" for a provider that lacks one, or second trade basket UI.
- Only stop for genuine irreversible/user-data hazard, uncertain merge conflict, indispensable missing dependency or unresolved product requirement. If one integration is blocked, continue independent Core work.

## Completion

Core-alone, Core+Hoomans, Core+DTCommon+DTAbstract, Core+DTCommon+DTHoomans+Hoomans, hybrid and dummy third-party app all load. Six devices render with correctly working physical buttons, clipped text/portrait, localized Home/Contacts/Call/Scanner and extensible apps. Hoomans owns real authorized contacts/discovery/dialogue; abstract trader may trade without spawned NPC with authoritative radio access; physical merchant trade requires actual nearby correct-role NPC. Current V2 trade UI/economy untouched. Native SP and dedicated MP authority/security/performance gates evidenced. Unverified native tests remain open gates.

Keep `Docs/radio_os/DT_RADIO_OS_PROGRESS.md` compact: current phase, implemented, evidence/tests/SHAs, risks, exact next chunk. The existing root `GOAL_PROMPT.md` belongs to a separate trading MVP; do NOT overwrite it.
