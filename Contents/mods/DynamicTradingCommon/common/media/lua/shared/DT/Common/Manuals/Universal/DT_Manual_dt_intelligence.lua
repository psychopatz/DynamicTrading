-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_intelligence",
--   "module": "DynamicTradingCommon",
--   "title": "Faction Intelligence",
--   "description": "Guide to monitoring faction wealth, survival, and economic trends.",
--   "start_page_id": "intel_overview",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 2,
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
--       "id": "public_intel",
--       "title": "Public Intelligence",
--       "description": "Understanding reputations and basic faction info."
--     },
--     {
--       "id": "deep_intel",
--       "title": "Deep Logistics",
--       "description": "Monitoring stockpiles, population, and market trends."
--     }
--   ],
--   "pages": [
--     {
--       "id": "intel_overview",
--       "chapter_id": "public_intel",
--       "title": "The Intelligence Window",
--       "keywords": [
--         "intel",
--         "intelligence",
--         "ui",
--         "window"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "intel-intro",
--           "level": 1,
--           "text": "The Intelligence Window"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dt_intelligence/image.png",
--           "caption": "",
--           "width": 0,
--           "height": 141,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.5714285714285714
--         },
--         {
--           "type": "paragraph",
--           "text": "Knowledge is as valuable as ammunition. The Faction Intelligence window is your tactical dashboard for the entire exclusion zone. It allows you to monitor the health, wealth, and stability of every group you've encountered."
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Field Tip",
--           "text": "Access the Intelligence window through the radio(V1) or scanner/info(v2)"
--         }
--       ]
--     },
--     {
--       "id": "reputation_system",
--       "chapter_id": "public_intel",
--       "title": "Reputation & Trust",
--       "keywords": [
--         "faction",
--         "standing",
--         "reputation",
--         "trust"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "trust-mechanics",
--           "level": 1,
--           "text": "Factions & Standing"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dt_intelligence/image_bdd4cf64e7.png",
--           "caption": "Your reputation precedes you in every town.",
--           "width": 132,
--           "height": 114,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.1595744680851063
--         },
--         {
--           "type": "paragraph",
--           "text": "Traders don't inherently trust strangers. Every trader may belong to a Faction, and your 'Standing' with that Faction dictates the terms of your interaction with them. Building a positive reputation through fair trades and fulfilling demands will earn you better prices and unlock specialized inventory and can even recruit them(Dynamic Colonies Required). \n\nConversely, hostility or ignoring a faction's pleas will restrict your access to their services(Partially Implemented)."
--         }
--       ]
--     },
--     {
--       "id": "economics_dashboard",
--       "chapter_id": "deep_intel",
--       "title": "Market Trends",
--       "keywords": [
--         "economics",
--         "market",
--         "trends",
--         "inflation",
--         "multipliers"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "reading-the-market",
--           "level": 1,
--           "text": "Global Market Dashboard"
--         },
--         {
--           "type": "paragraph",
--           "text": "The Economics tab is the brain of the market. It shows you exactly how events and inflation are affecting prices across the world. Look for the 'Market Multipliers' to see which categories (like Food or Ammo) are currently volatile."
--         },
--         {
--           "type": "paragraph",
--           "text": "If you see a 2.50x multiplier on Medical supplies, it’s a sign of a global plague or a local raid. Savvy traders use these trends to decide when to sell their stockpiles for maximum profit."
--         }
--       ]
--     },
--     {
--       "id": "stockpiles_logistics",
--       "chapter_id": "deep_intel",
--       "title": "Resource Management",
--       "keywords": [
--         "stockpiles",
--         "resources",
--         "food",
--         "meds",
--         "supply"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "monitoring-supplies",
--           "level": 1,
--           "text": "Stockpiles & Attrition"
--         },
--         {
--           "type": "paragraph",
--           "text": "Every faction maintains a stockpile of essential resources. If their Food or Medical supplies drop to zero, they'll experience 'Attrition' their members will begin to die from neglect."
--         },
--         {
--           "type": "paragraph",
--           "text": "By monitoring these levels, you can predict what a faction needs most. Selling them a crate of canned food when they're starving isn't just profitable; it keeps their market alive."
--         }
--       ]
--     },
--     {
--       "id": "population_roster",
--       "chapter_id": "deep_intel",
--       "title": "The Human Cost",
--       "keywords": [
--         "population",
--         "roster",
--         "members",
--         "survival",
--         "dead"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "roster-management",
--           "level": 1,
--           "text": "Faction Roster"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dt_intelligence/image_12ca421aa5.png",
--           "caption": "",
--           "width": 220,
--           "height": 140,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.5714285714285714
--         },
--         {
--           "type": "paragraph",
--           "text": "The Population tab shows every individual member of a faction. You can track their status whether they're out trading, guarding a camp, or if they've met a grim end in the streets."
--         },
--         {
--           "type": "paragraph",
--           "text": "For factions you control, this interface allows you to dispatch workers to specific trade routes or recall them to safety when a storm hits."
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_intelligence", {
        title = "Faction Intelligence",
        description = "Guide to monitoring faction wealth, survival, and economic trends.",
        startPageId = "intel_overview",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 2,
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
                id = "public_intel",
                title = "Public Intelligence",
                description = "Understanding reputations and basic faction info.",
            },
            {
                id = "deep_intel",
                title = "Deep Logistics",
                description = "Monitoring stockpiles, population, and market trends.",
            },
        },
        pages = {
            {
                id = "intel_overview",
                chapterId = "public_intel",
                title = "The Intelligence Window",
                keywords = { "intel", "intelligence", "ui", "window" },
                blocks = {
                    { type = "heading", id = "intel-intro", level = 1, text = "The Intelligence Window" },
                    { type = "image", path = "media/ui/Manuals/dt_intelligence/image.png", caption = "", width = 0, height = 141 },
                    { type = "paragraph", text = "Knowledge is as valuable as ammunition. The Faction Intelligence window is your tactical dashboard for the entire exclusion zone. It allows you to monitor the health, wealth, and stability of every group you've encountered." },
                    { type = "callout", tone = "info", title = "Field Tip", text = "Access the Intelligence window through the radio(V1) or scanner/info(v2)" },
                },
            },
            {
                id = "reputation_system",
                chapterId = "public_intel",
                title = "Reputation & Trust",
                keywords = { "faction", "standing", "reputation", "trust" },
                blocks = {
                    { type = "heading", id = "trust-mechanics", level = 1, text = "Factions & Standing" },
                    { type = "image", path = "media/ui/Manuals/dt_intelligence/image_bdd4cf64e7.png", caption = "Your reputation precedes you in every town.", width = 132, height = 114 },
                    { type = "paragraph", text = "Traders don't inherently trust strangers. Every trader may belong to a Faction, and your 'Standing' with that Faction dictates the terms of your interaction with them. Building a positive reputation through fair trades and fulfilling demands will earn you better prices and unlock specialized inventory and can even recruit them(Dynamic Colonies Required). \n\nConversely, hostility or ignoring a faction's pleas will restrict your access to their services(Partially Implemented)." },
                },
            },
            {
                id = "economics_dashboard",
                chapterId = "deep_intel",
                title = "Market Trends",
                keywords = { "economics", "market", "trends", "inflation", "multipliers" },
                blocks = {
                    { type = "heading", id = "reading-the-market", level = 1, text = "Global Market Dashboard" },
                    { type = "paragraph", text = "The Economics tab is the brain of the market. It shows you exactly how events and inflation are affecting prices across the world. Look for the 'Market Multipliers' to see which categories (like Food or Ammo) are currently volatile." },
                    { type = "paragraph", text = "If you see a 2.50x multiplier on Medical supplies, it’s a sign of a global plague or a local raid. Savvy traders use these trends to decide when to sell their stockpiles for maximum profit." },
                },
            },
            {
                id = "stockpiles_logistics",
                chapterId = "deep_intel",
                title = "Resource Management",
                keywords = { "stockpiles", "resources", "food", "meds", "supply" },
                blocks = {
                    { type = "heading", id = "monitoring-supplies", level = 1, text = "Stockpiles & Attrition" },
                    { type = "paragraph", text = "Every faction maintains a stockpile of essential resources. If their Food or Medical supplies drop to zero, they'll experience 'Attrition' their members will begin to die from neglect." },
                    { type = "paragraph", text = "By monitoring these levels, you can predict what a faction needs most. Selling them a crate of canned food when they're starving isn't just profitable; it keeps their market alive." },
                },
            },
            {
                id = "population_roster",
                chapterId = "deep_intel",
                title = "The Human Cost",
                keywords = { "population", "roster", "members", "survival", "dead" },
                blocks = {
                    { type = "heading", id = "roster-management", level = 1, text = "Faction Roster" },
                    { type = "image", path = "media/ui/Manuals/dt_intelligence/image_12ca421aa5.png", caption = "", width = 220, height = 140 },
                    { type = "paragraph", text = "The Population tab shows every individual member of a faction. You can track their status whether they're out trading, guarding a camp, or if they've met a grim end in the streets." },
                    { type = "paragraph", text = "For factions you control, this interface allows you to dispatch workers to specific trade routes or recall them to safety when a storm hits." },
                },
            },
        },
    })
end
