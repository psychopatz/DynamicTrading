# DTAbstract Radio OS — Opt-in In-Game UI Preview

**Status: renderer and navigation smoke test only. Not a released Radio OS,
not verified in native Project Zomboid Build 42 yet.**

This stage exercises six manifest-driven walkie shells using the committed
UI Core atlas and a real Project Zomboid \`ISPanel\` with transparent
\`ISButton\` input hotspots. Default \`EnableRadioOSPreview=false\` keeps
the existing trader UI/context options and server code unchanged.

## How to test

In a client Lua console (development only):

\`\`\`lua
DTAbstract.RadioOS.OpenPreview(0, "Base.WalkieTalkie5")
\`\`\`

Other six Build 42 walkie fullTypes are accepted through
\`DTA_Walkie_Manifest.lua\`. Unknown types fail without opening a UI.

Alternatively set \`DTAbstract.EnableRadioOSPreview=true\` in a development
load context, then choose \`[Radio OS] Preview (development)\` from the world
context menu. **This context option deliberately does not require a radio,
because it tests the art only.** It does not grant remote trader access.

The screen has two clickable rows, Contacts and Scanner. These open a
\`NOT CONNECTED\` placeholder. Use the three actual radio-body button
regions to change selection, select and go back/close. No fake contact
data is injected.

## Draw contract

The preview uses \`ISUIElement:drawSubTexture\` with the PZ Lua argument
order \`(texture, sourceX, sourceY, sourceW, sourceH,
destX, destY, destW, destH, alpha, red, green, blue)\`.
Per-sheet texture lookup is cached. The LCD background draws first,
then runtime labels; the transparent shell draws last.
The sketch deliberately avoids complex clipping by keeping all displayed
text within the cutout; real portrait rendering must enforce clipping
and test different game scaling options.

A pure-Lua mock test verifies initialization, five hotspots, two
app navigations, shell/LCD drawing, close and unknown skin rejection:

\`\`\`sh
texlua tests/test_DTA_RadioOSPreview.lua \
  Contents/mods/DTAbstract/42.20/media/lua/client/DTAbstract/UI/DTA_RadioOSPreview.lua \
  Contents/mods/DTAbstract/42.20/media/lua/client/DTAbstract/UI/DTA_Walkie_Manifest.lua
\`\`\`

## Next work — do not treat as implemented

1. Native B42 smoke test of \`drawSubTexture\` rendering, hitboxes, text
   legibility, scaling and cursor/drag behavior (SP and MP client).
2. Replace preview-only static screen with a reusable \`RadioOSWindow\`,
   app registry, runtime button-state assets, keyboard navigation,
   icon widgets, and localization.
3. Resolve the actual held/selected/placed radio item. The existing
   DTAbstract trader-access radio detection is insufficient for all
   six Build 42 walkie types; authorization/power/range checks belong
   in a separate real-device resolver and authoritative services.
4. Populate Contacts from real permitted NPC contacts. Integrate the
   existing Hoomans portrait renderer only after verifying clipping,
   performance and API contract.
5. Add a real trader scanner backed by authorized DTCommon service
   data. Clicking Trade must open the **existing V2 trade window**.
6. Decide whether the very small 72–83×55–61 source LCD holes need
   a bigger radio display viewport or a user-controlled zoom mode
   before enabling rich OS screens. Never force tiny illegible text.

The UI-only preview intentionally performs no game transactions or
server commands, so it cannot grant new authority in multiplayer.
