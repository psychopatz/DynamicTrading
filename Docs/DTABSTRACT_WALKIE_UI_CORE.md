# DTAbstract Radio OS — UI Core atlas

Source script: `tools/build_dtabstract_walkie_ui_core.py`

Game texture: `Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_UI_Core.png`

## V1 contract

- 1024 × 1024 transparent PNG, 25 non-overlapping atlas rectangles.
- Positions, IDs and dimensions must exactly match the `core` entries in `DTA_Walkie_Manifest.lua`. All dimensions are source pixels with a top-left origin.
- Muted Project Zomboid-inspired green, amber and dark CRT/LCD panels; not extracted or copied vanilla game artwork.
- Contains LCD backgrounds, title/footer/tab bars, list rows, dialogs, home app tiles, two transparent portrait-frame openings, a contact card and a status strip.
- NO baked NPC names, portraits, app icon labels, trader prices, scan results or frequency readouts. Render these on the device OS at runtime.
- A portrait frame has transparent center. Backing and portrait go underneath it; the frame is a foreground overlay.
- Reusable 9-slice cap insets come from the manifest and must be confirmed at native game scale. The script generates decorative corner ticks only inside the caps.
- Runtime must clip all content to the active device screen viewport and cache the atlas texture. Use uniform scale and avoid per-frame image loads.

## Build and verify

```sh
python -m pip install 'Pillow==12.3.0'
python tools/build_dtabstract_walkie_ui_core.py \
  --output Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/ui/DTA_Walkie_UI_Core.png
```

The generator executes bounding-box, alpha, sprite overlap and portrait hole checks before writing the image.

A narrowly scoped GitHub Actions workflow `.github/workflows/dtabstract_walkie_ui_core.yml` regenerates and commits this exact binary when its builder or workflow changes on main. Its only write permission is repository contents. Whether the workflow runs depends on repository Actions permissions, which must be verified separately.

## Integration boundary

- *This is art + metadata, not yet a functioning radio OS.*
- Walkie device detection, radio power/access validation, Home/Contacts/Call/Trader Scan navigation, Project Hoomans portrait integration, hover/hit-testing, B42 atlas drawing API validation and native SP/MP tests remain future steps.
- Trade continues to open the existing Dynamic Trading V2 trade UI. Do not create a second trade basket or payment lane in the radio renderer.

## Production ordering

1. Walkie shells and precise screen regions (previous asset stage).
2. **UI Core** (this stage).
3. Modular Buttons atlas with idle/hover/pressed/disabled.
4. Icons, signal/battery indicators and optional screen overlays.
5. Client UI renderer and app router, keeping data/event ownership separate.
