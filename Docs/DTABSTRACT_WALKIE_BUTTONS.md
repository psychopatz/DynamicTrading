# DTAbstract Radio OS — Modular Buttons Atlas

Status: Build-time asset generation implemented. Native Project Zomboid UI
drawing, interactive button logic and automatic layout scaling are **not yet implemented**.

## Runtime texture

`Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_Buttons.png`

- Size: **1024×512** with transparent gutters.
- **36** components matching the existing `DTA_Walkie_Manifest.lua` button
  rectangle IDs and positions. All PNG pixels outside sprites are alpha-zero.
- Square softkeys: 64×32, green/dark/amber/red × idle/hover/pressed/disabled.
- Wide softkeys: 144×40, green/dark × idle/hover/pressed/disabled.
- Call/hangup backgrounds: 80×40, 4 states each, green/red.
- Tabs: 112×36, idle/hover/active/disabled.
- Cap insets already specified in the manifest (6 or 8 pixels). Use 9-slicing
  when resizing the button backgrounds; never distort the corner art.

## Dynamic composition contract

A button consists of the atlas background state, separately supplied **icon**,
localized **label**, focus/click behavior and optional tooltip. No icon or text
is painted into this atlas.

State priority: disabled > pressed > hover/focus > selected/active > idle.
Runtime code must choose the correct sprite on pointer/key input; these files
do **not** make a clickable control automatically.

When rendering a physical device, clickable **screen UI buttons** must be
strictly clipped to the device's screen viewport. Separately define three
hardware softkey hitboxes via the existing device manifest; input hit testing
must not assume every softkey is at the same position across skins.

## Design notes

Matte, worn, low-saturation colors follow the existing DTAbstract UI Core
palette, inspired by Project Zomboid styling. Not an extracted vanilla sprite.
The background center is quiet for readable dynamic glyphs at native scale.
Hover uses brighter corners; pressed depresses the bevel; disabled fades.

## Reproduce

```sh
python -m pip install Pillow==12.3.0
python tools/build_dtabstract_walkie_buttons.py \
  --output Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_Buttons.png \
  --map /tmp/dta_buttons_layout.json
```

The builder validates 36 regions, bounds, alpha gutters, lack of overlaps,
distinct visual states and an exact RGBA PNG round trip.

The GitHub Actions workflow `.github/workflows/dtabstract_walkie_buttons.yml`
automatically commits the generated PNG after a source change, provided
repository Actions permissions allow it.

## Follow-up

Build the Icons atlas, Indicators atlas, and optional Overlays atlas. Then
implement and validate a client Radio OS window in Build 42: Home, Contacts,
Call and Trader Scan. The **Trade** action must open the existing Dynamic
Trading V2 window; do not duplicate shopping, quoting or settlement UI.
