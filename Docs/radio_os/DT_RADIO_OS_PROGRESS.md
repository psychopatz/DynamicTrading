# DTCommon Radio OS — Progress Ledger

**Planning baseline:** 2026-10-15, DynamicTrading main at 3f8ec67540c43e2f67cf9ee8acbe002e3886a48b (re-audit immediately on agent start).
**Current phase:** R0 — fresh implementation audit/test baseline, **not begun** by Luna.
**Next chunk:** R0 — inspect working tree, current test harness and dependency contracts; run in-repo baseline and verify six alpha/atlas PNGs; document actual B42 rendering APIs and short reproducible access tests, then continue directly into R1.

## Implemented before this goal

- Six walkie PNG atlases in DTAbstract media: Shells (6 variants), UI Core (25), Buttons (36), Icons (32), Indicators (25), Overlays (8). Current shell is a compact/color-reduced version of approved art.
- Lua manifest defines six Base.WalkieTalkie1–5 and Base.WalkieTalkieMakeShift skins, rects/button hotzones. DTA_RadioOSPreview.lua opens an opt-in client preview: Home / Contacts / Scanner placeholder; no real contact/call/trade.
- Current DTCommon client already has OpenTrader and RequestSnapshot, with handoff to existing PNC.InventoryWindow.OpenTrade when available and DTCommon fallback otherwise. Common TraderService owns basket settlement.
- DTHoomans has ContextHub merchant context and Project Hoomans conversation outcome/trader referral support.

## Verified for planning

- GitHub tree shows all six PNGs at main baseline. Prior independent build workflows passed for assets. **No native B42 radio UI proof recorded**.
- Module dependency declarations: DTCommon requires PsychopatzCore,MarketSense; DTHoomans requires DTCommon,ProjectHoomans; DTAbstract requires DTCommon,MarketSense.
- Current preview and atlas manifests/assets are incorrectly owned by DTAbstract for a cross-module UI.
- Physical trader access in DTCommon checks nearby PNC body when record.a != 1; record.a == 1 bypasses the nearby test. It does not by itself prove physical radio ownership. Must audit authorization at all snapshot/commit paths before rollout.

## Missing / known risks

- No DTCommon-owned Radio OS, no actual contact provider registry, no device resolver, no authenticated server-side radio session.
- Existing DTAbstract hasRadio() checks non-canonical Base.WalkieTalkie and one HamRadio1 type.
- Small physical LCD cutouts (~72–83 x 55–61 at authoring scale) may not support readable rich UI/portrait without presentation redesign and measured scale testing.
- Hoomans portrait/social/call API integration and abstract no-body handling untested.
- Six production atlases available for walkies only. HAM/manpack/receiver shell families are **not** ready and should be separately scoped after MVP.
- Native SP, dedicated MP, screenshots, keyboard/focus, performance, radio gating, forged requests and load combination tests: **not run for this goal**.

## Invariants / don't regress

- Existing Dynamic Trading V2 trade window and its basket/quote/settlement logic remain authoritative.
- Abstract trader without physical NPC can trade only after server-resolved remote access; Hoomans trader must be near a valid merchant NPC for physical interaction.
- DTHoomans guard referral remains referral, not trade.
- Do not replace root GOAL_PROMPT.md (MarketSense basic trading MVP). Radio OS uses RADIO_OS_GOAL_PROMPT.md.

## Progress writing instructions to Luna

Update only current phase, implemented, verification, risks and next chunk after each commit. Include exact test commands/evidence and native/CI distinction; do not append full tool transcripts or claim native success from Lua mock tests. Advance to next chunk automatically until gates are complete or real safety blockers remain.
