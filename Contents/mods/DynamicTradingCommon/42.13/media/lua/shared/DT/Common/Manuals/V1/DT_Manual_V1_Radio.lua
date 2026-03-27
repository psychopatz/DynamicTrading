-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_v1_radio",
--   "title": "The Scavenger's Radio Guide",
--   "description": "Mastering the airwaves to secure supplies from the safety of your safehouse.",
--   "start_page_id": "radio_basics",
--   "chapters": [
--     { "id": "equipment", "title": "Field Equipment", "description": "Choosing the right hardware for the job." },
--     { "id": "interaction", "title": "Establishing Contact", "description": "Tuning into the hidden markets of Kentucky." }
--   ],
--   "pages": [
--     {
--       "id": "radio_basics",
--       "chapter_id": "equipment",
--       "title": "Remote Survival",
--       "keywords": ["radio", "v1", "remote", "wireless", "safehouse"],
--       "blocks": [
--         { "type": "heading", "id": "radio-utility", "level": 1, "text": "Why Radio?" },
--         { "type": "paragraph", "text": "Walking into West Point with a backpack full of gold is a death sentence. The radio lets you deal with merchants from the relative safety of your own walls. It’s the difference between a desperate sprint through the streets and a calculated business transaction." },
--         { "type": "image", "path": "media/ui/Radio/Signal_found/1.png", "caption": "A steady signal is your lifeline.", "width": 64, "height": 64 }
--       ]
--     },
--     {
--       "id": "radio_tiers",
--       "chapter_id": "equipment",
--       "title": "Radio Tiers",
--       "keywords": ["tiers", "power", "capacity", "military", "ham"],
--       "blocks": [
--         { "type": "heading", "id": "hardware-selection", "level": 1, "text": "Ten Tiers of Technology" },
--         { "type": "paragraph", "text": "From scavenged toy walkie-talkies to high-end military manpacks, there are ten tiers of gear to track down. Each upgrade offers two critical improvements:" },
--         { "type": "bullet_list", "items": [
--             "Signal Reach: Higher tiers cut through the static, allowing you to find traders further out in the exclusion zone.",
--             "Signal Channels: Better hardware can maintain more trader frequencies at once without losing the lock."
--         ]},
--         { "type": "callout", "tone": "info", "title": "Field Observation", "text": "The Tier 10 Military Ham Radio is a beast. I managed to lock onto 20 different traders from a single rooftop in Louisville. Keep an eye out in military outposts." }
--       ]
--     },
--     {
--       "id": "signal_discovery",
--       "chapter_id": "interaction",
--       "title": "Scanning the Static",
--       "keywords": ["signals", "discovery", "polling", "scanning"],
--       "blocks": [
--         { "type": "heading", "id": "finding-traders", "level": 1, "text": "Locking the Signal" },
--         { "type": "paragraph", "text": "Finding a trader isn't manual; it's a game of patience. Your radio constantly scans the background noise. Depending on your location and the radio's power, new signals will pop up in your 'Trader List' as they become active." },
--         { "type": "paragraph", "text": "Once a signal is locked, you can monitor their stock in real-time. If they go offline or move out of range, the signal will fade, and you'll have to rescan." }
--       ]
--     },
--     {
--       "id": "remote_interaction",
--       "chapter_id": "interaction",
--       "title": "The Trade Interface",
--       "keywords": ["interface", "ui", "delivery", "transaction"],
--       "blocks": [
--         { "type": "heading", "id": "radio-trading", "level": 1, "text": "Executing the Deal" },
--         { "type": "paragraph", "text": "Once you've tuned in, the 'Radio Interface' handles the heavy lifting. You can swap goods and currency over the airwaves. Just remember: even with a Tier 10 radio, the faction wealth and market fluctuations are still very real. If the signal is weak, checking your stock might take a moment as the interface 'polls' the remote merchant." },
--         { "type": "callout", "tone": "warn", "title": "Technical Note", "text": "Always wait for the signal bars to turn green before confirming a high-value exchange. Desyncs happen in the wasteland too." }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_v1_radio", {
        title = "The Scavenger's Radio Guide",
        description = "Mastering the airwaves to secure supplies from the safety of your safehouse.",
        audiences = { "v1" },
        startPageId = "radio_basics",
        chapters = {
            { id = "equipment", title = "Field Equipment", description = "Choosing the right hardware for the job." },
            { id = "interaction", title = "Establishing Contact", description = "Tuning into the hidden markets of Kentucky." },
        },
        pages = {
            {
                id = "radio_basics",
                chapterId = "equipment",
                title = "Remote Survival",
                keywords = { "radio", "v1", "remote", "wireless", "safehouse" },
                blocks = {
                    { type = "heading", id = "radio-utility", level = 1, text = "Why Radio?" },
                    { type = "paragraph", text = "Walking into West Point with a backpack full of gold is a death sentence. The radio lets you deal with merchants from the relative safety of your own walls. It’s the difference between a desperate sprint through the streets and a calculated business transaction." },
                    { type = "image", path = "media/ui/Radio/Signal_found/1.png", caption = "A steady signal is your lifeline.", width = 64, height = 64 },
                },
            },
            {
                id = "radio_tiers",
                chapterId = "equipment",
                title = "Radio Tiers",
                keywords = { "tiers", "power", "capacity", "military", "ham" },
                blocks = {
                    { type = "heading", id = "hardware-selection", level = 1, text = "Ten Tiers of Technology" },
                    { type = "paragraph", text = "From scavenged toy walkie-talkies to high-end military manpacks, there are ten tiers of gear to track down. Each upgrade offers two critical improvements:" },
                    { type = "bullet_list", items = {
                        "Signal Reach: Higher tiers cut through the static, allowing you to find traders further out in the exclusion zone.",
                        "Signal Channels: Better hardware can maintain more trader frequencies at once without losing the lock."
                    } },
                    { type = "callout", tone = "info", title = "Field Observation", text = "The Tier 10 Military Ham Radio is a beast. I managed to lock onto 20 different traders from a single rooftop in Louisville. Keep an eye out in military outposts." },
                },
            },
            {
                id = "signal_discovery",
                chapterId = "interaction",
                title = "Scanning the Static",
                keywords = { "signals", "discovery", "polling", "scanning" },
                blocks = {
                    { type = "heading", id = "finding-traders", level = 1, text = "Locking the Signal" },
                    { type = "paragraph", text = "Finding a trader isn't manual; it's a game of patience. Your radio constantly scans the background noise. Depending on your location and the radio's power, new signals will pop up in your 'Trader List' as they become active." },
                    { type = "paragraph", text = "Once a signal is locked, you can monitor their stock in real-time. If they go offline or move out of range, the signal will fade, and you'll have to rescan." },
                },
            },
            {
                id = "remote_interaction",
                chapterId = "interaction",
                title = "The Trade Interface",
                keywords = { "interface", "ui", "delivery", "transaction" },
                blocks = {
                    { type = "heading", id = "radio-trading", level = 1, text = "Executing the Deal" },
                    { type = "paragraph", text = "Once you've tuned in, the 'Radio Interface' handles the heavy lifting. You can swap goods and currency over the airwaves. Just remember: even with a Tier 10 radio, the faction wealth and market fluctuations are still very real. If the signal is weak, checking your stock might take a moment as the interface 'polls' the remote merchant." },
                    { type = "callout", tone = "warn", title = "Technical Note", text = "Always wait for the signal bars to turn green before confirming a high-value exchange. Desyncs happen in the wasteland too." },
                },
            },
        },
    })
end
