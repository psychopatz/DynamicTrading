require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: LITERACY CRISIS
-- =============================================================================

DynamicTrading.Events.Register("KnowledgeGap", {
    name = "Knowledge Gap",
    sentiment = "Negative",
    type = "meta",
    description = "Technical manuals are degrading or lost. Knowledge is becoming the ultimate currency.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 180
    end,
    effects = {
        ["Literature.SkillBook"] = { price = 3.5, vol = 0.2 }, -- Extremely rare/expensive
        ["Literature"] = { price = 2.0 },           -- Entertainment is precious
        ["Resource.Material.Paper"] = { price = 1.5 },                -- For writing new notes
        ["Literature.Book"] = { price = 2.5 }
    },
    factionImpact = {
        stabilityAdd = -3
    }
})
