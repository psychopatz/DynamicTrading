# Reusable PsychopatzCore Radio OS — Progress Ledger

**Planning update:** 2026-10-15
**Baseline at planning:** DynamicTrading `da480d5ef91e18bbbcdfe80c79e5523356e13cca`; PsychopatzCore `ff7ce885eed29fa5f42b1a5223e39144982c8049`. Actual HEAD may advance; recheck.
**Current phase:** R0 fresh cross-repo audit — **not started by Luna**.
**Next chunk:** R0: inspect current statuses/HEAD of Core, Hoomans and DynamicTrading; source-audit existing RadioDeviceState/RadioActions/PortraitPanel and Hoomans contacts; verify six DTAbstract PNGs/manifest; run initial cross-repo regression and capture failings, then continue to R1 moving assets and UI ownership into Core.

## Already present (source/asset-level)

- Core already supplies radio device state, generic vanilla-radio action host and generic portrait panel. These will be extended, not duplicated.
- ProjectHoomans has WorldDiscovery `radio_scan`, `radio_ambient` and `call_contact` actions as discovery mechanics, plus separate NPC conversation systems. Integration as a Core radio contact provider is **not** yet implemented.
- DynamicTrading/DTAbstract has six committed walkie PNG atlases (Shells=6 devices, Core=25 UI sprites, Buttons=36, Icons=32, Indicators=25, Overlays=8); alpha transparency locally checked in earlier asset builds. The art is color-reduced and tiny LCD openings remain a UX risk.
- DTAbstract holds a disabled-by-default walkie preview with Home/Contacts/Scanner placeholders and the six-skin manifest. It is **not** a live contact/trade OS.
- DTCommon already owns trader service/trade window, including current Project Hoomans trade UI handoff; DTHoomans already has merchant/guard conversational context. Preserve these.

## Updated architecture and outstanding work

- **Core owns entire reusable radio device/OS/contacts UI/atlas system. DTCommon does not own Radio OS**. Core may not depend on DynamicTrading or PNC; consumers register their own apps/providers.
- Existing previous Dynamic Trading plan incorrectly instructed Luna to migrate assets to DTCommon. That plan is superseded; R1 destination is psychopatzCore.
- No production Core-owned atlas, app/contact-provider API, working Hoomans contact integration, trader scanner, authentication hardening or radio call/chat integration yet.
- TraderService's `record.a==1` present access behavior requires server-side radio/remote validation to prevent unauthorized trader snapshots and settlement.
- No native B42 SP/MP Radio OS testing evidenced; all gates remain open. HAM/manpack assets are not available; defer those families.
- Small source LCD screen rectangles ~72–83×55–61 may need native zoom/layout changes.

## Progress hygiene

After each successful chunk record current phase, actual verification/test class and commands, exact commits/push result in each owning repo, blockers and next safe chunk. Do not inflate this file with command transcripts or claim native success from offline mocks. Keep DynamicTrading `GOAL_PROMPT.md` for the separate trading MVP untouched. Continue automatically after each coherent safe commit.
