-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_support_patreon",
--   "module": "DynamicTradingCommon",
--   "title": "Support the Mod",
--   "description": "Support page for players who want to fund continued development",
--   "start_page_id": "support_overview",
--   "audiences": [
--     "DynamicTradingCommon"
--   ],
--   "sort_order": 9999999,
--   "release_version": "",
--   "popup_version": "dt_support_patreon",
--   "auto_open_on_update": false,
--   "is_whats_new": false,
--   "manual_type": "support",
--   "show_in_library": false,
--   "support_url": "",
--   "banner_title": "",
--   "banner_text": "",
--   "banner_action_label": "",
--   "source_folder": "Support",
--   "chapters": [
--     {
--       "id": "support",
--       "title": "Support",
--       "description": "How to help fund continued development."
--     }
--   ],
--   "pages": [
--     {
--       "id": "support_overview",
--       "chapter_id": "support",
--       "title": "Keep The Project Alive",
--       "keywords": [
--         "support",
--         "Ko-Fi",
--         "funding",
--         "donate"
--       ],
--       "blocks": [
--         {
--           "type": "supporter_carousel",
--           "title": "Thank You",
--           "compact": true,
--           "autoplay_ms": 4000,
--           "currency_symbol": "$",
--           "thank_you_text": "",
--           "supporters_ref": "dt_support_hall_of_fame"
--         },
--         {
--           "type": "heading",
--           "id": "support-dynamic-trading",
--           "level": 1,
--           "text": "Support Dynamic Trading"
--         },
--         {
--           "type": "paragraph",
--           "text": "Dynamic Trading Needs ya <3"
--         },
--         {
--           "type": "image",
--           "path": "media/ui/Manuals/dt_support_patreon/donate.png",
--           "caption": "",
--           "width": 247,
--           "height": 167,
--           "keep_aspect_ratio": true,
--           "aspect_ratio": 1.4790419161676647
--         },
--         {
--           "type": "paragraph",
--           "text": "I started making this mod as a hobby, mostly because I hit that point in Project Zomboid where the late game just feels… empty. I love the simulation side of it, and Zomboid gets so close to something incredible but it’s always felt like it was missing real NPC interaction and something meaningful to work toward long-term."
--         },
--         {
--           "type": "paragraph",
--           "text": "So I figured I’d try building that myself."
--         },
--         {
--           "type": "paragraph",
--           "text": "What I ended up with is a mix of a trading system and a colony simulator, kind of like if State of Decay and RimWorld somehow existed inside Zomboid(UI only and some basic functionalities for now but I will port an actual V2 compatible once I finalized the System to make my implimentation easier). It’s been a genuinely fun project to work on, and seeing people actually enjoy it has made it even better."
--         },
--         {
--           "type": "paragraph",
--           "text": "That said, the codebase is getting pretty big now. I’ve been “vibe-coding” most of it using free AI tools (mainly Gemini), but I’ve completely hit my usage limits and can’t really continue until they reset next week… which is frustrating when you’re in the middle of a good streak."
--         },
--         {
--           "type": "paragraph",
--           "text": "So I’m trying to scrape together about $200 for a paid plan to keep working on this in my spare time. If you’ve been enjoying the mod and feel like supporting it, even $1 genuinely helps."
--         },
--         {
--           "type": "paragraph",
--           "text": "As a thank you, I’ll add your character into the colony roster, and if you’re feeling extra generous, I can even build a custom quest around them (those take a bit more work and tokens, especially with dialogue but hopefully I can streamline it)."
--         },
--         {
--           "type": "paragraph",
--           "text": "No pressure at all either way. I’m just really glad people are enjoying it."
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Ko-Fi:",
--           "text": "https://ko-fi.com/psychopatz"
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_support_patreon", {
        title = "Support the Mod",
        description = "Support page for players who want to fund continued development",
        startPageId = "support_overview",
        audiences = { "DynamicTradingCommon" },
        sortOrder = 9999999,
        releaseVersion = "",
        popupVersion = "dt_support_patreon",
        autoOpenOnUpdate = false,
        isWhatsNew = false,
        manualType = "support",
        showInLibrary = false,
        supportUrl = "",
        bannerTitle = "",
        bannerText = "",
        bannerActionLabel = "",
        chapters = {
            {
                id = "support",
                title = "Support",
                description = "How to help fund continued development.",
            },
        },
        pages = {
            {
                id = "support_overview",
                chapterId = "support",
                title = "Keep The Project Alive",
                keywords = { "support", "Ko-Fi", "funding", "donate" },
                blocks = {
                    { type = "supporter_carousel", title = "Thank You", compact = true, autoplayMs = 4000, currencySymbol = "$", thankYouText = "", supportersRef = "dt_support_hall_of_fame" },
                    { type = "heading", id = "support-dynamic-trading", level = 1, text = "Support Dynamic Trading" },
                    { type = "paragraph", text = "Dynamic Trading Needs ya <3" },
                    { type = "image", path = "media/ui/Manuals/dt_support_patreon/donate.png", caption = "", width = 247, height = 167 },
                    { type = "paragraph", text = "I started making this mod as a hobby, mostly because I hit that point in Project Zomboid where the late game just feels… empty. I love the simulation side of it, and Zomboid gets so close to something incredible but it’s always felt like it was missing real NPC interaction and something meaningful to work toward long-term." },
                    { type = "paragraph", text = "So I figured I’d try building that myself." },
                    { type = "paragraph", text = "What I ended up with is a mix of a trading system and a colony simulator, kind of like if State of Decay and RimWorld somehow existed inside Zomboid(UI only and some basic functionalities for now but I will port an actual V2 compatible once I finalized the System to make my implimentation easier). It’s been a genuinely fun project to work on, and seeing people actually enjoy it has made it even better." },
                    { type = "paragraph", text = "That said, the codebase is getting pretty big now. I’ve been “vibe-coding” most of it using free AI tools (mainly Gemini), but I’ve completely hit my usage limits and can’t really continue until they reset next week… which is frustrating when you’re in the middle of a good streak." },
                    { type = "paragraph", text = "So I’m trying to scrape together about $200 for a paid plan to keep working on this in my spare time. If you’ve been enjoying the mod and feel like supporting it, even $1 genuinely helps." },
                    { type = "paragraph", text = "As a thank you, I’ll add your character into the colony roster, and if you’re feeling extra generous, I can even build a custom quest around them (those take a bit more work and tokens, especially with dialogue but hopefully I can streamline it)." },
                    { type = "paragraph", text = "No pressure at all either way. I’m just really glad people are enjoying it." },
                    { type = "callout", tone = "info", title = "Ko-Fi:", text = "https://ko-fi.com/psychopatz" },
                },
            },
        },
    })
end
