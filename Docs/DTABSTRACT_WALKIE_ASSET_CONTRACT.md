# DTAbstract Radio OS — Walkie Asset Contract v1

Status: **manifest implemented, Lua metadata tested; artwork/layout and native B42 rendering not yet validated.**

## Deliverables

- `DTA_Walkie_Manifest.lua` — six exact vanilla handheld item IDs, 1024×1024 walkie shell atlas, reusable UI chrome/buttons/icons/indicators/overlays, coordinate metadata, scale-independent screen bounds, lookup helpers and contract validation.
- `test_DTA_Walkie_Manifest.lua` — non-game Lua smoke test. Command: `texlua test_DTA_Walkie_Manifest.lua DTA_Walkie_Manifest.lua` (or use an ordinary Lua interpreter).

## Where to place the files

```text
Contents/mods/DTAbstract/42.20/media/
  lua/client/DTAbstract/UI/DTA_Walkie_Manifest.lua
  ui/dtabstract/radio/shells/DTA_Walkie_Shells.png
  ui/dtabstract/radio/ui/DTA_Walkie_UI_Core.png
  ui/dtabstract/radio/ui/DTA_Walkie_Buttons.png
  ui/dtabstract/radio/ui/DTA_Walkie_Icons.png
  ui/dtabstract/radio/ui/DTA_Walkie_Indicators.png
  ui/dtabstract/radio/ui/DTA_Walkie_Overlays.png
```

The `.png` filenames above are *planned atlas outputs*, **not included** in this package.

## Coordinate contract

- All positions `x,y,w,h` are integer PNG pixels, origin top-left, rectangles half-open.
- Shell sheet: 1024×1024. Six cells 256×432 at (32,32), (320,32), (608,32), (32,496), (320,496), (608,496).
- All screen rectangles and three physical button hit regions are local to their shell cell; use `ScreenBounds(skinId, scale, winX, winY)` to convert the screen viewport into window coordinates.
- Each screen cutout in the **shell art** must have alpha 0 all the way to the bezel's inner edge. Draw a colored LCD backing in the same viewport before compositing portrait/UI.
- No NPC names, dialogue, portraits, fixed app icons, user strings, or trader listings inside shell artwork; those belong in live OS widgets.
- UI buttons contain state-only backgrounds. Draw label and icon separately at runtime.
- Do not distort the shell: a 256×432 source body should be shown at 256×432 × uniform scale. At 1.0×, the production US Army screen cutout is **72×55** pixels; use a larger uniform radio UI scale or very compact/paginated content. Do not distort the shell to make it fit.
- Keep text/portrait inside the screen viewport. Clip portrait rendering; alpha=0 cutout alone does **not** clip overflow from a too-large portrait.

## Asset sourcing limitation

The supplied image `image.png` is a **1536×1024 concept sprite sheet**, not an atlas that already conforms to the 1024×1024 layout defined here. The rects in the manifest are *production targets*. Do **not** apply them to the concept image and assume the six full shells or cutouts will align.

Before shipping: create a new 1024×1024 shell sheet conforming to the rects, using the concept as visual reference, then inspect the alpha channel. If a design's antenna/body exceeds its 256×432 cell, adjust the master atlas + manifest together rather than clipping it silently.

## Project Zomboid rendering seam

Official UIElement Java documentation describes `DrawSubTextureRGBA` and `DrawUVSliceTexture`; public Lua documentation exposes `ISUIElement:drawSubTexture`. These can potentially draw a single region from an atlas without exporting every button as a separate file. **Verify which wrapper/signature works in the user's installed B42 build before wiring the renderer.**

Example *proposed* PZ Lua usage after verifying the local wrapper:

```lua
local A = require "DTAbstract/UI/DTA_Walkie_Manifest"
local skin = assert(A.GetSkin("Base.WalkieTalkie5"))
local path, r = A.GetSprite(skin.sprite)
local texture = getTexture(path) -- cache once, not on every frame
-- self:drawSubTexture(texture, r.x, r.y, r.w, r.h,
--     windowX, windowY, r.w * scale, r.h * scale, 1, 1, 1, 1, 1)
```

For the screen: render blank LCD backing, then UI/portrait/text, then optional scanlines, then the alpha-cutout shell and interactive controls. The **existing V2 trade window stays separate**; radio Trade app navigates into that interface rather than baking a second shop display into radio art.

## Follow-on work

1. Produce pixel-aligned transparent production shell atlas and inspect screen-hole alpha.
2. Produce Core, Buttons, Icons, Indicators, Overlays at the manifest rects.
3. Add a minimal client-only radio renderer: home screen, contact list, call portrait, trader scan, softkeys. Use real device IDs and actual powered/usable radio capability when supported.
4. Bridge the Trade app to existing DynamicTrading V2 trade UI, not a duplicate transaction implementation.
5. Verify in native SP and MP and profile redraw cost. No per-frame texture loads or catalog scans.

Source references for rendering APIs:
- https://projectzomboid.com/modding/zombie/ui/UIElement.html
- https://projectzomboid.com/modding/zombie/core/textures/Texture.html
- https://demiurgequantified.github.io/ProjectZomboidLuaDocs/classMainOptions-members.html


## First atlas authoring pass (2026-10-14)

The six-shell production atlas has been composed locally from a 1448×1086
approved concept sheet into a 1024×1024 transparent PNG. The authoring script
`tools/build_dtabstract_walkie_shells.py` reproduces layout from that reference.
The calculated screen rectangles and front button hotspots **replace**
the earlier illustrative coordinates in the Lua manifest.

All six screen rectangles were checked to contain only alpha=0 pixels; the
separate alignment preview verified the visible shell/button locations.

**Publication status:** this source commit does not include the binary PNG or
the original input concept art. The asset must be transferred separately to
`Contents/mods/DTAbstract/42.20/media/ui/dtabstract/radio/shells/DTA_Walkie_Shells.png`
before enabling the skin in-game. Never claim the artwork is installed just
because manifest tests pass.

To reproduce from the original approved concept sheet:

```sh
python tools/build_dtabstract_walkie_shells.py --source path/to/approved_concept.png --layout /tmp/walkie-atlas-layout.json
```

The manifest shell rectangles are unchanged at 256×432 each.
The display cutouts now range from roughly 72–83 px wide and 55–61 px tall,
so the portrait must be bounded/cropped carefully. Future art with larger
LCD holes must regenerate both atlas and manifest together.
