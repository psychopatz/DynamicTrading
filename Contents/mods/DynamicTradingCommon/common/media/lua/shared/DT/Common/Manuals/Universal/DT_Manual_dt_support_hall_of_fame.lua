-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_support_hall_of_fame",
--   "module": "DynamicTradingCommon",
--   "title": "Thank You",
--   "description": "Recognizes the supporters helping fund continued development.",
--   "start_page_id": "hall_of_fame_showcase",
--   "audiences": [
--     "DynamicTradingCommon"
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
--       "title": "Supporters",
--       "description": "Recognizes the supporters helping keep the project moving."
--     }
--   ],
--   "pages": [
--     {
--       "id": "hall_of_fame_showcase",
--       "chapter_id": "hall_of_fame",
--       "title": "Supporters",
--       "keywords": [
--         "support",
--         "donators",
--         "supporters",
--         "donation",
--         "thank you"
--       ],
--       "blocks": [
--         {
--           "type": "supporter_carousel",
--           "title": "Thank You",
--           "autoplay_ms": 4000,
--           "currency_symbol": "$",
--           "thank_you_text": "Thank you to everyone who’s supported the development of this mod. Your donations go directly into tools and resources (like Copilot) that help me build faster and improve things more often. It genuinely makes a difference. \n\nShout out to Summer for covering it up that made the companion system developed faster <3.",
--           "supporters": [
--             {
--               "id": "alice",
--               "name": "Alice",
--               "total_donation": 25.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_de8169ec3d.png",
--               "support_message": "Nice mod",
--               "active": true
--             },
--             {
--               "id": "summer",
--               "name": "Summer",
--               "total_donation": 20.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_e3b0585f79.png",
--               "support_message": "Love your mod, thank you for sharing your creation with the community, we appreciate you!",
--               "active": true
--             },
--             {
--               "id": "amikcze",
--               "name": "Amikcze",
--               "total_donation": 10.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_fb22414ddf.png",
--               "support_message": "Thank you for the best trading mod on Zomboid! Don't bother with the people who can't read descriptions. Your vision for the mod is amazing, and the real fans appreciate the hard work. Take care of yourself first! Hopefully, we will see your vision come to life!",
--               "active": true
--             },
--             {
--               "id": "dremons",
--               "name": "Dremons",
--               "total_donation": 10.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_5e4eff3fde.png",
--               "support_message": "Greetings from Brazil",
--               "active": true
--             },
--             {
--               "id": "psy",
--               "name": "Psy",
--               "total_donation": 10.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_46a120b30e.png",
--               "support_message": "Thanks for the mod, I'm really enjoying the extra depth and purpose it gives to the game. Just started my first run with the colony add-on!",
--               "active": true
--             },
--             {
--               "id": "supporter_4",
--               "name": "ДанилоМироненко",
--               "total_donation": 10.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_1b927e850e.png",
--               "support_message": "I sent a donation and wanted to suggest improving price balance, as some values feel inconsistent.\n\nThanks for your work!",
--               "active": true
--             },
--             {
--               "id": "slayter",
--               "name": "Slayter",
--               "total_donation": 5.0,
--               "image_path": "media/ui/Manuals/dt_support_hall_of_fame/image_67df704544.png",
--               "support_message": "",
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
        title = "Thank You",
        description = "Recognizes the supporters helping fund continued development.",
        startPageId = "hall_of_fame_showcase",
        audiences = { "DynamicTradingCommon" },
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
                title = "Supporters",
                description = "Recognizes the supporters helping keep the project moving.",
            },
        },
        pages = {
            {
                id = "hall_of_fame_showcase",
                chapterId = "hall_of_fame",
                title = "Supporters",
                keywords = { "support", "donators", "supporters", "donation", "thank you" },
                blocks = {
                    { type = "supporter_carousel", title = "Thank You", autoplayMs = 4000, currencySymbol = "$", thankYouText = "Thank you to everyone who’s supported the development of this mod. Your donations go directly into tools and resources (like Copilot) that help me build faster and improve things more often. It genuinely makes a difference. \n\nShout out to Summer for covering it up that made the companion system developed faster <3.", supporters = { { id = "alice", name = "Alice", totalDonation = 25.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_de8169ec3d.png", supportMessage = "Nice mod", active = true }, { id = "alice", name = "Alice", totalDonation = 25.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_776caca2cb.png", supportMessage = "Nice mod", active = true }, { id = "summer", name = "Summer", totalDonation = 20.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_e3b0585f79.png", supportMessage = "Love your mod, thank you for sharing your creation with the community, we appreciate you!", active = true }, { id = "amikcze", name = "Amikcze", totalDonation = 10.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_fb22414ddf.png", supportMessage = "Thank you for the best trading mod on Zomboid! Don't bother with the people who can't read descriptions. Your vision for the mod is amazing, and the real fans appreciate the hard work. Take care of yourself first! Hopefully, we will see your vision come to life!", active = true }, { id = "dremons", name = "Dremons", totalDonation = 10.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_5e4eff3fde.png", supportMessage = "Greetings from Brazil", active = true }, { id = "psy", name = "Psy", totalDonation = 10.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_46a120b30e.png", supportMessage = "Thanks for the mod, I'm really enjoying the extra depth and purpose it gives to the game. Just started my first run with the colony add-on!", active = true }, { id = "supporter_4", name = "ДанилоМироненко", totalDonation = 10.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_1b927e850e.png", supportMessage = "I sent a donation and wanted to suggest improving price balance, as some values feel inconsistent.\n\nThanks for your work!", active = true }, { id = "slayter", name = "Slayter", totalDonation = 5.0, imagePath = "media/ui/Manuals/dt_support_hall_of_fame/image_67df704544.png", supportMessage = "", active = true } } },
                },
            },
        },
    })
end
