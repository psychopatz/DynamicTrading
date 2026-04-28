-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_economy",
--   "module": "DynamicTradingCommon",
--   "title": "Economic System",
--   "description": "Guide for proper inflation and deflation mechanics",
--   "start_page_id": "price_calculation",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 3,
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
--       "id": "pricing",
--       "title": "Art of the Deal",
--       "description": "Understanding how your loot turns into coin."
--     },
--     {
--       "id": "specialization",
--       "title": "Expertise & Connections",
--       "description": "Finding the right buyer for your specialized gear."
--     }
--   ],
--   "pages": [
--     {
--       "id": "price_calculation",
--       "chapter_id": "pricing",
--       "title": "Pricing Your Loot",
--       "keywords": [
--         "math",
--         "formula",
--         "buy",
--         "sell",
--         "profit"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "sell-math",
--           "level": 1,
--           "text": "Cashing Out"
--         },
--         {
--           "type": "paragraph",
--           "text": "In the exclusion zone, nothing has a fixed price. When you approach a merchant, they'll weigh your items against rarity, demand, and their own expertise. Expect to walk away with about half of the 'official' value on average, but a savvy trader knows how to push that higher."
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Merchant Observation",
--           "text": "I sold a single Catfish to a hungry angler for $15 today. A general trader wouldn't have given me more than $10. Shop around!"
--         },
--         {
--           "type": "heading",
--           "id": "buy-math",
--           "level": 1,
--           "text": "The Merchant's Cut"
--         },
--         {
--           "type": "paragraph",
--           "text": "Merchants aren't in this for charity. They'll add at least a 20% markup on everything they sell. If you see high prices, blame the world events, not the middleman."
--         }
--       ]
--     },
--     {
--       "id": "scarcity",
--       "chapter_id": "pricing",
--       "title": "Scarcity & Desperation",
--       "keywords": [
--         "stock",
--         "scarcity",
--         "bonus",
--         "profit"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "scarcity-bonus",
--           "level": 1,
--           "text": "Supply and Demand"
--         },
--         {
--           "type": "paragraph",
--           "text": "When a trader's shelves are bare, they get desperate. If you bring them something they don't have in stock, they'll often pay a 50% premium just to get it back on the shelf."
--         },
--         {
--           "type": "paragraph",
--           "text": "Even bringing a few units of a low-stock item can net you a 20% bonus. Keep an eye on what's missing from their inventory before you sell your high-tier gear."
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Icon_MarketInfo.png",
--           "caption": "Empty shelves are a scavenger's best friend.",
--           "width": 64,
--           "height": 64,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.0
--         }
--       ]
--     },
--     {
--       "id": "expertise",
--       "chapter_id": "specialization",
--       "title": "Knowing the Buyer",
--       "keywords": [
--         "expert",
--         "wants",
--         "forbid",
--         "specialty"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "expert-bonus",
--           "level": 1,
--           "text": "Finding Specialists"
--         },
--         {
--           "type": "paragraph",
--           "text": "Every trader has a specialty. A gunsmith knows his bullets, and a doctor knows her pills. Selling items that match their expertise grants you a 25% price bonus. Don't waste your ammo on a general store clerk!"
--         },
--         {
--           "type": "heading",
--           "id": "trader-wants",
--           "level": 2,
--           "text": "Greedy Merchants"
--         },
--         {
--           "type": "paragraph",
--           "text": "Sometimes a merchant really 'wants' an item for their personal collection or hidden contacts. Be prepared to pay a 20% premium if you're trying to buy these items off them."
--         },
--         {
--           "type": "heading",
--           "id": "forbid-system",
--           "level": 2,
--           "text": "Hard Refusals"
--         },
--         {
--           "type": "paragraph",
--           "text": "Some deals just aren't going to happen. You won't sell a rifle to a pacifist medic, no matter how much you beg. Learn the boundaries of your local traders."
--         }
--       ]
--     },
--     {
--       "id": "condition_charge",
--       "chapter_id": "specialization",
--       "title": "Quality Counts",
--       "keywords": [
--         "condition",
--         "drainable",
--         "repair",
--         "battery"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "wear-tear",
--           "level": 1,
--           "text": "Damaged Goods"
--         },
--         {
--           "type": "paragraph",
--           "text": "A broken rifle is a heavy club. If your gear is battered, expect to lose half its value or more. A few repairs with a screwdriver can double your profit margins on valuable weapons."
--         },
--         {
--           "type": "heading",
--           "id": "drainable-items",
--           "level": 2,
--           "text": "Fading Power"
--         },
--         {
--           "type": "paragraph",
--           "text": "An empty battery is just a piece of plastic. Merchants weigh your flashlights and gas cans by how much is left inside. Charge up or fill up if you want the full market price."
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_economy", {
        title = "Economic System",
        description = "Guide for proper inflation and deflation mechanics",
        startPageId = "price_calculation",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 3,
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
                id = "pricing",
                title = "Art of the Deal",
                description = "Understanding how your loot turns into coin.",
            },
            {
                id = "specialization",
                title = "Expertise & Connections",
                description = "Finding the right buyer for your specialized gear.",
            },
        },
        pages = {
            {
                id = "price_calculation",
                chapterId = "pricing",
                title = "Pricing Your Loot",
                keywords = { "math", "formula", "buy", "sell", "profit" },
                blocks = {
                    { type = "heading", id = "sell-math", level = 1, text = "Cashing Out" },
                    { type = "paragraph", text = "In the exclusion zone, nothing has a fixed price. When you approach a merchant, they'll weigh your items against rarity, demand, and their own expertise. Expect to walk away with about half of the 'official' value on average, but a savvy trader knows how to push that higher." },
                    { type = "callout", tone = "info", title = "Merchant Observation", text = "I sold a single Catfish to a hungry angler for $15 today. A general trader wouldn't have given me more than $10. Shop around!" },
                    { type = "heading", id = "buy-math", level = 1, text = "The Merchant's Cut" },
                    { type = "paragraph", text = "Merchants aren't in this for charity. They'll add at least a 20% markup on everything they sell. If you see high prices, blame the world events, not the middleman." },
                },
            },
            {
                id = "scarcity",
                chapterId = "pricing",
                title = "Scarcity & Desperation",
                keywords = { "stock", "scarcity", "bonus", "profit" },
                blocks = {
                    { type = "heading", id = "scarcity-bonus", level = 1, text = "Supply and Demand" },
                    { type = "paragraph", text = "When a trader's shelves are bare, they get desperate. If you bring them something they don't have in stock, they'll often pay a 50% premium just to get it back on the shelf." },
                    { type = "paragraph", text = "Even bringing a few units of a low-stock item can net you a 20% bonus. Keep an eye on what's missing from their inventory before you sell your high-tier gear." },
                    { type = "image", path = "media/ui/Icon_MarketInfo.png", caption = "Empty shelves are a scavenger's best friend.", width = 64, height = 64 },
                },
            },
            {
                id = "expertise",
                chapterId = "specialization",
                title = "Knowing the Buyer",
                keywords = { "expert", "wants", "forbid", "specialty" },
                blocks = {
                    { type = "heading", id = "expert-bonus", level = 1, text = "Finding Specialists" },
                    { type = "paragraph", text = "Every trader has a specialty. A gunsmith knows his bullets, and a doctor knows her pills. Selling items that match their expertise grants you a 25% price bonus. Don't waste your ammo on a general store clerk!" },
                    { type = "heading", id = "trader-wants", level = 2, text = "Greedy Merchants" },
                    { type = "paragraph", text = "Sometimes a merchant really 'wants' an item for their personal collection or hidden contacts. Be prepared to pay a 20% premium if you're trying to buy these items off them." },
                    { type = "heading", id = "forbid-system", level = 2, text = "Hard Refusals" },
                    { type = "paragraph", text = "Some deals just aren't going to happen. You won't sell a rifle to a pacifist medic, no matter how much you beg. Learn the boundaries of your local traders." },
                },
            },
            {
                id = "condition_charge",
                chapterId = "specialization",
                title = "Quality Counts",
                keywords = { "condition", "drainable", "repair", "battery" },
                blocks = {
                    { type = "heading", id = "wear-tear", level = 1, text = "Damaged Goods" },
                    { type = "paragraph", text = "A broken rifle is a heavy club. If your gear is battered, expect to lose half its value or more. A few repairs with a screwdriver can double your profit margins on valuable weapons." },
                    { type = "heading", id = "drainable-items", level = 2, text = "Fading Power" },
                    { type = "paragraph", text = "An empty battery is just a piece of plastic. Merchants weigh your flashlights and gas cans by how much is left inside. Charge up or fill up if you want the full market price." },
                },
            },
        },
    })
end
