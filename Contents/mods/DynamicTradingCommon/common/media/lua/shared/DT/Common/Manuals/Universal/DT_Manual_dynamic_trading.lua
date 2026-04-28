-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dynamic_trading",
--   "module": "DynamicTradingCommon",
--   "title": "Manual Guide",
--   "description": "Overview pages for mod system and quick links for major systems.",
--   "start_page_id": "intro",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 1,
--   "release_version": "",
--   "popup_version": "",
--   "auto_open_on_update": false,
--   "is_whats_new": false,
--   "manual_type": "manual",
--   "show_in_library": true,
--   "support_url": "",
--   "banner_title": "",
--   "banner_text": "",
--   "banner_action_label": "",
--   "source_folder": "Universal",
--   "chapters": [
--     {
--       "id": "getting_started",
--       "title": "Getting Started",
--       "description": "Core concepts and how to open trading-related interfaces."
--     },
--     {
--       "id": "systems",
--       "title": "Systems",
--       "description": "High-level explanations of the main DT subsystems."
--     }
--   ],
--   "pages": [
--     {
--       "id": "intro",
--       "chapter_id": "getting_started",
--       "title": "Introduction",
--       "keywords": [
--         "guide",
--         "manual",
--         "start",
--         "intro"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "overview",
--           "level": 1,
--           "text": "Dynamic Trading Overview"
--         },
--         {
--           "type": "paragraph",
--           "text": "Dynamic Trading Commons now supports in-game manuals that can be opened from the Options window or from any custom button callback."
--         },
--         {
--           "type": "paragraph",
--           "text": "Use the navigation on the left to move between chapters and pages. Use search to jump directly to a section in any registered manual."
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Backgrounds/dawn.png",
--           "caption": "Manual pages can embed images using any valid in-mod texture path.",
--           "width": 227,
--           "height": 147,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.5442176870748299
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Deep Link Example",
--           "text": "DynamicTrading.Manuals.Open({ manualId = \"dynamic_trading\", pageId = \"trading_window\", sectionId = \"trade-flow\" })"
--         }
--       ]
--     },
--     {
--       "id": "open_manual",
--       "chapter_id": "getting_started",
--       "title": "Opening The Manual",
--       "keywords": [
--         "options",
--         "open",
--         "launcher"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "options-window",
--           "level": 1,
--           "text": "Options Window Launcher"
--         },
--         {
--           "type": "paragraph",
--           "text": "Open the Dynamic Trading settings window and switch to the Manuals tab. From there you can launch the library or jump straight into a registered manual."
--         },
--         {
--           "type": "heading",
--           "id": "custom-buttons",
--           "level": 2,
--           "text": "Custom Buttons"
--         },
--         {
--           "type": "paragraph",
--           "text": "Any custom UI or dialogue callback can call the manual API directly. The API accepts a manual id, page id, optional section id, and an optional search query."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Use page ids for stable quick links.",
--             "Use heading block ids for section-level jumps.",
--             "Search works across all registered manuals."
--           ]
--         }
--       ]
--     },
--     {
--       "id": "trading_window",
--       "chapter_id": "systems",
--       "title": "Trading Window",
--       "keywords": [
--         "trade",
--         "window",
--         "inventory",
--         "pricing"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "trade-flow",
--           "level": 1,
--           "text": "Trade Flow"
--         },
--         {
--           "type": "paragraph",
--           "text": "Open a trader, review the available stock, and compare prices before confirming the transaction. The exact provider may differ between radio and NPC trading, but the core window behavior is shared."
--         },
--         {
--           "type": "callout",
--           "tone": "warn",
--           "title": "Tip",
--           "text": "Use deep links from dialogue options to bring players into a specific manual section right when they need help."
--         },
--         {
--           "type": "heading",
--           "id": "pricing-basics",
--           "level": 2,
--           "text": "Pricing Basics"
--         },
--         {
--           "type": "paragraph",
--           "text": "Prices are influenced by item tags, rarity, stock rules, and active economy systems. Search for terms like pricing, stock, or economy to jump to related help pages once more manuals are added."
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dynamic_trading", {
        title = "Manual Guide",
        description = "Overview pages for mod system and quick links for major systems.",
        startPageId = "intro",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 1,
        releaseVersion = "",
        popupVersion = "",
        autoOpenOnUpdate = false,
        isWhatsNew = false,
        manualType = "manual",
        showInLibrary = true,
        supportUrl = "",
        bannerTitle = "",
        bannerText = "",
        bannerActionLabel = "",
        chapters = {
            {
                id = "getting_started",
                title = "Getting Started",
                description = "Core concepts and how to open trading-related interfaces.",
            },
            {
                id = "systems",
                title = "Systems",
                description = "High-level explanations of the main DT subsystems.",
            },
        },
        pages = {
            {
                id = "intro",
                chapterId = "getting_started",
                title = "Introduction",
                keywords = { "guide", "manual", "start", "intro" },
                blocks = {
                    { type = "heading", id = "overview", level = 1, text = "Dynamic Trading Overview" },
                    { type = "paragraph", text = "Dynamic Trading Commons now supports in-game manuals that can be opened from the Options window or from any custom button callback." },
                    { type = "paragraph", text = "Use the navigation on the left to move between chapters and pages. Use search to jump directly to a section in any registered manual." },
                    { type = "image", path = "media/ui/Backgrounds/dawn.png", caption = "Manual pages can embed images using any valid in-mod texture path.", width = 227, height = 147 },
                    { type = "callout", tone = "info", title = "Deep Link Example", text = "DynamicTrading.Manuals.Open({ manualId = \"dynamic_trading\", pageId = \"trading_window\", sectionId = \"trade-flow\" })" },
                },
            },
            {
                id = "open_manual",
                chapterId = "getting_started",
                title = "Opening The Manual",
                keywords = { "options", "open", "launcher" },
                blocks = {
                    { type = "heading", id = "options-window", level = 1, text = "Options Window Launcher" },
                    { type = "paragraph", text = "Open the Dynamic Trading settings window and switch to the Manuals tab. From there you can launch the library or jump straight into a registered manual." },
                    { type = "heading", id = "custom-buttons", level = 2, text = "Custom Buttons" },
                    { type = "paragraph", text = "Any custom UI or dialogue callback can call the manual API directly. The API accepts a manual id, page id, optional section id, and an optional search query." },
                    { type = "bullet_list", items = { "Use page ids for stable quick links.", "Use heading block ids for section-level jumps.", "Search works across all registered manuals." } },
                },
            },
            {
                id = "trading_window",
                chapterId = "systems",
                title = "Trading Window",
                keywords = { "trade", "window", "inventory", "pricing" },
                blocks = {
                    { type = "heading", id = "trade-flow", level = 1, text = "Trade Flow" },
                    { type = "paragraph", text = "Open a trader, review the available stock, and compare prices before confirming the transaction. The exact provider may differ between radio and NPC trading, but the core window behavior is shared." },
                    { type = "callout", tone = "warn", title = "Tip", text = "Use deep links from dialogue options to bring players into a specific manual section right when they need help." },
                    { type = "heading", id = "pricing-basics", level = 2, text = "Pricing Basics" },
                    { type = "paragraph", text = "Prices are influenced by item tags, rarity, stock rules, and active economy systems. Search for terms like pricing, stock, or economy to jump to related help pages once more manuals are added." },
                },
            },
        },
    })
end
