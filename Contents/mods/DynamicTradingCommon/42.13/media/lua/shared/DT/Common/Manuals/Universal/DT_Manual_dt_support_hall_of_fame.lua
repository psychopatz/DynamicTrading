-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_support_hall_of_fame",
--   "module": "common",
--   "title": "Hall of Fame Donators",
--   "description": "Recognizes the supporters helping fund continued development.",
--   "start_page_id": "hall_of_fame_showcase",
--   "audiences": [
--     "common"
--   ],
--   "sort_order": 9999998,
--   "release_version": "",
--   "popup_version": "",
--   "auto_open_on_update": false,
--   "is_whats_new": false,
--   "manual_type": "donators",
--   "show_in_library": false,
--   "support_url": "",
--   "banner_title": "",
--   "banner_text": "",
--   "banner_action_label": "",
--   "source_folder": "Support",
--   "chapters": [
--     {
--       "id": "hall_of_fame",
--       "title": "Hall of Fame",
--       "description": "Recognizes the supporters helping keep the project moving."
--     }
--   ],
--   "pages": [
--     {
--       "id": "hall_of_fame_showcase",
--       "chapter_id": "hall_of_fame",
--       "title": "Hall of Fame",
--       "keywords": [
--         "support",
--         "donators",
--         "hall of fame",
--         "supporters",
--         "donation"
--       ],
--       "blocks": [
--         {
--           "type": "supporter_carousel",
--           "title": "Hall of Fame Donators",
--           "autoplay_ms": 4000,
--           "currency_symbol": "$",
--           "thank_you_text": "Thank you to everyone helping keep Dynamic Trading moving.",
--           "supporters": [
--             {
--               "id": "summer",
--               "name": "Summer",
--               "total_donation": 20.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_e3b0585f79.png",
--               "active": true
--             },
--             {
--               "id": "sy",
--               "name": "Sy",
--               "total_donation": 1.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_ef8ebfa9fd.png",
--               "active": true
--             },
--             {
--               "id": "w",
--               "name": "w",
--               "total_donation": 0.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_1221f7d13e.png",
--               "active": true
--             }
--           ]
--         }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_support_hall_of_fame", {
        title = "Hall of Fame Donators",
        description = "Recognizes the supporters helping fund continued development.",
        startPageId = "hall_of_fame_showcase",
        audiences = { "common" },
        sortOrder = 9999998,
        releaseVersion = "",
        popupVersion = "",
        autoOpenOnUpdate = false,
        isWhatsNew = false,
        manualType = "donators",
        showInLibrary = false,
        supportUrl = "",
        bannerTitle = "",
        bannerText = "",
        bannerActionLabel = "",
        chapters = {
            {
                id = "hall_of_fame",
                title = "Hall of Fame",
                description = "Recognizes the supporters helping keep the project moving.",
            },
        },
        pages = {
            {
                id = "hall_of_fame_showcase",
                chapterId = "hall_of_fame",
                title = "Hall of Fame",
                keywords = { "support", "donators", "hall of fame", "supporters", "donation" },
                blocks = {
                    { type = "supporter_carousel", title = "Hall of Fame Donators", autoplayMs = 4000, currencySymbol = "$", thankYouText = "Thank you to everyone helping keep Dynamic Trading moving.", supporters = { { id = "summer", name = "Summer", totalDonation = 20.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_e3b0585f79.png", active = true }, { id = "sy", name = "Sy", totalDonation = 1.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_ef8ebfa9fd.png", active = true }, { id = "w", name = "w", totalDonation = 0.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_1221f7d13e.png", active = true } } },
                },
            },
        },
    })
end
