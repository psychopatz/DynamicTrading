-- DT_MANUAL_EDITOR_BEGIN
-- {
--   "manual_id": "dt_events",
--   "title": "World Events & Crises",
--   "description": "A field guide to the sudden shifts and seasonal cycles that define life and death in Kentucky.",
--   "start_page_id": "event_types",
--   "chapters": [
--     { "id": "types", "title": "Recognizing the Shift", "description": "Learning to tell a local riot from a global plague." },
--     { "id": "mechanics", "title": "The Lottery of Fate", "description": "How the world changes while you sleep." }
--   ],
--   "pages": [
--     {
--       "id": "event_types",
--       "chapter_id": "types",
--       "title": "Three Types of Chaos",
--       "keywords": ["flash", "meta", "seasonal", "types", "crises"],
--       "blocks": [
--         { "type": "heading", "id": "flash-events", "level": 1, "text": "Sudden Flashes" },
--         { "type": "paragraph", "text": "Flash events are local and violent. A 'Warehouse Fire' or a 'Civil Riot' will only affect the town it happens in. They burn hot and fast—blink and you'll miss the window to sell your surplus or grab a bargain." },
--         { "type": "heading", "id": "meta-events", "level": 1, "text": "Global Shifts" },
--         { "type": "paragraph", "text": "Meta events are world-altering. A 'State-wide Shortage' or a 'Plague Outbreak' affects every merchant from Rosewood to West Point. These aren't just market blips; they are new realities you must adapt to." },
--         { "type": "heading", "id": "seasonal-events", "level": 1, "text": "The Turning Seasons" },
--         { "type": "paragraph", "text": "The seasons wait for no one. Expect 'Winter Scarcity' to make food a luxury when the snow falls, and 'Summer Surplus' to make basics cheap when the sun is out. Plan your stockpile months in advance." }
--       ]
--     },
--     {
--       "id": "event_lottery",
--       "chapter_id": "mechanics",
--       "title": "The Daily Roll",
--       "keywords": ["lottery", "chance", "probability", "daily"],
--       "blocks": [
--         { "type": "heading", "id": "how-it-triggers", "level": 1, "text": "The Hour of Choice" },
--         { "type": "paragraph", "text": "Every hour, the server rolls the dice for every faction. It checks if they're already overwhelmed with events and if enough time has passed since the last crisis. If the gods of fate are feeling fickle, a new event triggers immediately." },
--         { "type": "paragraph", "text": "Once an event hits, it marks the merchants. They'll adjust their stock and prices based on the new reality, and they won't go back until the event timer runs out." }
--       ]
--     },
--     {
--       "id": "stacking_model",
--       "chapter_id": "mechanics",
--       "title": "Compounding Crises",
--       "keywords": ["stacking", "compounding", "crises", "multipliers"],
--       "blocks": [
--         { "type": "heading", "id": "the-stacking-rule", "level": 1, "text": "When Disasters Overlap" },
--         { "type": "paragraph", "text": "Disasters don't just add up; they multiply. If a 'Plague' doubles medical prices and a local 'Medical Raid' doubles them again, you're looking at a 400% price hike. Overlapping events can turn a slightly expensive item into a king's ransom overnight." },
--         { "type": "image", "path": "media/ui/Backgrounds/sunrise.png", "caption": "The market doesn't care about your budget during a triple-crisis.", "width": 400, "height": 200 },
--         { "type": "callout", "tone": "warn", "title": "Survival Tip", "text": "Always check your Faction Intelligence window. If the 'Market Breakdown' shows multiple red multipliers, it's time to sell your stockpile and run for the hills." }
--       ]
--     },
--     {
--       "id": "faction_impact",
--       "chapter_id": "mechanics",
--       "title": "The Human Cost",
--       "keywords": ["deaths", "casualties", "attrition", "starvation"],
--       "blocks": [
--         { "type": "heading", "id": "human-cost", "level": 1, "text": "Casualties and Starvation" },
--         { "type": "paragraph", "text": "Events aren't just numbers on a screen. Factions lose people during a 'Civil War' or a 'Plague'. If you see a faction's population dropping, it's because the events are taking their toll." },
--         { "type": "paragraph", "text": "Worse still is 'Attrition'. If a town runs out of food or medical supplies during an event, people start dying from neglect. You have the power to stop this—selling them the supplies they need can stabilize their population." }
--       ]
--     }
--   ]
-- }
-- DT_MANUAL_EDITOR_END
if DynamicTrading and DynamicTrading.RegisterManual then
    DynamicTrading.RegisterManual("dt_events", {
        title = "World Events & Crises",
        description = "A field guide to the sudden shifts and seasonal cycles that define life and death in Kentucky.",
        startPageId = "event_types",
        chapters = {
            { id = "types", title = "Recognizing the Shift", description = "Learning to tell a local riot from a global plague." },
            { id = "mechanics", title = "The Lottery of Fate", description = "How the world changes while you sleep." },
        },
        pages = {
            {
                id = "event_types",
                chapterId = "types",
                title = "Three Types of Chaos",
                keywords = { "flash", "meta", "seasonal", "types", "crises" },
                blocks = {
                    { type = "heading", id = "flash-events", level = 1, text = "Sudden Flashes" },
                    { type = "paragraph", text = "Flash events are local and violent. A 'Warehouse Fire' or a 'Civil Riot' will only affect the town it happens in. They burn hot and fast—blink and you'll miss the window to sell your surplus or grab a bargain." },
                    { type = "heading", id = "meta-events", level = 1, text = "Global Shifts" },
                    { type = "paragraph", text = "Meta events are world-altering. A 'State-wide Shortage' or a 'Plague Outbreak' affects every merchant from Rosewood to West Point. These aren't just market blips; they are new realities you must adapt to." },
                    { type = "heading", id = "seasonal-events", level = 1, text = "The Turning Seasons" },
                    { type = "paragraph", text = "The seasons wait for no one. Expect 'Winter Scarcity' to make food a luxury when the snow falls, and 'Summer Surplus' to make basics cheap when the sun is out. Plan your stockpile months in advance." },
                },
            },
            {
                id = "event_lottery",
                chapterId = "mechanics",
                title = "The Daily Roll",
                keywords = { "lottery", "chance", "probability", "daily" },
                blocks = {
                    { type = "heading", id = "how-it-triggers", level = 1, text = "The Hour of Choice" },
                    { type = "paragraph", text = "Every hour, the server rolls the dice for every faction. It checks if they're already overwhelmed with events and if enough time has passed since the last crisis. If the gods of fate are feeling fickle, a new event triggers immediately." },
                    { type = "paragraph", text = "Once an event hits, it marks the merchants. They'll adjust their stock and prices based on the new reality, and they won't go back until the event timer runs out." },
                },
            },
            {
                id = "stacking_model",
                chapterId = "mechanics",
                title = "Compounding Crises",
                keywords = { "stacking", "compounding", "crises", "multipliers" },
                blocks = {
                    { type = "heading", id = "the-stacking-rule", level = 1, text = "When Disasters Overlap" },
                    { type = "paragraph", text = "Disasters don't just add up; they multiply. If a 'Plague' doubles medical prices and a local 'Medical Raid' doubles them again, you're looking at a 400% price hike. Overlapping events can turn a slightly expensive item into a king's ransom overnight." },
                    { type = "image", path = "media/ui/Backgrounds/sunrise.png", caption = "The market doesn't care about your budget during a triple-crisis.", width = 400, height = 200 },
                    { type = "callout", tone = "warn", title = "Survival Tip", text = "Always check your Faction Intelligence window. If the 'Market Breakdown' shows multiple red multipliers, it's time to sell your stockpile and run for the hills." },
                },
            },
            {
                id = "faction_impact",
                chapterId = "mechanics",
                title = "The Human Cost",
                keywords = { "deaths", "casualties", "attrition", "starvation" },
                blocks = {
                    { type = "heading", id = "human-cost", level = 1, text = "Casualties and Starvation" },
                    { type = "paragraph", text = "Events aren't just numbers on a screen. Factions lose people during a 'Civil War' or a 'Plague'. If you see a faction's population dropping, it's because the events are taking their toll." },
                    { type = "paragraph", text = "Worse still is 'Attrition'. If a town runs out of food or medical supplies during an event, people start dying from neglect. You have the power to stop this—selling them the supplies they need can stabilize their population." },
                },
            },
        },
    })
end
