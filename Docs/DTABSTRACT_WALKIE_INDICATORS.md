# DTAbstract Radio OS — Walkie Indicators Atlas v1

This phase publishes the shared status artwork only. In-game Radio OS data,
network state and widget behavior are **not yet implemented**.

## Production texture

- Path: \`Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_Indicators.png\`
- PNG 512 × 256, RGBA with transparent gutters.
- Exactly 25 sprites matching \`DTA_Walkie_Manifest.lua\`:
  - 10 signal meters, green and amber, each with 0–4 signal bars.
  - 5 green battery meters, 0–4 charge segments.
  - 4 receive/transmit/muted/offline pictograms.
  - 6 **blank** status-chip backgrounds: standby, receiving, transmitting,
    signal_lost, offline, connecting. Localization strings are drawn at runtime.
- Original art inspired by Project Zomboid's grounded, muted, low-resolution
  survival interface. Not copied vanilla assets.

## Build

\`\`\`sh
python -m pip install Pillow==12.3.0
python tools/build_dtabstract_walkie_indicators.py \
  --output Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_Indicators.png \
  --layout /tmp/dta_indicators.json
\`\`\`

The builder validates bounds, sprite count, transparent corners and reserved
zones, absence of rectangle overlap, distinct signal/battery levels and
lossless PNG round trip. Workflow
\`.github/workflows/dtabstract_walkie_indicators.yml\` builds and commits the
production image on source changes, if Actions is enabled.

## Game integration behavior

The game supplies measured/factual state; these icons are **not a signal model**.

- Map validated battery condition/charge to 0–4 levels only where the actual
  device API exposes a meaningful quantity; use an unknown/omitted indicator
  when no data is available.
- Do not invent physical radio signal strength from an NPC's disposition,
  model appearance or a purely fictional frequency. An abstract "connected"
  state may be represented separately from four real signal levels.
- Network permission, device ownership, server authority and player proximity
  must be enforced in the behavior/service layers; changing a chip from red
  to green never authorizes a trade or a remote call.
- Render localized text on **top** of the blank status chip background.
  State changes select an existing sprite; do not rebuild an atlas at runtime.
- Cache the texture; share the indicator atlas across walkie, HAM and manpack
  screens whenever their app logic needs the same symbols.
- Draw and clip indicators within the actual per-device screen viewport.

## Next stages

1. Optional scanline/noise/glare Overlays atlas (must not conceal text).
2. Build 42 runtime subtexture and softkey hit-test smoke test.
3. Live Home, Contacts, Call and Trader Scan screens. The Trade action remains
   a bridge to existing DynamicTrading V2; no second trading implementation.
