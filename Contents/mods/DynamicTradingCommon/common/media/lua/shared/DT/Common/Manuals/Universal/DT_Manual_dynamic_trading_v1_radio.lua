-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dynamic_trading_v1_radio",
--   "module": "DynamicTradingCommon",
--   "title": "The Scavenger Radio Gu",
--   "description": "Master the airwaves to find merchants from your safehouse.",
--   "start_page_id": "radio_basics",
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
--       "id": "radio_operation",
--       "title": "Radio Operation",
--       "description": "Hardware and signal management."
--     },
--     {
--       "id": "trader_network",
--       "title": "The Trader Network",
--       "description": "Monitoring active signals and logs."
--     }
--   ],
--   "pages": [
--     {
--       "id": "radio_basics",
--       "chapter_id": "radio_operation",
--       "title": "Mastering the Frequencies",
--       "keywords": [
--         "radio",
--         "power",
--         "frequencies",
--         "scanning",
--         "signals"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "radio-intro",
--           "level": 1,
--           "text": "Remote Survival"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dynamic_trading_v1_radio/image_a0024cd0ee.png",
--           "caption": "",
--           "width": 220,
--           "height": 140,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.5714285714285714
--         },
--         {
--           "type": "paragraph",
--           "text": "Walking into a high-risk area for a trade run is a death sentence. The Trader Network & Logs UI lets you scan for signals and check market trends remotely from the safety of your walls."
--         },
--         {
--           "type": "paragraph",
--           "text": "At the top of the interface, you can see your current Signal Power (e.g., x1.5). This is determined by the quality of your radio hardware. Higher power multipliers allow you to punch through background noise and discover more distant traders."
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Scanning for Signals",
--           "text": "Use the SCAN FREQUENCIES button to search for nearby traders. Your active signal capacity is limited by your current equipment."
--         }
--       ]
--     },
--     {
--       "id": "signal_management",
--       "chapter_id": "trader_network",
--       "title": "Managing Active Signals",
--       "keywords": [
--         "active",
--         "signals",
--         "expiry",
--         "traders",
--         "locking"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "signal-locking",
--           "level": 1,
--           "text": "Locking the Frequency"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dynamic_trading_v1_radio/image_3719216676.png",
--           "caption": "",
--           "width": 220,
--           "height": 140,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.5714285714285714
--         },
--         {
--           "type": "paragraph",
--           "text": "Once a frequency is locked in, the signal will appear in your Active Signals list. Each trader will show an Expiry Timer (e.g., 8h, 22h) representing how much longer the signal will remain stable. Once the timer reaches zero, the signal will fade and you will need to rescan."
--         },
--         {
--           "type": "callout",
--           "tone": "warn",
--           "title": "Remote Intelligence",
--           "text": "Click the VIEW MARKET INFO button at any time to see the global trends and event data affecting all known factions across the trader network!"
--         }
--       ]
--     },
--     {
--       "id": "network_logs",
--       "chapter_id": "trader_network",
--       "title": "Monitoring the Log",
--       "keywords": [
--         "logs",
--         "history",
--         "signals",
--         "tracking"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "log-tracking",
--           "level": 1,
--           "text": "The Network Log"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dynamic_trading_v1_radio/image_a3cfbd9135.png",
--           "caption": "",
--           "width": 220,
--           "height": 140,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.5714285714285714
--         },
--         {
--           "type": "paragraph",
--           "text": "The bottom of the interface is the Network Log, a live timestamped history of all signal activity. This log is an invaluable tool for tracking who you have spoken to and which factions they represent across multiple sessions."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Signal Acquired: Confirms a frequency lock and identifies the trader and faction.",
--             "Signal Lost: Occurs when a trader goes offline, out of range, or their broadcast window expires.",
--             "Historical Data: Use these logs to identify patterns if a faction keeps appearing on the same frequencies."
--           ]
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dynamic_trading_v1_radio", {
        title = "The Scavenger Radio Gu",
        description = "Master the airwaves to find merchants from your safehouse.",
        startPageId = "radio_basics",
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
                id = "radio_operation",
                title = "Radio Operation",
                description = "Hardware and signal management.",
            },
            {
                id = "trader_network",
                title = "The Trader Network",
                description = "Monitoring active signals and logs.",
            },
        },
        pages = {
            {
                id = "radio_basics",
                chapterId = "radio_operation",
                title = "Mastering the Frequencies",
                keywords = { "radio", "power", "frequencies", "scanning", "signals" },
                blocks = {
                    { type = "heading", id = "radio-intro", level = 1, text = "Remote Survival" },
                    { type = "image", path = "media/ui/Manuals/dynamic_trading_v1_radio/image_a0024cd0ee.png", caption = "", width = 220, height = 140 },
                    { type = "paragraph", text = "Walking into a high-risk area for a trade run is a death sentence. The Trader Network & Logs UI lets you scan for signals and check market trends remotely from the safety of your walls." },
                    { type = "paragraph", text = "At the top of the interface, you can see your current Signal Power (e.g., x1.5). This is determined by the quality of your radio hardware. Higher power multipliers allow you to punch through background noise and discover more distant traders." },
                    { type = "callout", tone = "info", title = "Scanning for Signals", text = "Use the SCAN FREQUENCIES button to search for nearby traders. Your active signal capacity is limited by your current equipment." },
                },
            },
            {
                id = "signal_management",
                chapterId = "trader_network",
                title = "Managing Active Signals",
                keywords = { "active", "signals", "expiry", "traders", "locking" },
                blocks = {
                    { type = "heading", id = "signal-locking", level = 1, text = "Locking the Frequency" },
                    { type = "image", path = "media/ui/Manuals/dynamic_trading_v1_radio/image_3719216676.png", caption = "", width = 220, height = 140 },
                    { type = "paragraph", text = "Once a frequency is locked in, the signal will appear in your Active Signals list. Each trader will show an Expiry Timer (e.g., 8h, 22h) representing how much longer the signal will remain stable. Once the timer reaches zero, the signal will fade and you will need to rescan." },
                    { type = "callout", tone = "warn", title = "Remote Intelligence", text = "Click the VIEW MARKET INFO button at any time to see the global trends and event data affecting all known factions across the trader network!" },
                },
            },
            {
                id = "network_logs",
                chapterId = "trader_network",
                title = "Monitoring the Log",
                keywords = { "logs", "history", "signals", "tracking" },
                blocks = {
                    { type = "heading", id = "log-tracking", level = 1, text = "The Network Log" },
                    { type = "image", path = "media/ui/Manuals/dynamic_trading_v1_radio/image_a3cfbd9135.png", caption = "", width = 220, height = 140 },
                    { type = "paragraph", text = "The bottom of the interface is the Network Log, a live timestamped history of all signal activity. This log is an invaluable tool for tracking who you have spoken to and which factions they represent across multiple sessions." },
                    { type = "bullet_list", items = { "Signal Acquired: Confirms a frequency lock and identifies the trader and faction.", "Signal Lost: Occurs when a trader goes offline, out of range, or their broadcast window expires.", "Historical Data: Use these logs to identify patterns if a faction keeps appearing on the same frequencies." } },
                },
            },
        },
    })
end
