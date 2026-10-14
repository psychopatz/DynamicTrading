# DTAbstract Radio OS — Optional Screen Overlays

Status: Build-time artwork stage complete. This is not an implemented Radio OS.

Production sprite: \`Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_Overlays.png\`

The 512×512 RGBA PNG holds exactly eight manifest-aligned components:

| ID | PNG rect x,y,w,h | Usage |
|---|---|---|
| overlay_scanlines_green | 16,16,160,160 | Low-opacity green CRT rows |
| overlay_scanlines_amber | 192,16,160,160 | Low-opacity amber CRT rows |
| overlay_noise_light | 16,192,160,160 | Subtle deterministic interference |
| overlay_noise_heavy | 192,192,160,160 | More intense interference (only conditionally) |
| overlay_glare_soft | 16,368,160,96 | Low-alpha pale reflection |
| overlay_glow_green | 192,368,160,96 | Subtle green perimeter glow |
| overlay_mask_square | 368,16,128,128 | Decorative green square frame/corners |
| overlay_mask_wide | 368,160,128,64 | Decorative amber wide frame/corners |

These exact bounds were already declared in \`DTA_Walkie_Manifest.lua\`.
No manifest changes are necessary. All sprite backgrounds are transparent.
No portraits, conversations, frequencies, fixed text, status measurements or
app-specific content are baked in. Source art is original and only inspired
by the muted Project Zomboid interface aesthetic, not pulled from vanilla assets.

## Build and test

\`\`\`sh
python -m pip install 'Pillow==12.3.0'
python tools/build_dtabstract_walkie_overlays.py \
  --output Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_Overlays.png \
  --preview /tmp/dta_overlays_preview.png \
  --map /tmp/dta_overlays.json
\`\`\`

The builder validates all eight sprites, alpha transparency, bounds, absent
overlap, non-opaque effect channels, zero-alpha centers in decorative frames,
unused atlas regions and byte-identical PNG serialization.

The workflow \`.github/workflows/dtabstract_walkie_overlays.yml\` creates and
commits the actual PNG to \`main\` when the source changes; repository Actions
permissions must permit the write.

## Important UI behavior

- These are **optional compositing effects**, not UI functionality.
- IDs containing \`mask\` are decorative screen border overlays, **not**
  scissor masks or stencil/alpha clipping operations. The game's UI renderer
  must clip its NPC portraits, text, and app widgets to the actual screen
  bounds, independently from these images.
- Prefer **static** screen noise textures. Do not regenerate noise per tick or
  load a PNG within a render loop. Cache atlas textures once per client UI.
- The scanline/glare effects are deliberately low alpha; preserve legibility.
  Keep them off by default in settings where readability is a concern.
- Only show heavy noise in an actual lost/interfered state; do not fabricate
  network or signal strength from a cosmetic texture.
- Render LCD backing -> dynamic content -> optional effects -> alpha-cutout
  radio shell -> interactive hitbox highlights. Avoid drawing effects outside
  the viewport.
- The real UI should use cached subtexture UV regions from the manifest,
  with B42 native API and clipping validated in the next implementation stage.

## Next stage: working Radio OS

The visual foundations for \`UI_Core\`, \`Buttons\`, \`Icons\`,
\`Indicators\`, and \`Overlays\` are present; shell artwork still needs
a verified binary commit. Build a small test window using the existing
authored assets, then add app routing for Home, Contacts, Call and Scanner.
Bridge Trade to the existing DynamicTrading V2 window; do not reproduce
pricing/settlement or inventory code inside the Radio OS.
