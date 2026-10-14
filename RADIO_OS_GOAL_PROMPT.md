# DTCommon Radio OS — Luna/Codex Copyable /goal

Paste the following into Codex CLI/Luna while positioned in the **current DynamicTrading V2** checkout with permitted access to its installed dependencies. This is a separate goal from the existing root GOAL_PROMPT.md (basic trading).

---

/goal

Build the actual, interactive DTCommon Radio OS / common NPC communication interface **unattended** using the six already-produced walkie-talkie atlases and existing Dynamic Trading V2. Shared UI ownership is DTCommon, not DTAbstract. BOTH DTAbstract and DTHoomans must be able to use the same UI/widgets. DTAbstract contacts abstract/remote traders without requiring a spawned NPC when server-authorized; DTHoomans must verify a nearby real merchant NPC and existing Hoomans conversation permissions for physical trading. They share exactly one existing V2 trade UI, trader stock, MarketSense prices and authoritative DTCommon settlement path. Calls/Contacts/Scanner should feel like a clickable device OS with Home/Back, reusable button states, dynamically populated NPC portraits/status/text, and future modular app extension. No baked-in dynamic data, no additional trade shop screen in radio art.

Read in this order:
1. Docs/radio_os/DT_RADIO_OS_AGENT_RUNBOOK.md
2. Docs/radio_os/DT_RADIO_OS_CONTRACT.md
3. Docs/radio_os/DT_RADIO_OS_ROADMAP.md
4. Docs/radio_os/DT_RADIO_OS_PROGRESS.md
5. Docs/DTABSTRACT_WALKIE_ASSET_CONTRACT.md and existing DTABSTRACT_RADIO_OS_PREVIEW.md as reference only where relevant.

Follow R0–R9 strictly, beginning with R0 and its Next Chunk. Freshly audit the real worktree, dependencies, vanilla Build42 radio/UI methods and in-repo tests before making changes. The atlas/source currently resides in DTAbstract, so R1 must migrate the common production assets, manifest, previews/build workflows and loading into DTCommon, keeping compatibility and not duplicating textures. Confirm six walkie PNGs and true LCD alpha holes. HAM, manpack and receive-only art is **out of initial production scope**.

Implement a reusable DTCommon RadioOSWindow, widget/skin registry, app navigation, screen clipping, text/icons/softkeys, and provider contracts; DTAbstract and DTHoomans only adapt entry points, contacts, authorization and optional NPC portrait/conversation. DTCommon must load safely without PNC or DTAbstract. Use ProjectHoomans existing NPC/portrait/dialogue interface only when installed; do not build a new LLM or NPC brain. Honor physical merchant/guard distinctions, nearby NPC presence for physical trades, and genuinely remote access for authorized abstract trades. Never trust client-side mode/device/NPC/trader claims: revalidate each discovery/snapshot/trade with server-side authority; review current TraderService.validateAccess and its a==1 capability. Preserve the existing commerce APIs, guard referral, item instance identity, currency rollback and basket semantics; no legacy manual pricing.

The six-shell LCD source rectangles are very small. Validate actual Build42 legibility, screen clipping, zoom and hitboxes rather than forcing unreadable Home/Contacts/Scanner/Call rows. A UI preview isn't proof of real contact/call/trade; disabled capabilities must visibly say unavailable instead of pretending to work. Keep sprites static/cached, updates event-driven/throttled, no world scans per tick, no large ModData memory histories or per-frame texture loads. Keep SP and MP behavior equivalent.

You are authorized to execute all routine safe development steps unattended: read/modify in-scope code, run offline/unit/native tests in isolated fixtures, update goal docs, commit and fast-forward push verified chunks. Preserve unrelated work, installed mods, live saves and user data; no force push or reset. Continue after each chunk automatically instead of asking repeated permission. Ask only for a genuine destructive/user-data risk, unresolved user-authored merge conflict, unavailable indispensable dependency, or unresolvable product decision; keep other safe work moving.

At every checkpoint update Docs/radio_os/DT_RADIO_OS_PROGRESS.md with current phase, evidence, commits/push, remaining risks and exact next chunk. Run relevant existing trading regression tests and new Lua mock tests; test standalone/common, Abstract-only, Hoomans-only, hybrid, six devices, native SP, native dedicated MP, access spoofing, reconnect and performance. Label evidence honestly: source / asset / Lua smoke / native SP / native MP / profiler. No native verification => milestone remains open and not production ready. Do not modify the separate trading GOAL_PROMPT.md or pursue unrelated economic features.

Proceed with R0 now, then R1 and beyond automatically until the R0–R9 acceptance gates are satisfied or a real safety blocker occurs.
