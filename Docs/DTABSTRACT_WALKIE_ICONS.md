# DTAbstract Radio OS — Shared Icons Atlas v1

**Status:** Reproducible production icon art. In-game runtime icon buttons/app
navigation are not yet wired.

## Production texture

\`Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_Icons.png\`

- 512 × 512 PNG, RGBA straight-alpha, neutral tinted-grey icon glyphs.
- 8 columns × 8 rows of 64 × 64 px cells; 32 occupied and 32 reserved.
- Every occupied sprite ID, row, column and rectangle matches the existing
  \`DTA_Walkie_Manifest.lua\` icon grid; no new manifest entries are required.
- Minimum three transparent border pixels per icon cell; no baked button
  backgrounds, text, contact records or NPC artwork.
- The same icons may be reused in the HAM/manpack OS; they are not physically
  tied to the walkie shell size. Do not reimplement the same app icons per model.

## Icon IDs in atlas order

\`\`\`text
row 0 contacts radio_call trade dossier scan home back settings
row 1 chat logs faction trader caravan signal battery mic
row 2 speaker mute connecting receiving transmitting offline alert search
row 3 plus minus next prev up down left right
rows 4–7 RESERVED / fully transparent
\`\`\`

Conceptual design: bold survival-radio LCD pictograms with low saturation
and a dark silhouette for readability against green/amber/dark screens.
This is original art inspired by the project, **not extracted vanilla graphics**.

## Build

\`\`\`sh
python -m pip install Pillow==12.3.0
python tools/build_dtabstract_walkie_icons.py \
  --output Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_Icons.png \
  --layout /tmp/dta_walkie_icons.json
\`\`\`

The builder asserts per-cell alignment, alpha gutters, empty reserved rows,
32 unique glyph identities, and lossless PNG round-trip. Workflow
\`.github/workflows/dtabstract_walkie_icons.yml\` rebuilds and commits the
texture when either its builder or workflow changes on \`main\`.

## Runtime guidelines

Always use the named manifest atlas rectangle rather than hardcoded UVs.
Draw icons as separate foreground layers above modular button backgrounds,
and draw localized labels as runtime text. A display theme may tint glyphs
or change button backgrounds without modifying the atlas. Cache the texture;
do not decode PNGs or recreate icons on each UI redraw. Clip drawing and
hit-tests to the active radio's screen viewport.

Do not advertise a screen as usable merely because its icon exists.
Only expose Contacts, Call and Scanner actions once their underlying
authenticated/authorized game functions exist; Trade must open the existing
Dynamic Trading V2 trading window rather than implementing new inventory,
pricing or settlement code.

## Acceptance boundary

Asset geometry and transparency can pass offline; true PZ Build 42 font/icon
legibility, subtexture drawing, focus/hover behavior and SP/MP execution still
need native engine testing. This phase does **not** create the device OS.
