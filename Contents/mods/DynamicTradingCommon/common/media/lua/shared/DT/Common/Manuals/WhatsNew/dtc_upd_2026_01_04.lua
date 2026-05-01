-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dtc_upd_2026_01_04",
--   "module": "DynamicTradingCommon",
--   "title": "Update: 12/17 - 01/04",
--   "description": "Trader Network Overhaul and UI Stability. Resolved critical bugs in trader network scanning, UI stability, and general trading system logic. — Updated archetype definitions to support the new dynamic trading features and fixes.",
--   "start_page_id": "cat_features",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 1,
--   "release_version": "",
--   "popup_version": "",
--   "auto_open_on_update": false,
--   "is_whats_new": true,
--   "manual_type": "whats_new",
--   "show_in_library": false,
--   "support_url": "",
--   "banner_title": "",
--   "banner_text": "",
--   "banner_action_label": "",
--   "source_folder": "WhatsNew",
--   "chapters": [
--     {
--       "id": "release_notes",
--       "title": "Release Notes",
--       "description": "Resolved critical bugs in trader network scanning, UI stability, and general trading system logic."
--     }
--   ],
--   "pages": [
--     {
--       "id": "cat_features",
--       "chapter_id": "release_notes",
--       "title": "Features",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_01_dynamictradingcommon",
--           "level": 2,
--           "text": "Expanded Temporary Trading Inventory"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Added a broad selection of new temporary items to the trading system.\n- Expanded the available inventory for dynamic player-to-player exchanges."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now trade a wider variety of temporary items."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2025_12_31_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading UI & Shop Inventory Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "- The shop interface now supports **dynamic buying and selling** with a new sell system and buy button.\n- UI improvements include text truncation for long names and automatic closure during daily resets.\n- Shop inventories have been significantly expanded with new data for electronics, clothing, and ammo.\n- Item selection now enforces a **minimum quantity of one** to prevent empty transactions."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now buy and sell items dynamically with a refreshed interface and expanded stock."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2025_12_30_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading UI and Economy Overhaul"
--         },
--         {
--           "type": "paragraph",
--           "text": "* **New Simple Market UI** allows players to browse items and check stock levels easily.\n* **Restock notices** now appear automatically when market inventory is empty.\n* Item categories are implemented to refine **economy pricing** and stock logic.\n* Internal file structure was reorganized to support future updates and stability."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Players can now view market stock, receive restock alerts, and benefit from a new category-based pricing system."
--         }
--       ]
--     },
--     {
--       "id": "cat_fixes",
--       "chapter_id": "release_notes",
--       "title": "Fixes",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Fixes Highlights",
--           "text": "Resolved critical bugs in trader network scanning, UI stability, and general trading system logic."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_02_dynamictradingcommon",
--           "level": 2,
--           "text": "Trader Network Scanning & UI Stability Fixes"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **Traders now require ham radios or walkie talkies** to access the store and scan for items.\n- Added a new daily scanning constraint and a dedicated scan button directly within the trader UI.\n- Fixed multiplayer synchronization issues and prevented log window overflow bugs.\n- Windows now auto-close if the player moves too far away or the device turns off."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Traders now require communication devices to scan, with improved UI stability and robust multiplayer sync."
--         }
--       ]
--     },
--     {
--       "id": "cat_misc",
--       "chapter_id": "release_notes",
--       "title": "Misc",
--       "keywords": [],
--       "blocks": [
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Misc Highlights",
--           "text": "Updated archetype definitions to support the new dynamic trading features and fixes."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_04_dynamictradingcommon",
--           "level": 2,
--           "text": "Dynamic Trading Wallets, Events & UI Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- **New wallet lottery system** and trader archetypes expand economic gameplay options.\n- Event system loop fixed to properly trigger modifications like scan chances.\n- Trading UI improved by hiding zero-value items and adding market info buttons.\n- Walkie-talkies now have a chance to spawn when looting corpses."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Enhances the trading economy with new wallet systems, event triggers, and refined interface details."
--         },
--         {
--           "type": "heading",
--           "id": "item_item_2026_01_03_dynamictradingcommon",
--           "level": 2,
--           "text": "Trading System Fixes and Archetype Updates"
--         },
--         {
--           "type": "paragraph",
--           "text": "- Daily trade limits and trader counts now reset correctly each day.\n- Added new item IDs and expanded trader archetypes for better variety.\n- The trade interface will now automatically close if the trader leaves."
--         },
--         {
--           "type": "callout",
--           "tone": "success",
--           "title": "Impact",
--           "text": "Resolves daily trade limits and improves trader variety for a smoother economy."
--         }
--       ]
--     }
--   ],
--   "raw_lua": null
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dtc_upd_2026_01_04", {
        title = "Update: 12/17 - 01/04",
        description = "Trader Network Overhaul and UI Stability. Resolved critical bugs in trader network scanning, UI stability, and general trading system logic. — Updated archetype definitions to support the new dynamic trading features and fixes.",
        startPageId = "cat_features",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 1,
        releaseVersion = "",
        popupVersion = "",
        autoOpenOnUpdate = false,
        isWhatsNew = true,
        manualType = "whats_new",
        showInLibrary = false,
        supportUrl = "",
        bannerTitle = "",
        bannerText = "",
        bannerActionLabel = "",
        chapters = {
            {
                id = "release_notes",
                title = "Release Notes",
                description = "Resolved critical bugs in trader network scanning, UI stability, and general trading system logic.",
            },
        },
        pages = {
            {
                id = "cat_features",
                chapterId = "release_notes",
                title = "Features",
                keywords = {  },
                blocks = {
                    { type = "heading", id = "item_item_2026_01_01_dynamictradingcommon", level = 2, text = "Expanded Temporary Trading Inventory" },
                    { type = "paragraph", text = "- Added a broad selection of new temporary items to the trading system.\n- Expanded the available inventory for dynamic player-to-player exchanges." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now trade a wider variety of temporary items." },
                    { type = "heading", id = "item_item_2025_12_31_dynamictradingcommon", level = 2, text = "Dynamic Trading UI & Shop Inventory Overhaul" },
                    { type = "paragraph", text = "- The shop interface now supports **dynamic buying and selling** with a new sell system and buy button.\n- UI improvements include text truncation for long names and automatic closure during daily resets.\n- Shop inventories have been significantly expanded with new data for electronics, clothing, and ammo.\n- Item selection now enforces a **minimum quantity of one** to prevent empty transactions." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now buy and sell items dynamically with a refreshed interface and expanded stock." },
                    { type = "heading", id = "item_item_2025_12_30_dynamictradingcommon", level = 2, text = "Dynamic Trading UI and Economy Overhaul" },
                    { type = "paragraph", text = "* **New Simple Market UI** allows players to browse items and check stock levels easily.\n* **Restock notices** now appear automatically when market inventory is empty.\n* Item categories are implemented to refine **economy pricing** and stock logic.\n* Internal file structure was reorganized to support future updates and stability." },
                    { type = "callout", tone = "success", title = "Impact", text = "Players can now view market stock, receive restock alerts, and benefit from a new category-based pricing system." },
                },
            },
            {
                id = "cat_fixes",
                chapterId = "release_notes",
                title = "Fixes",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Fixes Highlights", text = "Resolved critical bugs in trader network scanning, UI stability, and general trading system logic." },
                    { type = "heading", id = "item_item_2026_01_02_dynamictradingcommon", level = 2, text = "Trader Network Scanning & UI Stability Fixes" },
                    { type = "paragraph", text = "- **Traders now require ham radios or walkie talkies** to access the store and scan for items.\n- Added a new daily scanning constraint and a dedicated scan button directly within the trader UI.\n- Fixed multiplayer synchronization issues and prevented log window overflow bugs.\n- Windows now auto-close if the player moves too far away or the device turns off." },
                    { type = "callout", tone = "success", title = "Impact", text = "Traders now require communication devices to scan, with improved UI stability and robust multiplayer sync." },
                },
            },
            {
                id = "cat_misc",
                chapterId = "release_notes",
                title = "Misc",
                keywords = {  },
                blocks = {
                    { type = "callout", tone = "info", title = "Misc Highlights", text = "Updated archetype definitions to support the new dynamic trading features and fixes." },
                    { type = "heading", id = "item_item_2026_01_04_dynamictradingcommon", level = 2, text = "Dynamic Trading Wallets, Events & UI Updates" },
                    { type = "paragraph", text = "- **New wallet lottery system** and trader archetypes expand economic gameplay options.\n- Event system loop fixed to properly trigger modifications like scan chances.\n- Trading UI improved by hiding zero-value items and adding market info buttons.\n- Walkie-talkies now have a chance to spawn when looting corpses." },
                    { type = "callout", tone = "success", title = "Impact", text = "Enhances the trading economy with new wallet systems, event triggers, and refined interface details." },
                    { type = "heading", id = "item_item_2026_01_03_dynamictradingcommon", level = 2, text = "Trading System Fixes and Archetype Updates" },
                    { type = "paragraph", text = "- Daily trade limits and trader counts now reset correctly each day.\n- Added new item IDs and expanded trader archetypes for better variety.\n- The trade interface will now automatically close if the trader leaves." },
                    { type = "callout", tone = "success", title = "Impact", text = "Resolves daily trade limits and improves trader variety for a smoother economy." },
                },
            },
        },
    })
end
