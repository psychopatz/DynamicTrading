-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_support_patreon",
--   "manual_type": "support",
--   "title": "Support Dynamic Trading",
--   "description": "A short support page for players who want to fund continued development.",
--   "start_page_id": "support_overview",
--   "popup_version": "support-1",
--   "sort_order": 999900,
--   "show_in_library": false,
--   "banner_title": "Support Dynamic Trading On Patreon",
--   "banner_text": "If this mod has earned a permanent slot in your load order, consider backing development so updates ship faster and stay sustainable.",
--   "banner_action_label": "View Support",
--   "support_url": "https://www.patreon.com/",
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
--         "patreon",
--         "funding",
--         "donate"
--       ],
--       "blocks": [
--         {
--           "type": "heading",
--           "id": "support-dynamic-trading",
--           "level": 1,
--           "text": "Support Dynamic Trading"
--         },
--         {
--           "type": "paragraph",
--           "text": "Dynamic Trading is a long-tail mod. The more stable support it gets, the easier it is to keep shipping fixes, better manuals, and larger system updates without burning out the schedule."
--         },
--         {
--           "type": "bullet_list",
--           "items": [
--             "Back the project if you want to help fund continued maintenance and faster iteration.",
--             "Share the mod with other players if you cannot contribute financially.",
--             "Report clean bug repro steps so fixes land faster."
--           ]
--         },
--         {
--           "type": "callout",
--           "tone": "info",
--           "title": "Patreon",
--           "text": "Patreon URL: https://www.patreon.com/  Update the support_url field in Mod Manager when your real page is ready."
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_support_patreon", {
        manualType = "support",
        title = "Support Dynamic Trading",
        description = "A short support page for players who want to fund continued development.",
        startPageId = "support_overview",
        popupVersion = "support-1",
        sortOrder = 999900,
        showInLibrary = false,
        bannerTitle = "Support Dynamic Trading On Patreon",
        bannerText = "If this mod has earned a permanent slot in your load order, consider backing development so updates ship faster and stay sustainable.",
        bannerActionLabel = "View Support",
        supportUrl = "https://www.patreon.com/",
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
                keywords = { "support", "patreon", "funding", "donate" },
                blocks = {
                    { type = "heading", id = "support-dynamic-trading", level = 1, text = "Support Dynamic Trading" },
                    { type = "paragraph", text = "Dynamic Trading is a long-tail mod. The more stable support it gets, the easier it is to keep shipping fixes, better manuals, and larger system updates without burning out the schedule." },
                    { type = "bullet_list", items = {
                        "Back the project if you want to help fund continued maintenance and faster iteration.",
                        "Share the mod with other players if you cannot contribute financially.",
                        "Report clean bug repro steps so fixes land faster."
                    } },
                    { type = "callout", tone = "info", title = "Patreon", text = "Patreon URL: https://www.patreon.com/  Update the supportUrl field when your real page is ready." },
                },
            },
        },
    })
end
